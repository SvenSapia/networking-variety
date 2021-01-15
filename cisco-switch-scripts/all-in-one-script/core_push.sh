#!/bin/bash
clear

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

# Parse config.json
default_username=$(cat './config.json' | jq -r '.default.username')
default_sshkey=$(cat './config.json' | jq -r '.default.sshkey')

authentication_publickey_enable=$(cat './config.json' | jq -r '.authentication.publickey.enable')
authentication_publickey_filepath=$(cat './config.json' | jq -r '.authentication.publickey.filepath')
authentication_publickey_fallbackpassword=$(cat './config.json' | jq -r '.authentication.publickey.fallbackpassword')
authentication_enablepassword=$(cat './config.json' | jq -r '.authentication.enablepassword')


################################################################
##### Select switch family and model
### Family
echo "Select switch family."
echo "########## available families"
cat './config.json' | jq -r '.switch | keys[]'
echo "########## available families"
read -p "Value: " switchfamily 
printf "\n\n\n"

### Model
echo "Select switch model."
echo "########## available models"
cat './config.json' | jq -r '.switch.'$switchfamily' | keys[]'
echo "########## available models"
read -p "Value: " switchmodel
printf "\n\n\n"

### Show IPs
echo "IPs to connect:"
readarray -t switchlistRaw <<< "$(cat './config.json' | jq -r '.switch.'$switchfamily'.'$switchmodel.ips' | values[]')"
#Validate IP-Adress
for switchRaw in ${switchlistRaw[*]};
do
	if ipvalid $switchRaw; then
		switchlist+=( "$switchRaw" )
	fi
done
echo ${switchlist[*]}
printf "\n\n\n"

################################################################
##### Select commands
###
echo "Select command."
echo "########## available commands"

for k in $(jq -r ".cmdlib | keys | .[] " ./config.json); do
        echo $k " - " $(jq -r ".cmdlib.$k.descr" ./config.json)
done

echo "########## available commands"
read -p "Value: " cmd
printf "\n\n\n"

### Read commands from json, parse to array and echo out
echo "Commands to execute:"
counter=0
selectedcmd=".cmdlib."$cmd".cmds"
for k in $(jq -r "$selectedcmd | keys | .[] " ./config.json); do
	if [[ $k == "cmd"*"line" ]]; then
		cmdlist[$counter]=$(jq -r "$selectedcmd.$k" ./config.json)
		counter=$[$counter+1]
	elif [[ $k == "cmd"*"beginvar"* ]]; then
		if [[ $k == "cmd"*"parse" ]]; then
			parse=$(jq -r "$selectedcmd.$k" ./config.json)
			cmdlist[$counter]=$(jq -r "$parse" ./config.json)
		else
        		cmdlist[$counter]=$(jq -r "$selectedcmd.$k" ./config.json)
		fi
	elif [[ $k == "cmd"*"midvar"* ]]; then
		if [[ $k == "cmd"*"parse" ]]; then
                        parse=$(jq -r "$selectedcmd.$k" ./config.json)
                        attach=$(jq -r "$parse" ./config.json)
                else
                        attach=$(jq -r "$selectedcmd.$k" ./config.json)
                fi
		cmdlist[$counter]+=$attach
        elif [[ $k == "cmd"*"endvar"* ]]; then
		if [[ $k == "cmd"*"parse" ]]; then
                        parse=$(jq -r "$selectedcmd.$k" ./config.json)
                        attach=$(jq -r "$parse" ./config.json)
		else
			attach=$(jq -r "$selectedcmd.$k" ./config.json)
		fi
		cmdlist[$counter]+=$attach
		counter=$[$counter+1]
	fi
done

printf '%s\n' "${cmdlist[@]}"
printf "\n\n\n"


################################################################
###### Collect username, ssh, & enable passwords
### Username
read -p "Enter username (default: $default_username): " user
user=${user:-$default_username}

### Publickey, if publickey auth is enabled
if [ $authentication_publickey_enable = "true" ]
then
	read -p "Enter SSH key filepath (default: $default_sshkey): " sshkey
	sshkey=${sshkey:-$default_sshkey}
fi

### SSH-Password if publickey is disabled or fallbackpassword enabled
if [ $authentication_publickey_enable = "false" ] || ([ $authentication_publickey_enable = "true" ] && [ $authentication_publickey_fallbackpassword = "true" ])
then
	printf "Enter SSH password: "
	read -s -e password
fi

### Enable-Password if enabled
if [ $authentication_enablepassword = "true" ]
then
	printf "Enter enable password: "
	read -s -e enablepwd
fi
################################################################

# Set default values, to pass strings correctly and do not mess up expect array
defaultargv="unknown"
switch=${switch:-$defaultargv}
user=${user:-$defaultargv}
password=${password:-$defaultargv}
enablepwd=${enablepwd:-$defaultargv}
sshkey=${sshkey:-$defaultargv}

# Open device list & send the collected information to expect script
for switch in ${switchlist[*]}; 
do
	./expectpush.sh $switch $user $password $enablepwd $sshkey "${cmdlist[@]}";
done
printf "\n\n\n"
