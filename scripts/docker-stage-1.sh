#!/bin/bash
set -e

echo "Docker-Stage-1 Script Started Running..."
source "$PWD/scripts/modules/args-parser.sh"

if [ -z "$COMPOSE_FILE" ]; then COMPOSE_FILE="docker-compose.app.yml"; fi
if [ -z "$reg_id" ]; then reg_id="017964463726"; fi
if [ -z "$docker_repo_name" ]; then docker_repo_name="settle-apps"; fi
if [ -z "$repo_url" ]; then repo_url="$reg_id.dkr.ecr.us-east-1.amazonaws.com/$docker_repo_name"; fi

if [ -z "$app_uid" ]; then 
	echo "app_uid parameter was not present, can't execute this script and create docker images."
	exit 2
fi

echo "Creating Docker Images..."
echo "app_uid $app_uid"
echo "repo_url: $repo_url"
echo "repo_name: $repo_name"
echo "src_dir: $src_dir"

#cleanup
set +e
echo "Deleting all containers..."
docker rm -f $(docker ps -a -q)
echo "Deleting all images..."
docker rmi -f $(docker images -q)
set -e

artifact_path="$PWD/docker/publish"
mkdir -p -v $artifact_path

i=0 #iterator to indicate nr of the image in case dirName's are the same for some of the containers
bucket="app-cluster-secrets"
artifacts_path_s3="$repo_name/$app_uid/artifacts"

publish()
{
	dirRoot=$1
	IMG_NAME=$2
	f=$3
	img_path="$artifact_path/${IMG_NAME}.tar"
	img_path_s3="$artifacts_path_s3/${IMG_NAME}.tar"
	
	echo "Composing Artifacts with Image $IMG_NAME..."
	echo "Dir Root: $dirRoot"
	echo "File: $f"
	echo "Artifact Path: $artifact_path"
	
	CDHelper text replace --input="$f" --old="\${IMG_NAME}" --new=$IMG_NAME

	echo "Executing: docker-compose --file ${f} --project-directory $dirRoot --verbose --log-level DEBUG up --no-start"
	docker-compose --file "$f" --project-directory "$dirRoot" up --no-start
	docker save -o "$artifact_path/${IMG_NAME}.tar" "$IMG_NAME:latest"
	
	echo "Uploading new docker artifacts from 'artifact_path' to '$artifacts_path_s3'..."
	AWSHelper s3 upload-object --create-directories="true" --bucket=$bucket --path="$img_path_s3" --input="$img_path" --execution-mode=retry --retry-times=3 --retry-delay=10000
}


echo "Destroying old docker artifacts from '$artifacts_path_s3'..."
AWSHelper s3 delete-folder --bucket=$bucket --path=$artifacts_path_s3 --recursive="true" --execution-mode=retry --retry-times=3 --retry-delay=10000


OIFS="$IFS"
IFS=$'\n'
files=$(find "$src_dir" -type f -name "$COMPOSE_FILE")
for f in $files; do
	fileName=$(basename "${f}")
	dirRoot=$(dirname "${f}")
	dirName=$(basename "${dirRoot}")
	i=$((i + 1))
	IMG_NAME="$app_uid-$i"

	echo "Found docker yml file '$fileName' nr '$i' in dir '$dirName', full root '$dirRoot'."; 
	
	(publish $dirRoot $IMG_NAME $f || { echo 'Failed Docker Image Publish $IMG_NAME'; exit 1; }) &

done
IFS="$OIFS"

count=$(find "$src_dir" -name $COMPOSE_FILE | wc -l)

if [[ $count -eq 0 ]]
then
	echo "Error! No Docker compose file '$COMPOSE_FILE' was found in '$src_dir', iterations: '$i'." 
	exit 42
fi

source $PWD/scripts/modules/jobs-await.sh

echo "Docker-Stage-1 Script Finished Running."