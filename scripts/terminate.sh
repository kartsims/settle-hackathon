#!/bin/bash
set -e

echo "Destroy Script Started Running..."
source "$PWD/scripts/modules/args-parser.sh"

if [ -z "$app_uid" ]; then 
	echo "app_uid parameter was not present, can't execute this script."
	exit 1
fi

($PWD/scripts/resources-destroy.sh \
 --app_uid $app_uid \
 --app_name "api-1" \
 --app_type public || { echo 'Failed Resource Termination'; exit 1; }) #&

($PWD/scripts/resources-destroy.sh \
 --app_uid $app_uid \
 --app_name "ui-1" \
 --app_type public || { echo 'Failed Resource Termination'; exit 1; }) #&

#source $PWD/scripts/modules/jobs-await.sh
 
echo "Destroy Script Finished Running."