#!/bin/bash

# Snippet found at https://stackoverflow.com/questions/13777387/check-for-ip-validity
ipvalid() {
	# Set up local variables
	local ip=${1:-1.2.3.4}
	local IFS=.; local -a a=($ip)
	# Start with a regex format test
	[[ $ip =~ ^[0-9]+(\.[0-9]+){3}$ ]] || return 1
	# Test values of quads
	local quad
	for quad in {0..3}; do
		[[ "${a[$quad]}" -gt 255 ]] && return 1
	done
	return 0
}

# Set colors for echo output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

#Read all families from json file
readarray -t familylist <<< "$(cat './config.json' | jq -r '.switch | keys[]')"
#Loop through families
for family in ${familylist[*]};
do
	#Read all models
	readarray -t modellist <<< "$(cat './config.json' | jq -r '.switch.'$family' | keys[]')"
	#Loop through models
	for model in ${modellist[*]};
	do
		#Read all switch ids (letters)
		#WORK IN PROGRESS readarray -t switchid <<< "$(cat './config.json' | jq -r '.switch.'$family'.'$model.ips' | keys[]')"

		#WORKINPROGRESS readarray -t switchid <<< "$(cat './config.json' | jq -r '.switch.'$family'.'$model.ips' | keys[]')"
		#WORKINPROGRESSi=0
		
		#Read all ips
		readarray -t switchlistRaw <<< "$(cat './config.json' | jq -r '.switch.'$family'.'$model.ips' | values[]')"
		for switchRaw in ${switchlistRaw[*]};
		do	
			#Check with functon if ip is valid
			if ipvalid $switchRaw; then
				#Check if switch is online
				if ping -w1 -c1 $switchRaw 1>/dev/null 2>/dev/null  ; then
					echo -e $switchRaw $model ${switchid[$i]} "${GREEN}Ping OK${NC}"
				else
					echo -e $switchRaw $model ${switchid[$i]} "${RED}Down${NC}"
				fi
				#WORKINPROGESS((i++))
			fi
		done
	done
done

