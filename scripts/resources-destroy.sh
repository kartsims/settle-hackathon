#!/bin/sh

source "$PWD/scripts/modules/args-parser.sh"

if [ -z "$app_guid" ]; then app_guid="$app_uid-$app_name" ; fi;
if [ -z "$zone_public" ]; then zone_public="Z138SETQFBIP49" ; fi;
if [ -z "$zone_private" ]; then zone_private="ZY88ADO4BH74B" ; fi;
if [ -z "$cname" ]; then cname="$app_guid.$app_type" ; fi;
if [ -z "$storage_key_default_s3" ]; then storage_key_default_s3="app-cluster-default" ; fi;
if [ -z "$storage_key_internal_s3" ]; then storage_key_internal_s3="app-cluster-demo" ; fi;

echo "App Destruction: $app_guid STARTED"
echo "App Type: $app_type"
echo "App NAME: $app_name"
echo "App UID: $app_uid"
echo "App GUID: $app_guid"
echo "AWSHelper Path: $AWSHelper"

if [ -z "$app_uid" ]; then 
	echo "app_uid parameter was not present, can't execute this script."
	exit 1
fi

if [ "$app_type" = public ] ; then
	echo "### Destruction of Public Resources initiated..."
	is_public="true"
elif [ "$app_type" = private ] ; then
	echo "### Destruction of Private Resources initiated..."
	is_public="false"
else
	echo "Invalid app_type parameter, must be either public or private, but was: $app_type"
	exit 1
fi

AWSHelper fargate destroy-resources \
 --name=$app_guid \
 --cname=$cname \
 --zone-public=$zone_public \
 --zone-private=$zone_private \
 --public=$is_public \
 --storage-key-default-s3=$storage_key_default_s3 \
 --storage-key-internal-s3=$storage_key_internal_s3 \

echo "App Destruction: $app_guid ($app_type) FINISHED"