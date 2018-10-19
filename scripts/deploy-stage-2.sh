#!/bin/bash
set -e

echo "#############################"
echo "# DEPLOYMENT PART 2 - START #"
echo "#############################"

echo "Docker-Push Script Started Running..."
source "$PWD/scripts/modules/args-parser.sh"

if [ -z "$app_uid" ]; then 
	echo "app_uid parameter was not present, can't execute this script and create docker images."
	exit 1
fi

echo "### Publishing docker images..."
$PWD/scripts/docker-stage-2.sh --app_uid $app_uid --src_dir "$PWD/Sources" --repo_name $repo_name || { echo 'Failed Docker Image Creation'; exit 1; }
 
echo "### Deploying All Resources in AWS..."

($PWD/scripts/resources-create.sh \
 --app_uid $app_uid \
 --app_name "api-1" \
 --app_port 8000 \
 --health_check_path "/api/test/ping" \
 --app_type public || { echo 'Failed Resource Creation'; exit 1; }) #&
 
($PWD/scripts/resources-create.sh \
 --app_uid $app_uid \
 --app_name "ui-1" \
 --app_port 80 \
 --health_check_path "/" \
 --app_type public || { echo 'Failed Resource Creation'; exit 1; }) #&
 
#source "$PWD/scripts/modules/jobs-await.sh"

echo "#############################"
echo "# DEPLOYMENT PART 2 - STOP  #"
echo "#############################"