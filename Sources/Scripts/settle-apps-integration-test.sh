#!/bin/bash
set -e

#NOTE: this script should be executed from the root of the repository

script_path="$(realpath -s $0)"
script_directory="$(dirname "$script_path")"


echo "Integration Test Script Initiated"
echo "Working Directory: $PWD"
echo "Script Path: $script_path"
echo "Script Directory: $script_directory"

source "$PWD/scripts/modules/args-parser.sh"

echo "ONE TIME EXECUTED POST-DEPLOYMENT SCRIPT"