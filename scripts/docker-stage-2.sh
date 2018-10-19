#!/bin/bash
set -e

echo "Docker-Stage-2 Script Started Running..."
source "$PWD/scripts/modules/args-parser.sh"

if [ -z "$local_deployment" ]; then local_deployment=false; fi
if [ -z "$COMPOSE_FILE" ]; then COMPOSE_FILE="docker-compose.app.yml"; fi
if [ -z "$reg_id" ]; then reg_id="017964463726"; fi
if [ -z "$docker_repo_name" ]; then docker_repo_name="settle-apps"; fi
if [ -z "$repo_url" ]; then repo_url="$reg_id.dkr.ecr.us-east-1.amazonaws.com/$docker_repo_name"; fi

if [ -z "$app_uid" ]; then 
	echo "app_uid parameter was not present, can't execute this script and create docker images."
	exit 1
fi

echo "Creating Docker Images..."
echo "app_uid $app_uid"
echo "reg_id: $reg_id"
echo "docker_repo_name: $docker_repo_name"
echo "repo_url: $repo_url"
echo "repo_name: $repo_name"
echo "src_dir: $src_dir"

bucket="app-cluster-secrets"
artifact_path="$PWD/docker/publish"
artifacts_path_s3="$repo_name/$app_uid/artifacts"

rm -v -r -f $artifact_path
mkdir -p -v $artifact_path

echo "Downloading docker artifacts from '$artifacts_path_s3' to '$artifact_path'..."
(AWSHelper s3 download-folder --override="true" --create-output="true" --bucket=$bucket --path=$artifacts_path_s3 --output="$artifact_path"  --execution-mode=retry --retry-times=3 --retry-delay=10000 || { echo 'Failed Artifact Download'; exit 1; }) &

#cleanup
set +e
echo "Deleting all containers..."
docker rm -f $(docker ps -a -q)
echo "Deleting all images..."
docker rmi -f $(docker images -q)
set -e

cleanup_registry()
{
	set +e #don't exit
	echo "Registry cleanup started...";
	
	echo "Removing untagged images...";
	AWSHelper ecr delete --imageTag="" --registryId="$reg_id" --repositoryName="$docker_repo_name" --execution-mode="silent-errors"
	echo "Listing old images...";
	AWSHelper ecr list-images-by-tag --imageTag="$IMG_TAG" --registryId="$reg_id" --repositoryName="$docker_repo_name"
	if [ $? -eq 0 ]; then #previous command suceeded
		echo "Image $IMG_TAG was found, backing up."
		AWSHelper ecr delete --imageTag="$IMG_TAG-old" --registryId="$reg_id" --repositoryName="$docker_repo_name" --execution-mode="silent-errors"
		echo "Backingup latest image...";
		AWSHelper ecr retag --imageTag="$IMG_TAG" --imageTagNew="$IMG_TAG-old" --registryId="$reg_id" --repositoryName="$docker_repo_name" --execution-mode="silent-errors"
		echo "Removing $IMG_TAG ..."
		AWSHelper ecr delete --imageTag="$IMG_TAG" --registryId="$reg_id" --repositoryName="$docker_repo_name" --execution-mode="silent-errors"
	else #previous command failed
		echo "Image $IMG_TAG was NOT found, can't be backed up."
	fi

	echo "Registry cleanup ended."
	set -e #restore flag
}

echo "Source Location: $src_dir"

echo "Login into ECR..."
if [ "$local_deployment" = true ] ; then
	eval "aws ecr get-login --region us-east-1 --no-include-email"
else
	eval $(aws ecr get-login --region us-east-1 --no-include-email);
fi

source $PWD/scripts/modules/jobs-await.sh

i=0 #iterator to indicate nr of the image in case dirName's are the same for some of the containers

publish()
{
	dirRoot=$1
	IMG_NAME=$2
	IMG_TAG=$3
	f=$4
	img_path="$artifact_path/${IMG_NAME}.tar"
	img_path_s3="$artifacts_path_s3/${IMG_NAME}.tar"
	
	echo "Pushing Artifact $IMG_NAME to repository..."
	echo "Dir Root: $dirRoot"
	echo "File: $f"
	echo "Artifact Path: $artifact_path"

	cleanup_registry || true #don't throw

	echo "Downloading docker artifacts from '$img_path_s3' to '$artifact_path'..."
	AWSHelper s3 download-object --override="true" --create-output="true" --bucket=$bucket --path="$img_path_s3" --output="$artifact_path" --execution-mode=retry --retry-times=3 --retry-delay=10000
	
	echo "Executing: docker load of image '$img_path'"
	docker load --input "$img_path"
	docker tag "$IMG_NAME:latest" "$repo_url:$IMG_TAG"
	docker push "$repo_url:$IMG_TAG"
}

OIFS="$IFS"
IFS=$'\n'
files=$(find "$src_dir" -type f -name "$COMPOSE_FILE")
for f in $files; do
	fileName=$(basename "${f}")
	dirRoot=$(dirname "${f}")
	dirName=$(basename "${dirRoot}")
	i=$((i + 1))

	echo "Found docker yml file '$fileName' nr '$i' in dir '$dirName', full root '$dirRoot'."; 
	echo "Executing docker command..."; 
	
	IMG_NAME="$app_uid-$i"
	IMG_TAG="$app_uid-$dirName" #TODO: tag indexer - based on the dirName increment index
	
	(publish $dirRoot $IMG_NAME $IMG_TAG $f || { echo 'Failed Docker Artifact Push $IMG_NAME'; exit 1; }) &

done
IFS="$OIFS"

count=$(find "$src_dir" -name $COMPOSE_FILE | wc -l)

if [[ $count -eq 0 ]]
then
	echo "Error! Docker compose file '$COMPOSE_FILE' was not found in '$src_dir', iterations: '$i'." 
	exit 42
fi

source $PWD/scripts/modules/jobs-await.sh

echo "Docker-Stage-2 Script Finished Running."