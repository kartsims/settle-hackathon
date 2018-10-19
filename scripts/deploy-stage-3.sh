#!/bin/bash
set -e
 
echo "#############################"
echo "# DEPLOYMENT PART 3 - START #"
echo "#############################"
 
echo "### Test Scripts Execution..."
$PWD/Sources/Scripts/settle-apps-integration-test.sh || { echo 'Failed One Time Integration Test Execution Step'; exit 1; }
$PWD/scripts/modules/batch-execute.sh --target_file_pattern "*settle-app-integration-test.*.sh" || { echo 'Failed Batch Integration Test Execution Step'; exit 1; }

echo "#############################"
echo "# DEPLOYMENT PART 3 - STOP  #"
echo "#############################"