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
 
export Org1=MMS
export Org2=TLABS
export Org3=TSA

cd generated-orgs/

if [ "$1" == "bootstrap" ]; then

##### Bootstrap all ordering orgs

# Executable permissions to scripts

	chmod +x ${Org1}/fabric-network.sh
	chmod +x ${Org2}/fabric-network.sh
	chmod +x ${Org3}/fabric-network.sh

## Start Organization 1

	cd ${Org1}

	./fabric-network.sh generate-crypto
	./fabric-network.sh up

  	sleep 30
## Start Organization 2

	cp -rf fabric-orderer-ca ../${Org2}
	cd .. && cd ${Org2}

	./fabric-network.sh generate-crypto 

	# Add Organization 2 base orderer's configuration and generate genesis file
	cp -rf channel-artifacts/orderer10.crt ../${Org1}/channel-artifacts
	cd .. && cd ${Org1}

	./fabric-network.sh add-remote-orderer 10

	# Up ${Org2} containers
	cp -rf channel-artifacts/orderer_genesis.pb ../${Org2}/channel-artifacts/
	cd .. && cd ${Org2}

	./fabric-network.sh up 
  	sleep 10

	# Publish ${Org2} Orderers into system channel so that all peers may contact them 
	cd .. && cd ${Org1}

	./fabric-network.sh publish-remote-orderer 10

## Start Organization 3

	cp -rf fabric-orderer-ca ../${Org3}
	cd .. && cd ${Org3}

	./fabric-network.sh generate-crypto

	 #Add Organization 3 base orderer's configuration and generate genesis file
	cp -rf channel-artifacts/orderer20.crt ../${Org2}/channel-artifacts
	cd .. && cd ${Org2}

	./fabric-network.sh add-remote-orderer 20

	 #Up ${Org3} containers
	cp -rf channel-artifacts/orderer_genesis.pb ../${Org3}/channel-artifacts/
	cd .. && cd ${Org3}

	./fabric-network.sh up 
  	sleep 10

	 #Publish ${Org3} Orderers into system channel so that all peers may contact them 
	cd .. && cd ${Org2}

	./fabric-network.sh publish-remote-orderer 20

fi

if [ "$1" == "create-join-channel" ]; then

 if [ "$2" == "channelall" ]; then

##### Channel Creation & Joining

## ${Org1}
	# Channel Created and automatically joined by ${Org1}
	cd ${Org1}
	./fabric-network.sh create-channel ChannelAll channelall

## ${Org2}
	# ${Org2} copies its configuration file in ${Org1}'s channel-artifacts folder so that it can add its configuration in ledger
	cd .. && cd ${Org2}

	cp channel-artifacts/${Org2}.json ../${Org1}/channel-artifacts/

	# ${Org1} adds ${Org2}'s configuration in network
	cd .. && cd ${Org1}
	
	./fabric-network.sh add-org-config channelall ${Org2}

	./fabric-network.sh add-org-sign channelall ${Org2}

	# ${Org1} copies ./channel-artifacts/channelall.block in ${Org2}'s channel-artifacts
	cp channel-artifacts/channelall.block ../${Org2}/channel-artifacts/

	# ${Org2} joins channel using channelall.block file
	cd .. && cd ${Org2}
	./fabric-network.sh join-channel-peer 0 channelall

## ${Org3}
	# ${Org3} copies its configuration file in ${Org2}'s channel-artifacts folder so that it can add its configuration in ledger
	cd .. && cd ${Org3}
	cp channel-artifacts/${Org3}.json ../${Org2}/channel-artifacts/

	# ${Org2} adds ${Org3}'s configuration in network
	cd .. && cd ${Org2}
	
	./fabric-network.sh add-org-config channelall ${Org3}

	# ${Org2} signs the ${Org3}'s description and copies ${Org3} blockfile in ${Org1}'s channel-artifacts so that it can sign and publish ${Org3} in channel
	 cp channel-artifacts/${Org3}_update_in_envelope.pb ../${Org1}/channel-artifacts/

	# ${Org1} signs the blockfile, publishes it in network and generates channelall.block file so that ${Org3} can join it
	cd .. && cd ${Org1}
	./fabric-network.sh add-org-sign channelall ${Org3}
	cp channel-artifacts/channelall.block ../${Org3}/channel-artifacts/
	
	# ${Org2} joins channel using channelall.block file
	cd .. && cd ${Org3}
	./fabric-network.sh join-channel-peer 0 channelall
 fi
if [ "$2" == "channelall2" ]; then

##### Channel Creation & Joining

## ${Org2}
	# Channel Created and automatically joined by ${Org2}
	cd ${Org2}
	./fabric-network.sh create-channel ChannelAll2 channelall2

## ${Org1}
	# ${Org1} copies its configuration file in ${Org2}'s channel-artifacts folder so that it can add its configuration in ledger
	cd .. && cd ${Org1}
	cp channel-artifacts/${Org1}.json ../${Org2}/channel-artifacts/

	# ${Org2} adds ${Org1}'s configuration in network
	cd .. && cd ${Org2}
	./fabric-network.sh add-org-config channelall2 ${Org1}
	./fabric-network.sh add-org-sign channelall2 ${Org1}

	# ${Org2} copies ./channel-artifacts/channelall2.block in ${Org1}'s channel-artifacts
	cp channel-artifacts/channelall2.block ../${Org1}/channel-artifacts/

	# ${Org1} joins channel using channelall2.block file
	cd .. && cd ${Org1}
	./fabric-network.sh join-channel-peer 0 channelall2

## ${Org3}
	# ${Org3} copies its configuration file in ${Org1}'s channel-artifacts folder so that it can add its configuration in ledger
	cd .. && cd ${Org3}
	cp channel-artifacts/${Org3}.json ../${Org1}/channel-artifacts/

	# ${Org1} adds ${Org3}'s configuration in network
	cd .. && cd ${Org1}
	./fabric-network.sh add-org-config channelall2 ${Org3}

	# ${Org1} signs the ${Org3}'s description and copies ${Org3} blockfile in ${Org2}'s channel-artifacts so that it can sign and publish ${Org3} in channel
	 cp channel-artifacts/${Org3}_update_in_envelope.pb ../${Org2}/channel-artifacts/

	# ${Org2} signs the blockfile, publishes it in network and generates channelall2.block file so that ${Org3} can join it
	cd .. && cd ${Org2}
	./fabric-network.sh add-org-sign channelall2 ${Org3}
	cp channel-artifacts/channelall2.block ../${Org3}/channel-artifacts/
	
	# ${Org2} joins channel using channelall2.block file
	cd .. && cd ${Org3}
	./fabric-network.sh join-channel-peer 0 channelall2
 fi
if [ "$2" == "channelallany" ]; then

##### Channel Creation & Joining

## ${Org1}
	# Channel Created and automatically joined by ${Org1}
	cd ${Org1}
	./fabric-network.sh create-channel ChannelAllANY channelallany
echo "${Org1} done"

## ${Org2}
	# ${Org2} copies its configuration file in ${Org1}'s channel-artifacts folder so that it can add its configuration in ledger
	cd .. && cd ${Org2}
	cp channel-artifacts/${Org2}.json ../${Org1}/channel-artifacts/

	# ${Org1} adds ${Org2}'s configuration in network
	cd .. && cd ${Org1}
	./fabric-network.sh add-org-config channelallany ${Org2}
	./fabric-network.sh add-org-sign channelallany ${Org2}

	# ${Org1} copies ./channel-artifacts/channelallany.block in ${Org2}'s channel-artifacts
	cp channel-artifacts/channelallany.block ../${Org2}/channel-artifacts/

	# ${Org2} joins channel using channelallany.block file
	cd .. && cd ${Org2}
	./fabric-network.sh join-channel-peer 0 channelallany
echo "${Org2} done"

## ${Org3}
	# ${Org3} copies its configuration file in ${Org1}'s channel-artifacts folder so that it can add its configuration in ledger
	cd .. && cd ${Org3}
	cp channel-artifacts/${Org3}.json ../${Org1}/channel-artifacts/

	# ${Org1} adds ${Org3}'s configuration in network
	cd .. && cd ${Org1}
	./fabric-network.sh add-org-config channelallany ${Org3}
	./fabric-network.sh add-org-sign channelallany ${Org3}

	# ${Org1} copies ./channel-artifacts/channelallany.block in ${Org3}'s channel-artifacts
	cp channel-artifacts/channelallany.block ../${Org3}/channel-artifacts/
	
	# ${Org3} joins channel using channelallany.block file
	cd .. && cd ${Org3}
	./fabric-network.sh join-channel-peer 0 channelallany
echo "${Org3} done"

 fi

fi
if [ "$1" == "start-explorer" ]; then
	cd ${Org1}
	./fabric-network.sh bootstrap-explorer "$2"
#	<docker extext to attach host port>
	cd .. && cd ${Org2}
	./fabric-network.sh bootstrap-explorer "$2"
#	<docker extext to attach host port>
	cd .. && cd ${Org3}
	./fabric-network.sh bootstrap-explorer "$2"
#	<docker extext to attach host port>
fi

if [ "$1" == "stop-explorer" ]; then
	cd ${Org1}
	./fabric-network.sh explorer-down
	cd .. && cd ${Org2}
	./fabric-network.sh explorer-down
	cd .. && cd ${Org3}
	./fabric-network.sh explorer-down
fi

if [ "$1" == "down" ]; then

##### Down all containers, cleanup and restore initial state

## ${Org1}
	cd ${Org1}
	./fabric-network.sh down cleanup restore
## ${Org2}
	cd .. && cd ${Org2}
	./fabric-network.sh down cleanup restore
## ${Org3}
	cd .. && cd ${Org3}
	./fabric-network.sh down cleanup restore

fi








