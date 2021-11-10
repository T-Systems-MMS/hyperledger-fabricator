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


## Environment variables for future changes in names 

  export Org_Name="$1"
  export Org_MSP="$1"MSP
  export DOMAIN="$2"
  export ORG_NUMBER="$3"
  export ORG_EXPLORER_PORT="$4"	
  export NETWORK_NAME=fabric-template-network


if [ ! "$5" == "" ]; then
  export NETWORK_NAME="$5"
fi

if [ ! -d  generated-orgs/ ]; then
	mkdir generated-orgs
fi

if [ -d  bin/ ]; then
	mv bin generated-orgs/
fi

if [ ! -d  generated-orgs/bin ]; then
	echo "Error: Please install pre-requisites as advised in readme"
	exit
fi

if [ -d  generated-orgs/$Org_Name ]; then
	echo "Error: This Org $Org_Name Already exists"
	exit
fi

  echo ${Org_Name}
  echo ${Org_MSP}
  echo ${DOMAIN}
  echo ${ORG_NUMBER}
  echo ${NETWORK_NAME}
  echo ${ORG_EXPLORER_PORT}
	 

mkdir generated-orgs/$Org_Name
cp -r fabric-template/base generated-orgs/$Org_Name/
cp -r fabric-template/chaincode generated-orgs/$Org_Name/
cp -r fabric-template/scripts generated-orgs/$Org_Name/
cp fabric-template/docker-compose-new-peer.yaml generated-orgs/$Org_Name/docker-compose-new-peer.yaml
cp fabric-template/docker-compose-new-raft-orderer.yaml generated-orgs/$Org_Name/docker-compose-new-raft-orderer.yaml
cp -r fabric-template/connection-profile generated-orgs/$Org_Name/
cp -r fabric-template/docker-compose-explorer.yaml generated-orgs/$Org_Name/
cp -r fabric-template/explorer-config.json generated-orgs/$Org_Name/
cp -r fabric-template/docker-compose-org-ca.yaml generated-orgs/$Org_Name/
cp -r fabric-template/fabric-org-ca generated-orgs/$Org_Name/



if [ "$ORG_NUMBER" == "1" ]; then
	cp -r fabric-template/docker-compose-orderer-ca.yaml generated-orgs/$Org_Name/
	cp -r fabric-template/fabric-orderer-ca generated-orgs/$Org_Name/
	cat fabric-template/fabric-network-first-org.sh > generated-orgs/$Org_Name/fabric-network.sh
	cat fabric-template/configtx-first-org.yaml >  generated-orgs/$Org_Name/initial-configtx.yaml
	cat fabric-template/docker-compose-first-org.yaml > generated-orgs/$Org_Name/docker-compose.yaml
	sed -i -e 's/export Org_Name=Org1/export Org_Name='$Org_Name'/g' generated-orgs/$Org_Name/fabric-network.sh
	sed -i -e 's/export Org_MSP=Org1MSP/export Org_MSP='$Org_MSP'/g' generated-orgs/$Org_Name/fabric-network.sh
	sed -i -e 's/export NETWORK_NAME=fabric-template-network/export NETWORK_NAME='$NETWORK_NAME'/g' generated-orgs/$Org_Name/fabric-network.sh
	sed -i -e 's/export DOMAIN=example.com/export DOMAIN='$DOMAIN'/g' generated-orgs/$Org_Name/fabric-network.sh
	sed -i -e 's/Org1MSP/'$Org_MSP'/g' generated-orgs/$Org_Name/initial-configtx.yaml
	sed -i -e 's/org1.example.com/'${Org_Name,,}'.'$DOMAIN'/g' generated-orgs/$Org_Name/initial-configtx.yaml
	sed -i -e 's/example.com/'$DOMAIN'/g' generated-orgs/$Org_Name/initial-configtx.yaml
	sed -i -e 's/\&Org1/\&'$Org_Name'/g' generated-orgs/$Org_Name/initial-configtx.yaml
	sed -i -e 's/*Org1/*'$Org_Name'/g' generated-orgs/$Org_Name/initial-configtx.yaml
	cat generated-orgs/$Org_Name/initial-configtx.yaml > generated-orgs/$Org_Name/configtx.yaml
	sed -i -e 's/org1.example.com/'${Org_Name,,}'.'$DOMAIN'/g' generated-orgs/$Org_Name/docker-compose.yaml
	sed -i -e 's/example.com/'$DOMAIN'/g' generated-orgs/$Org_Name/docker-compose.yaml
	sed -i -e 's/Org1MSP/'$Org_MSP'/g' generated-orgs/$Org_Name/docker-compose.yaml
	sed -i -e 's/example.com/'$DOMAIN'/g' generated-orgs/$Org_Name/docker-compose-new-raft-orderer.yaml
	sed -i -e 's/org1.example.com/'${Org_Name,,}'.'$DOMAIN'/g' generated-orgs/$Org_Name/docker-compose-new-peer.yaml
	sed -i -e 's/Org1MSP/'$Org_MSP'/g' generated-orgs/$Org_Name/docker-compose-new-peer.yaml
	sed -i -e 's/Org1MSP/'$Org_MSP'/g' generated-orgs/$Org_Name/connection-profile/fabric-network.json
	sed -i -e 's/org1.example.com/'${Org_Name,,}'.'$DOMAIN'/g' generated-orgs/$Org_Name/connection-profile/fabric-network.json
	sed -i -e 's/org1/'${Org_Name,,}'/g' generated-orgs/$Org_Name/docker-compose-explorer.yaml
	sed -i -e 's/8080:8080/'$ORG_EXPLORER_PORT':8080/g' generated-orgs/$Org_Name/docker-compose-explorer.yaml
	sed -i -e 's/org1/'${Org_Name,,}'/g' generated-orgs/$Org_Name/docker-compose-org-ca.yaml
	sed -i -e 's/example.com/'$DOMAIN'/g' generated-orgs/$Org_Name/docker-compose-org-ca.yaml
	sed -i -e 's/example.com/'$DOMAIN'/g' generated-orgs/$Org_Name/docker-compose-orderer-ca.yaml
	sed -i -e 's/Org1/'${Org_Name,,}'/g' generated-orgs/$Org_Name/fabric-org-ca/fabric-ca-server-config.yaml
	sed -i -e 's/org1.example.com/'${Org_Name,,}'.'$DOMAIN'/g' generated-orgs/$Org_Name/fabric-org-ca/fabric-ca-server-config.yaml
	sed -i -e 's/org1.example.com/'${Org_Name,,}'.'$DOMAIN'/g' generated-orgs/$Org_Name/fabric-orderer-ca/fabric-ca-server-config.yaml
	sed -i -e 's/example.com/'$DOMAIN'/g' generated-orgs/$Org_Name/fabric-orderer-ca/fabric-ca-server-config.yaml
fi

if [ ! "$ORG_NUMBER" == "1" ]; then
	export ord_ser=$(($ORG_NUMBER-1))
	cat fabric-template/fabric-network-next-org.sh > generated-orgs/$Org_Name/fabric-network.sh
	cat fabric-template/configtx-next-org.yaml >  generated-orgs/$Org_Name/initial-configtx.yaml
	cat fabric-template/docker-compose-next-org.yaml > generated-orgs/$Org_Name/docker-compose.yaml
	sed -i -e 's/export Org_Name=Org2/export Org_Name='$Org_Name'/g' generated-orgs/$Org_Name/fabric-network.sh
	sed -i -e 's/export Org_MSP=Org2MSP/export Org_MSP='$Org_MSP'/g' generated-orgs/$Org_Name/fabric-network.sh
	sed -i -e 's/export NETWORK_NAME=fabric-template-network/export NETWORK_NAME='$NETWORK_NAME'/g' generated-orgs/$Org_Name/fabric-network.sh
	sed -i -e 's/export DOMAIN=example.com/export DOMAIN='$DOMAIN'/g' generated-orgs/$Org_Name/fabric-network.sh
	sed -i -e 's/export ORDERER_SERIES=1/export ORDERER_SERIES='$ord_ser'/g' generated-orgs/$Org_Name/fabric-network.sh
	sed -i -e 's/export BASE_ORDERER=10/export BASE_ORDERER='$ord_ser'0/g' generated-orgs/$Org_Name/fabric-network.sh
	sed -i -e 's/BYFN_CA2_PRIVATE_KEY/BYFN_CA'$ORG_NUMBER'_PRIVATE_KEY/g' generated-orgs/$Org_Name/fabric-network.sh
	sed -i -e 's/Org2MSP/'$Org_MSP'/g' generated-orgs/$Org_Name/initial-configtx.yaml
	sed -i -e 's/org2.example.com/'${Org_Name,,}'.'$DOMAIN'/g' generated-orgs/$Org_Name/initial-configtx.yaml
	sed -i -e 's/example.com/'$DOMAIN'/g' generated-orgs/$Org_Name/initial-configtx.yaml
	sed -i -e 's/\&Org2/\&'$Org_Name'/g' generated-orgs/$Org_Name/initial-configtx.yaml
	sed -i -e 's/*Org2/*'$Org_Name'/g' generated-orgs/$Org_Name/initial-configtx.yaml
	cat generated-orgs/$Org_Name/initial-configtx.yaml > generated-orgs/$Org_Name/configtx.yaml
	sed -i -e 's/org2.example.com/'${Org_Name,,}'.'$DOMAIN'/g' generated-orgs/$Org_Name/docker-compose.yaml
	sed -i -e 's/example.com/'$DOMAIN'/g' generated-orgs/$Org_Name/docker-compose.yaml
	sed -i -e 's/Org2MSP/'$Org_MSP'/g' generated-orgs/$Org_Name/docker-compose.yaml
	sed -i -e 's/BYFN_CA2_PRIVATE_KEY/BYFN_CA'$ORG_NUMBER'_PRIVATE_KEY/g' generated-orgs/$Org_Name/docker-compose.yaml
	sed -i -e 's/example.com/'$DOMAIN'/g' generated-orgs/$Org_Name/docker-compose-new-raft-orderer.yaml
	sed -i -e 's/org1.example.com/'${Org_Name,,}'.'$DOMAIN'/g' generated-orgs/$Org_Name/docker-compose-new-peer.yaml
	sed -i -e 's/Org1MSP/'$Org_MSP'/g' generated-orgs/$Org_Name/docker-compose-new-peer.yaml
	sed -i -e 's/Org1MSP/'$Org_MSP'/g' generated-orgs/$Org_Name/connection-profile/fabric-network.json
	sed -i -e 's/org1.example.com/'${Org_Name,,}'.'$DOMAIN'/g' generated-orgs/$Org_Name/connection-profile/fabric-network.json
	sed -i -e 's/org1/'${Org_Name,,}'/g' generated-orgs/$Org_Name/docker-compose-explorer.yaml
	sed -i -e 's/8080:8080/'$ORG_EXPLORER_PORT':8080/g' generated-orgs/$Org_Name/docker-compose-explorer.yaml
	sed -i -e 's/org1/'${Org_Name,,}'/g' generated-orgs/$Org_Name/docker-compose-org-ca.yaml
	sed -i -e 's/example.com/'$DOMAIN'/g' generated-orgs/$Org_Name/docker-compose-org-ca.yaml
	sed -i -e 's/Org1/'${Org_Name,,}'/g' generated-orgs/$Org_Name/fabric-org-ca/fabric-ca-server-config.yaml
	sed -i -e 's/org1.example.com/'${Org_Name,,}'.'$DOMAIN'/g' generated-orgs/$Org_Name/fabric-org-ca/fabric-ca-server-config.yaml

fi

	echo "Scripts generated for $Org_Name"




