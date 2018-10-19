echo "*** Args-parser START ***"

declare -a illegal_declare_chars=("-" "/" "\\" "*" "$" "%" "#" "@" "'" "^" "(" ")" " ")

while [ $# -gt 0 ]; do
	if [[ $1 == "--"* ]]; then
	
		key="${1/--/}"
		
		if [ -z "$key" ]; then
			echo "Argument '$1' can't be declared, because it parses into empty key."
			break
		fi

		legal=true
		for i in "${illegal_declare_chars[@]}" ; do
			if [[ $key = *"$i"* ]]; then
				echo "Key '$key' can't be declared because it contains illegal caracher '$i'"
				legal=false
				break
			fi
		done
		
		if [ "$legal" = false ] ; then #key contains illegal char, can't declare
			break
		else
			echo "Declaring Key: '$key', Value: '$2'"
			declare $key="$2"
		fi 
	fi
	shift
done

echo "*** Args-parser END ***"