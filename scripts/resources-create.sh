#!/bin/sh
set -e

source "$PWD/scripts/modules/args-parser.sh"

if [ -z "$private_service" ]; then private_service="false" ; fi;
if [ -z "$s3_bucket" ]; then s3_bucket="app-cluster" ; fi;
if [ -z "$app_guid" ]; then app_guid="$app_uid-$app_name" ; fi;
if [ -z "$cname" ]; then cname="$app_guid.$app_type" ; fi;
if [ -z "$app_port" ]; then app_port=7000 ; fi;
if [ -z "$app_ports" ]; then app_ports="9000,8000,7000,3000,443,80,22" ; fi;
if [ -z "$health_check_path" ]; then health_check_path="/api/test/ping" ; fi;
if [ -z "$zone_public" ]; then zone_public="Z138SETQFBIP49" ; fi;
if [ -z "$zone_private" ]; then zone_private="ZY88ADO4BH74B" ; fi;
if [ -z "$subnets_public" ]; then subnets_public="subnet-6ec8c80a,subnet-c12fc38b" ; fi;
if [ -z "$subnets_private" ]; then subnets_private="subnet-28ecda17,subnet-7ff9dc50" ; fi;
if [ -z "$security_groups" ]; then security_groups="sg-924381e4" ; fi;
if [ -z "$vpc" ]; then vpc="vpc-898322f2" ; fi;
if [ -z "$image" ]; then image="017964463726.dkr.ecr.us-east-1.amazonaws.com/settle-apps:$app_guid" ; fi;
if [ -z "$region" ]; then region="us-east-1" ; fi;
if [ -z "$dns_ttl" ]; then dns_ttl=10 ; fi;
if [ -z "$dns_resolve_timeout" ]; then dns_resolve_timeout=600000 ; fi;
if [ -z "$dns_update_delay" ]; then dns_update_delay=60000 ; fi;
if [ -z "$chealth_check_timeout" ]; then chealth_check_timeout=300 ; fi;
if [ -z "$execution_policy" ]; then execution_policy="AmazonECSTaskExecutionRolePolicy" ; fi;
if [ -z "$cpu" ]; then cpu=256 ; fi;
if [ -z "$memory" ]; then memory=512 ; fi;
if [ -z "$desired_count" ]; then desired_count=1 ; fi;
if [ -z "$storage_key_default_s3" ]; then storage_key_default_s3="app-cluster-default" ; fi;
if [ -z "$storage_key_internal_s3" ]; then storage_key_internal_s3="app-cluster-demo" ; fi;
if [ -z "$role_create_delay_ms" ]; then role_create_delay_ms=30000 ; fi;
if [ -z "$paths_s3" ]; then paths_s3="$s3_bucket/$app_uid/$app_type/*,$s3_bucket/$app_uid/$app_name/*" ; fi;
if [ -z "$permissions_s3" ]; then permissions_s3="Read,Write,Delete" ; fi;
if [ -z "$resource_create_timeout" ]; then resource_create_timeout=1200 ; fi;

if [ "$app_type" = "public" ] ; then
	subnets=$subnets_public
	is_public="true"
fi

if [ "$app_type" = "private" ] ; then
	subnets=$subnets_private
	is_public="false"
	paths_s3="$paths_s3,$s3_bucket/$app_uid/public/*"
fi

domain_name="$app_type.settle.host"

echo "Resource Create Script Started..."
echo "PWD: $PWD"
echo "App Name: $app_name"
echo "App UID: $app_uid"
echo "App Type: $app_type"
echo "Is Public: $is_public"
echo "S3 Access Paths: $paths_s3"

echo "Creating Fargate Resources..."
AWSHelper fargate create-resources \
	--name=$app_guid \
	--cname=$cname \
	--region=$region \
	--image=$image \
	--dns-resolve-timeout=$dns_resolve_timeout \
	--dns-update-delay=$dns_update_delay \
	--chealth-check-timeout=$chealth_check_timeout \
	--zone-public=$zone_public \
	--zone-private=$zone_private \
	--subnets=$subnets \
	--security-groups=$security_groups \
	--execution-policy=$execution_policy \
	--cpu=$cpu \
	--memory=$memory \
	--desired-count=$desired_count \
	--public=$is_public \
	--port=$app_port \
	--ports=$app_ports \
	--vpc=$vpc \
	--health-check-path=$health_check_path \
	--storage-key-default-s3=$storage_key_default_s3 \
	--storage-key-internal-s3=$storage_key_internal_s3 \
	--role-create-delay-ms=$role_create_delay_ms \
	--paths-s3=$paths_s3 \
	--permissions-s3=$permissions_s3 \
	--resource-create-timeout=$resource_create_timeout \
	--certificate-domain-name="*.$domain_name" \
	--environment="APP_NAME:$app_name,APP_UID:$app_uid,APP_GUID:$app_guid,APP_TYPE:$app_type,APP_CPU:$cpu,APP_MEMORY:$memory,APP_STORAGE_KEY:$storage_key_internal_s3,APP_DOMAIN:$domain_name,APP_PORT:$app_port"

echo "Testing $app_type service HTTP access..."
CDHelper curl GET --uri="http://${app_guid}.${domain_name}:${app_port}${health_check_path}" --timeout="600000" --intensity="2000"

echo "Testing $app_type service HTTPS access..."
CDHelper curl GET --uri="https://${app_guid}.${domain_name}${health_check_path}" --timeout="600000" --intensity="2000"

echo "Resource Creation Script Finished Running!"