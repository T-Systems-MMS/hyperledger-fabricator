#!/bin/bash

# Copyright 2021 T-Systems MMS

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# This is a demo chaincode deployment script that would be used with jenkins
# In this example Organization 1 will be the one to commit the chaincode
# It auto-increments the chaincode version and seq number 
# domain should be changed as per real orgs


export org_committer="$1"
export org_name="$2"
export channel_name="$3"
export version="$4"
export sequence="$5"
export domain="$6"
export script_path="$7" 
export label=1
export chaincode_name="fabcar"
export output_type="json"
echo "Deploying on channel: ${channel_name}"


if [ ${org_name,,} == ${org_committer,,} ]; then 
	echo 'I was the one who committed the chaincode'
else
	echo "$1"
fi


#cd generated-orgs
cd $script_path/generated-orgs

#first check if the fabric network is up and running
export container_name="cli.${org_name,,}.${domain,,}"
echo "Going to exec into container: ${container_name}"

result=$(docker inspect -f '{{.State.Running}}' ${container_name})
echo "Are the required containers up and running?: $result"

if [ $result == "true" ]; then
	cd ${org_name}
        #echo "Required containers are up and running"
	#package chaincode
	bash fabric-network.sh package-cc fabcar golang ${label}
	echo "Chaincode is packaged"	
	
	#install chaincode 
	bash fabric-network.sh install-cc fabcar
	echo "Chaincode is installed"

	#query chaincode installation
	bash fabric-network.sh query-installed-cc ${org_name}>&install-log-${org_name}.txt
	echo "Querying chaincode installation"
	PACKAGE_ID=$(cat install-log-${org_name}.txt | awk "/Package ID: /{print}" | sed -n 's/^Package ID: //; s/, Label:.*$//;p')
	echo "Package id is: " $PACKAGE_ID

	#approve chaincode
	echo "Approving chaincode"		
	bash fabric-network.sh approve-cc ${channel_name} ${chaincode_name} ${version} $PACKAGE_ID ${sequence}
        
	#check if I was the one who committed chaincode
	if [ ${org_name,,}  == ${org_committer,,} ]; then
	
		#check commit readiness
		echo "I pushed the chaincode, so I will be the one to commit it"
		i=0;
		while true; 
			do
			i=$((i+1))
			echo "Checking approvals gathered. Iteration # ${i}" 
			bash fabric-network.sh checkcommitreadiness-cc ${channel_name} ${chaincode_name} ${version} ${sequence} ${output_type} > approval-check.json
			approvalCheck="`grep false approval-check.json`" 
			echo $approvalCheck			
			if [ -z "$approvalCheck" ]; then
			echo "all approvals are true"
			break
			else
			sleep 30;
			fi
			done

		#commit chaincode - only org that pushed the chaincode will commit it
		echo "Trying to commit chaincode"
		bash fabric-network.sh commit-cc ${channel_name} ${chaincode_name} ${version} ${sequence} 

		#query committed code
		echo "Query committed chaincode"
		bash fabric-network.sh query-committed-cc ${channel_name}
		#initialize chaincode - only org1 will do it
		echo "Initializing chaincode"
		bash fabric-network.sh init-cc ${channel_name} ${chaincode_name} 
	else 
		
		echo "I did not push the chaincode, so someone else will commit it"
		 i=0;
		 while true;
		 	do
			i=$((i+1))	
			echo "Query committed chaincode iteration # ${i}"
			bash fabric-network.sh query-committed-cc ${channel_name} | sed -n '3p' > commit-check.txt
			updated_version=$(sed -rn 's/.*(Version: ([[:digit:]]),).*/\2/p' commit-check.txt) 
			updated_sequence=$(sed -rn 's/.*(Sequence: ([[:digit:]]),).*/\2/p' commit-check.txt)
			#echo $version
			#echo $sequence
			#echo $updated_version
			#echo $updated_sequence
			if [ "$version" != "$updated_version" ] && [ "$sequence" != "$updated_sequence" ]; then
			echo "Committed chaincode version and sequence has been updated"
			break
			else 
			sleep 60;
			fi
			done
		
	fi

else 
        echo "Required fabric network containers are not running on the machine"
        echo "Chaincode cannot be deployed"
fi
