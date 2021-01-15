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


readarray -t familylist <<< "$(cat './config.json' | jq -r '.switch | keys[]')"
for family in ${familylist[*]};
do
	readarray -t modellist <<< "$(cat './config.json' | jq -r '.switch.'$family' | keys[]')"
	
	for model in ${modellist[*]};
	do
		readarray -t switchid <<< "$(cat './config.json' | jq -r '.switch.'$family'.'$model.ips' | keys[]')"
		readarray -t switchlistRaw <<< "$(cat './config.json' | jq -r '.switch.'$family'.'$model.ips' | values[]')"
		for switchRaw in ${switchlistRaw[*]};
		do
			if ipvalid $switchRaw; then
				switchlist+=( "$model" "$switchid" "$switchRaw" )
			fi
		done
	done
done

echo ${switchlist[*]}
