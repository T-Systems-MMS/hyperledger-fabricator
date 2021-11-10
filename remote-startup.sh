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

export Org1Path=~/blockchain-common-fabric-net/generated-orgs
export Org2Path=~/blockchain-common-fabric-net/generated-orgs
export Org3Path=~/blockchain-common-fabric-net/generated-orgs

export Org2SSHAddress=mujtaba@192.168.109.142
export Org3SSHAddress=mujtaba@192.168.109.131

#export Org2SSHAddress=fabric@192.168.57.66
#export Org3SSHAddress=fabric@192.168.58.122

cd $Org1Path

if [ "$1" == "bootstrap" ]; then

##### Bootstrap all ordering orgs

# Executable permissions to scripts

	chmod +x ${Org1Path}/${Org1}/fabric-network.sh
	ssh  ${Org2SSHAddress} "chmod +x ${Org2Path}/${Org2}/fabric-network.sh"
	ssh  ${Org3SSHAddress} "chmod +x ${Org3Path}/${Org3}/fabric-network.sh"


## Start Organization 1

	cd ${Org1}

	./fabric-network.sh generate-crypto
	./fabric-network.sh up

  	 sleep 30
## Start Organization 2
	scp -r channel-artifacts/OrdererSharedCerts ${Org2SSHAddress}:${Org2Path}/${Org2}
	ssh  ${Org2SSHAddress} "cd ${Org2Path}/${Org2} && ./fabric-network.sh generate-crypto"

	# Add Organization 2 base orderer's configuration and generate genesis file
	scp ${Org2SSHAddress}:${Org2Path}/${Org2}/channel-artifacts/orderer10.crt channel-artifacts/
	./fabric-network.sh add-remote-orderer 10

	# Up ${Org2} containers
	scp channel-artifacts/orderer_genesis.pb ${Org2SSHAddress}:${Org2Path}/${Org2}/channel-artifacts/
	ssh  ${Org2SSHAddress} "cd ${Org2Path}/${Org2} && ./fabric-network.sh up"
	sleep 10
	./fabric-network.sh publish-remote-orderer 10
## Start Organization 3
	scp -r channel-artifacts/OrdererSharedCerts ${Org3SSHAddress}:${Org3Path}/${Org3}
	ssh  ${Org3SSHAddress} "cd ${Org3Path}/${Org3} && ./fabric-network.sh generate-crypto"

	# Add Organization 3 base orderer's configuration and generate genesis file
	scp ${Org3SSHAddress}:${Org3Path}/${Org3}/channel-artifacts/orderer20.crt channel-artifacts/
	./fabric-network.sh add-remote-orderer 20

	# Up ${Org3} containers
	scp channel-artifacts/orderer_genesis.pb ${Org3SSHAddress}:${Org3Path}/${Org3}/channel-artifacts/
	ssh  ${Org3SSHAddress} "cd ${Org3Path}/${Org3} && ./fabric-network.sh up"
	sleep 10
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
	scp ${Org2SSHAddress}:${Org2Path}/${Org2}/channel-artifacts/${Org2}.json channel-artifacts/

	# ${Org1} adds ${Org2}'s configuration in network

	./fabric-network.sh add-org-config channelall ${Org2}
	 ./fabric-network.sh add-org-sign channelall ${Org2}

	# ${Org1} copies ./channel-artifacts/channelall.block in ${Org2}'s channel-artifacts
	scp channel-artifacts/channelall.block ${Org2SSHAddress}:${Org2Path}/${Org2}/channel-artifacts/

	# ${Org2} joins channel using channelall.block file
	ssh  ${Org2SSHAddress} "cd ${Org2Path}/${Org2} && ./fabric-network.sh join-channel-peer 0 channelall"
	

## ${Org3}
	# ${Org3} copies its configuration file in ${Org1} and ${Org2}'s channel-artifacts folder so that it can add its configuration in ledger
	scp ${Org3SSHAddress}:${Org3Path}/${Org3}/channel-artifacts/${Org3}.json channel-artifacts/
	scp channel-artifacts/${Org3}.json ${Org2SSHAddress}:${Org2Path}/${Org2}/channel-artifacts/

	# ${Org2} adds ${Org3}'s configuration in network
	ssh ${Org2SSHAddress} "cd ${Org2Path}/${Org2} && ./fabric-network.sh add-org-config channelall ${Org3}"

	# ${Org2} signs the ${Org3}'s description and copies ${Org3} blockfile in ${Org1}'s channel-artifacts so that it can sign and publish ${Org3} in channel
	scp ${Org2SSHAddress}:${Org2Path}/${Org2}/channel-artifacts/${Org3}_update_in_envelope.pb channel-artifacts/
		
	# ${Org1} signs the blockfile, publishes it in network and generates channelall.block file so that ${Org3} can join it
	./fabric-network.sh add-org-sign channelall ${Org3}
	scp channel-artifacts/channelall.block ${Org3SSHAddress}:${Org3Path}/${Org3}/channel-artifacts/
	
	# ${Org2} joins channel using channelall.block file
	ssh  ${Org3SSHAddress} "cd ${Org3Path}/${Org3} && ./fabric-network.sh join-channel-peer 0 channelall"
	
 fi
if [ "$2" == "channelall2" ]; then

##### Channel Creation & Joining
	cd ${Org1}
## ${Org2}
	# Channel Created and automatically joined by ${Org2}
	ssh  ${Org2SSHAddress} "cd ${Org2Path}/${Org2} && ./fabric-network.sh create-channel ChannelAll2 channelall2"
	
## ${Org1}
	# ${Org1} copies its configuration file in ${Org2}'s channel-artifacts folder so that it can add its configuration in ledger

	scp channel-artifacts/${Org1}.json ${Org2SSHAddress}:${Org2Path}/${Org2}/channel-artifacts/

	# ${Org2} adds ${Org1}'s configuration in network
	ssh  ${Org2SSHAddress} "cd ${Org2Path}/${Org2} && ./fabric-network.sh add-org-config channelall2 ${Org1} && ./fabric-network.sh add-org-sign channelall2 ${Org1}"

	# ${Org2} copies ./channel-artifacts/channelall2.block in ${Org1}'s channel-artifacts
	scp ${Org2SSHAddress}:${Org2Path}/${Org2}/channel-artifacts/channelall2.block channel-artifacts/

	# ${Org1} joins channel using channelall2.block file
	./fabric-network.sh join-channel-peer 0 channelall2

## ${Org3}
	# ${Org3} copies its configuration file in ${Org1}'s channel-artifacts folder so that it can add its configuration in ledger
	scp ${Org3SSHAddress}:${Org3Path}/${Org3}/channel-artifacts/${Org3}.json channel-artifacts/

	# ${Org1} adds ${Org3}'s configuration in network
	./fabric-network.sh add-org-config channelall2 ${Org3}

	# ${Org1} signs the ${Org3}'s description and copies ${Org3} blockfile in ${Org2}'s channel-artifacts so that it can sign and publish ${Org3} in channel

	scp channel-artifacts/${Org3}_update_in_envelope.pb ${Org2SSHAddress}:${Org2Path}/${Org2}/channel-artifacts/

	# ${Org2} signs the blockfile, publishes it in network and generates channelall2.block file so that ${Org3} can join it
	ssh  ${Org2SSHAddress} "cd ${Org2Path}/${Org2} && ./fabric-network.sh add-org-sign channelall2 ${Org3}"
	
	scp ${Org2SSHAddress}:${Org2Path}/${Org2}/channel-artifacts/channelall2.block channel-artifacts/
	scp channel-artifacts/channelall2.block ${Org3SSHAddress}:${Org3Path}/${Org3}/channel-artifacts/
	
	# ${Org3} joins channel using channelall2.block file
	ssh  ${Org3SSHAddress} "cd ${Org3Path}/${Org3} && ./fabric-network.sh join-channel-peer 0 channelall2"
	
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

	scp ${Org2SSHAddress}:${Org2Path}/${Org2}/channel-artifacts/${Org2}.json channel-artifacts/

	# ${Org1} adds ${Org2}'s configuration in network
	./fabric-network.sh add-org-config channelallany ${Org2}
	./fabric-network.sh add-org-sign channelallany ${Org2}

	# ${Org1} copies ./channel-artifacts/channelallany.block in ${Org2}'s channel-artifacts
	scp channel-artifacts/channelallany.block ${Org2SSHAddress}:${Org2Path}/${Org2}/channel-artifacts/

	# ${Org2} joins channel using channelallany.block file
	ssh  ${Org2SSHAddress} "cd ${Org2Path}/${Org2} && ./fabric-network.sh join-channel-peer 0 channelallany"
	
echo "${Org2} done"

## ${Org3}
	# ${Org3} copies its configuration file in ${Org1}'s channel-artifacts folder so that it can add its configuration in ledger
	scp ${Org3SSHAddress}:${Org3Path}/${Org3}/channel-artifacts/${Org3}.json channel-artifacts/

	# ${Org1} adds ${Org3}'s configuration in network
	./fabric-network.sh add-org-config channelallany ${Org3}
	./fabric-network.sh add-org-sign channelallany ${Org3}

	# ${Org1} copies ./channel-artifacts/channelallany.block in ${Org3}'s channel-artifacts
	scp channel-artifacts/channelallany.block ${Org3SSHAddress}:${Org3Path}/${Org3}/channel-artifacts/
	
	# ${Org3} joins channel using channelallany.block file
	ssh  ${Org3SSHAddress} "cd ${Org3Path}/${Org3} && ./fabric-network.sh join-channel-peer 0 channelallany"
	
echo "${Org3} done"

 fi

fi

if [ "$1" == "start-explorer" ]; then
## ${Org1}
	cd ${Org1}
	./fabric-network.sh bootstrap-explorer "$2"
## ${Org2}
	ssh  ${Org2SSHAddress} "cd ${Org2Path}/${Org2} && ./fabric-network.sh bootstrap-explorer"
	
## ${Org3}
	ssh  ${Org3SSHAddress} "cd ${Org3Path}/${Org3} && ./fabric-network.sh bootstrap-explorer"
fi

if [ "$1" == "stop-explorer" ]; then

## ${Org1}
	cd ${Org1}
	./fabric-network.sh explorer-down
## ${Org2}
	ssh  ${Org2SSHAddress} "cd ${Org2Path}/${Org2} && ./fabric-network.sh explorer-down"
	
## ${Org3}
	ssh  ${Org3SSHAddress} "cd ${Org3Path}/${Org3} && ./fabric-network.sh explorer-down"
	
fi

if [ "$1" == "deploy-demo-chaincode" ]; then
	cd ${Org1}
	./fabric-network.sh package-cc fabcar golang 1
	ssh  ${Org2SSHAddress} "cd ${Org2Path}/${Org2} && ./fabric-network.sh package-cc fabcar golang 1"
	ssh  ${Org3SSHAddress} "cd ${Org3Path}/${Org3} && ./fabric-network.sh package-cc fabcar golang 1"

	./fabric-network.sh install-cc fabcar
	ssh  ${Org2SSHAddress} "cd ${Org2Path}/${Org2} && ./fabric-network.sh install-cc fabcar"
	ssh  ${Org3SSHAddress} "cd ${Org3Path}/${Org3} && ./fabric-network.sh install-cc fabcar"

	./fabric-network.sh approve-cc channelall fabcar 1 1:a413310bd764d0e4bfdbe988646b6081f6fcc80c865abd51a1cbc4b570a5feb2 1 
	ssh  ${Org2SSHAddress} "cd ${Org2Path}/${Org2} && ./fabric-network.sh approve-cc channelall fabcar 1 1:a413310bd764d0e4bfdbe988646b6081f6fcc80c865abd51a1cbc4b570a5feb2 1"
	ssh  ${Org3SSHAddress} "cd ${Org3Path}/${Org3} && ./fabric-network.sh approve-cc channelall fabcar 1 1:a413310bd764d0e4bfdbe988646b6081f6fcc80c865abd51a1cbc4b570a5feb2 1"
	
	./fabric-network.sh commit-cc channelall fabcar 1 1
	./fabric-network.sh init-cc channelall fabcar
	sleep 10
	./fabric-network.sh invoke-function-cc channelall fabcar initLedger
	sleep 10
	./fabric-network.sh query-function-cc channelall fabcar queryAllCars
	./fabric-network.sh invoke-function-cc channelall fabcar changeCarOwner \"CAR9\",\"MMS\"
	sleep 10
	./fabric-network.sh query-function-cc channelall fabcar queryAllCars
fi


if [ "$1" == "down" ]; then

##### Down all containers, cleanup and restore initial state

## ${Org1}
	cd ${Org1}
	./fabric-network.sh down cleanup restore
## ${Org2}
	ssh  ${Org2SSHAddress} "cd ${Org2Path}/${Org2} && ./fabric-network.sh down cleanup restore"
	
## ${Org3}
	ssh  ${Org3SSHAddress} "cd ${Org3Path}/${Org3} && ./fabric-network.sh down cleanup restore"


fi

