#Use example: source ./scripts/modules/jobs-await.sh

echo "Job Await Macro Started"

JOB_AWAIT_FAIL_COUNTER=0
ALL_JOBS=$(jobs -p)

for job in $ALL_JOBS ; do
	echo "Awaiting Job: $job"
	wait $job || let "JOB_AWAIT_FAIL_COUNTER+=1"
done

if [ "$JOB_AWAIT_FAIL_COUNTER" == "0" ]; then
	echo "All Jobs Finished Successfully"
else
	echo "$JOB_AWAIT_FAIL_COUNTER Jobs Failed"
	exit 1
fi

echo "Job Await Macro Ended"