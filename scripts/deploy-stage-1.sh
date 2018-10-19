#!/bin/bash
set -e

echo "#############################"
echo "# DEPLOYMENT PART 1 - START #"
echo "#############################"

echo "Docker-Push Script Started Running..."
source "$PWD/scripts/modules/args-parser.sh"

if [ -z "$app_uid" ]; then 
	echo "app_uid parameter was not present, can't execute this script and create docker images."
	exit 1
fi

echo "### Initiation Scripts Execution..."
$PWD/Sources/Scripts/settle-apps-initialize.sh || { echo 'Failed One Time Initialization Step'; exit 1; }
$PWD/scripts/modules/batch-execute.sh --target_file_pattern "*settle-app-initialize.*.sh" || { echo 'Failed Batch Initialization Step'; exit 1; }

echo "### Build Scripts Execution..."
$PWD/Sources/Scripts/settle-apps-build.sh || { echo 'Failed One Time Build Step'; exit 1; }
$PWD/scripts/modules/batch-execute.sh --target_file_pattern "*settle-app-build.*.sh" || { echo 'Failed Batch Build Step'; exit 1; }

echo "### Publish Scripts Execution..."
$PWD/Sources/Scripts/settle-apps-publish.sh || { echo 'Failed One Time Publish Step'; exit 1; }
$PWD/scripts/modules/batch-execute.sh --target_file_pattern "*settle-app-publish.*.sh" || { echo 'Failed Batch Publish Step'; exit 1; }

echo "### Test Scripts Execution..."
$PWD/Sources/Scripts/settle-apps-test.sh || { echo 'Failed One Time Test Execution Step'; exit 1; }
$PWD/scripts/modules/batch-execute.sh --target_file_pattern "*settle-app-test.*.sh" || { echo 'Failed Batch Test Execution Step'; exit 1; }

echo "### Creating docker images..."
$PWD/scripts/docker-stage-1.sh --app_uid $app_uid --src_dir "$PWD/Sources" --repo_name $repo_name || { echo 'Failed Docker Image Creation'; exit 1; }

echo "#############################"
echo "# DEPLOYMENT PART 1 - STOP  #"
echo "#############################"
