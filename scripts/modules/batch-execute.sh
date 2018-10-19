#!/bin/bash
set -e

#NOTE: this script should be executed from the root of the repository

script_path="$(realpath -s $0)"
script_directory="$(dirname "$script_path")"

source "$PWD/scripts/modules/args-parser.sh"

if [ -z "$target_file_pattern" ]; then 
	echo "Target File Pattern parameter 'target_file_pattern' was not specified"
	exit 1
fi

echo "Targetted Script Execution Initiated"
echo "Working Directory: $PWD"
echo "Script Path: $script_path"
echo "Script Directory: $script_directory"
echo "Target Pattern: target_file_pattern"

OIFS="$IFS"
IFS=$'\n'
files=$(find "$PWD/Sources" -type f -name "$target_file_pattern")
for f in $files; do
	f=${f#"$PWD/"} #removing path prefix - for windows compatibility
	echo "Found Target Execution File '$f' executing...";

	if [[ "$f" = *".parallel."* ]]; then
		echo "Found Parallelizable Target Execution File '$f' executing...";
		sh "./$f" &
	elif [[ "$f" = *".series."* ]]; then
		echo "Found NONE Parallelizable Target Execution File '$f' executing...";
		sh "./$f"
	else
		echo "FAILURE, Target Execution File Names must be contain either .parallel or .series. suffix.";
		exit 1
	fi
	
done
IFS="$OIFS"

source "$PWD/scripts/modules/jobs-await.sh"

echo "Targetted Script Execution Finished"