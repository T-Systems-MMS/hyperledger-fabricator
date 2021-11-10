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

  export Org_Name=Org1
  export Org_MSP=Org1MSP
  export COMPOSE_PROJECT_NAME=net
  export NETWORK_NAME=fabric-template-network
  export IMAGE_TAG=latest
  export SYS_CHANNEL=byfn-sys-channel
  export DOMAIN=example.com
  export ORDERER_SERIES=  # this should be empty for 1st org (Not zero 0), 1 for 2nd Org, 2 for 3rd Org and so on..
  export BASE_ORDERER=0
  export BASE_PEER=0
  echo ${Org_Name}

if [ "$1" == "help" ]; then
  echo "Welcome to Fabric setup utility"
  echo "The command works like this:"
  echo "./fabric-network.sh COMMAND_NAME ARGS" 
  echo ""
  echo "1. To generate crypto material for this organization use:"
  echo " ./fabric-network.sh generate-crypto"
  echo ""
  echo "2. To bring up the organization:"
  echo " ./fabric-network.sh up"
  echo ""
  echo "3. To add config of another organization:"
  echo " ./fabric-network.sh add-org-config CHANNEL_NAME ORG_TO_BE_ADDED_NAME"
  echo ""
  echo "4. To sign config of another organization:"
  echo " ./fabric-network.sh add-org-sign CHANNEL_NAME ORG_TO_BE_SIGNED_NAME"
  echo ""
  echo "5. To create a channel:"
  echo " ./fabric-network.sh create-channel CHANNEL_PROFILE CHANNEL_NAME"
  echo ""
  echo "6. To join a peer to a channel:"
  echo " ./fabric-network.sh join-channel-peer PEER_NO CHANNEL_NAME"
  echo ""
  echo "7. To add another peer:"
  echo "./fabric-network.sh add-peer"
  echo ""
  echo "8. To add another local orderer of an organization:"
  echo "./fabric-network.sh add-local-orderer"
  echo ""
  echo "9. To add orderer to a channel:"
  echo "./fabric-network.sh join-channel-orderer ORDERER_NO CHANNEL_NAME"
  echo ""
  echo "10. To add remote orderer of another organization:"
  echo "./fabric-network.sh add-remote-orderer ORDERER_NO"
  echo ""
  echo "11. To publish remote orderer of another organization:"
  echo "./fabric-network.sh publish-remote-orderer ORDERER_NO"
  echo ""
  echo "12. To package a chaincode:"
  echo " ./fabric-network.sh package-cc CHAINCODE_NAME CHAINCODE_LANGUAGE CHAINCODE_LABEL"
  echo ""
  echo "13. To install a chaincode:"
  echo " ./fabric-network.sh install-cc CHAINCODE_NAME"
  echo ""
  echo "14. To query whether a chaincode has installed:"
  echo " ./fabric-network.sh query-installed-cc"
  echo ""
  echo "15. To approve a chaincode from your organization:"
  echo " ./fabric-network.sh approve-cc CHANNEL_NAME CHAINCODE_NAME VERSION PACKAGE_ID SEQUENCE"
  echo ""
  echo "16. To check commit-readiness of a chaincode:"
  echo " ./fabric-network.sh checkcommitreadiness-cc CHANNEL_NAME CHAINCODE_NAME VERSION SEQUENCE OUTPUT"
  echo ""
  echo "17. To commit a chaincode:"
  echo " ./fabric-network.sh commit-cc CHANNEL_NAME CHAINCODE_NAME VERSION SEQUENCE"
  echo ""
  echo "18. To query committed chaincodes on a channel:"
  echo " ./fabric-network.sh query-committed-cc CHANNEL_NAME"
  echo ""
  echo "19. To initialize a chaincode:"
  echo " ./fabric-network.sh init-cc CHANNEL_NAME CHAINCODE_NAME"
  echo ""
  echo "20. To invoke a chaincode:"
  echo " ./fabric-network.sh invoke-function-cc CHANNEL_NAME CHAINCODE_NAME FUNCTION ARGS"
  echo ""
  echo "21. To query a chaincode:"
  echo " ./fabric-network.sh query-function-cc CHANNEL_NAME CHAINCODE_NAME ARGS"
  echo ""
  echo "22. To start explorer:"
  echo " ./fabric-network.sh bootstrap-explorer"
  echo ""
  echo "23. To down explorer:"
  echo " ./fabric-network.sh explorer-down"
  echo ""
  echo "24. To display help:"
  echo " ./fabric-network.sh help"
  echo ""
  echo "25. To shut down the organization and cleanup:"
  echo " ./fabric-network.sh down cleanup"
  echo ""
fi


if [ "$1" == "generate-crypto" ]; then
  docker network create $NETWORK_NAME
  
  rm -rf channel-artifacts/ crypto-config/
  
  docker-compose -f docker-compose-orderer-ca.yaml up -d
  docker-compose -f docker-compose-org-ca.yaml up -d

  sleep 5
  chmod -R 777 fabric-org-ca
  chmod -R 777 fabric-orderer-ca


  docker exec ca-cli.${Org_Name,,}.$DOMAIN bash -c "scripts/registerEnroll-Orderer.sh $Org_Name $DOMAIN $BASE_ORDERER"
  docker exec ca-cli.${Org_Name,,}.$DOMAIN bash -c "scripts/registerEnroll-Peer.sh $Org_Name $DOMAIN $BASE_PEER"
  docker exec ca-cli.${Org_Name,,}.$DOMAIN bash -c "scripts/registerEnroll-Peer.sh $Org_Name $DOMAIN $((BASE_PEER+1))" 

  chmod -R 777 crypto-config  
  
  mkdir channel-artifacts && mkdir channel-artifacts/OrdererSharedCerts && mkdir dynamic-containers && export FABRIC_CFG_PATH=$PWD

  ../bin/configtxgen -profile OrdererGenesis -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block
  ../bin/configtxgen -printOrg ${Org_Name}MSP > ./channel-artifacts/${Org_Name}.json

  echo "The peer related certificates have been generated and exported in ./channel-artifacts/${Org_Name}.json file"
  echo "Copy ${Org_Name}.json in channel-artifacts of already running organization to add peers to a channel"

  echo "The required certificates have been generated"
fi


if [ "$1" == "reenroll-certificate" ]; then
	
  export identity="$2"
  export identity_no="$3"
  docker exec ca-cli.${Org_Name,,}.$DOMAIN bash -c "scripts/reenroll-certificate.sh $Org_Name $DOMAIN $identity $identity_no" 
fi


if [ "$1" == "revoke-certificate" ]; then
  export identity="$2"
  export identity_no="$3"
  docker exec ca-cli.${Org_Name,,}.$DOMAIN bash -c "scripts/revoke-certificate.sh $Org_Name $DOMAIN $identity $identity_no"
fi


if [ "$1" == "up" ]; then
  export FABRIC_CFG_PATH=$PWD
  #export BYFN_CA1_PRIVATE_KEY=$(cd crypto-config/peerOrganizations/${Org_Name,,}.$DOMAIN/ca && ls *_sk && cd ../../../../)
  #echo $BYFN_CA1_PRIVATE_KEY
  docker-compose up -d
fi

if [ "$1" == "add-org-config" ]; then
  export CHANNEL_NAME="$2"
  export NEW_ORG="$3"
docker exec cli.${Org_Name,,}.$DOMAIN bash -c "scripts/add-org-config.sh $CHANNEL_NAME $NEW_ORG $BASE_ORDERER $DOMAIN"

fi

if [ "$1" == "add-org-sign" ]; then
  export CHANNEL_NAME="$2"
  export NEW_ORG="$3"
docker exec cli.${Org_Name,,}.$DOMAIN bash -c "scripts/add-org-sign.sh $CHANNEL_NAME $NEW_ORG $BASE_ORDERER $DOMAIN"

fi

if [ "$1" == "create-channel" ]; then
  
 export FABRIC_CFG_PATH=$PWD
  export CHANNEL_PROFILE="$2"
  export CHANNEL_NAME="$3"


  ../bin/configtxgen -profile ${CHANNEL_PROFILE} -outputCreateChannelTx ./channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME

  ../bin/configtxgen -profile ${CHANNEL_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/${Org_Name}MSPanchors_${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME -asOrg ${Org_Name}MSP

  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "scripts/create-channel.sh $CHANNEL_NAME $Org_Name $BASE_ORDERER $DOMAIN"

fi

if [ "$1" == "join-channel-peer" ]; then

  export PEER_NO="$2"
  export CHANNEL_NAME="$3"
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "scripts/join-channel-peer.sh $CHANNEL_NAME $Org_Name $PEER_NO $DOMAIN"
fi

if [ "$1" == "add-peer" ]; then

peer_service_name=$(yq e -j docker-compose-new-peer.yaml | jq -r '.volumes|keys[1]')
postfix=${peer_service_name%.${Org_Name,,}*}
newpeer=${postfix##*peer}

docker exec ca-cli.${Org_Name,,}.$DOMAIN bash -c "scripts/registerEnroll-Peer.sh $Org_Name $DOMAIN $newpeer"
docker-compose -f docker-compose-new-peer.yaml up -d

cat docker-compose-new-peer.yaml> dynamic-containers/docker-compose-new-peer-$newpeer.yaml

newPeerCount=$((newpeer+1))
sed -i -e 's/'${peer_service_name}'/peer'$newPeerCount'.'${Org_Name,,}'.'$DOMAIN'/g' docker-compose-new-peer.yaml

fi


if [ "$1" == "add-local-orderer" ]; then
 
  old_orderer_service_name=$(yq e '.volumes' docker-compose-new-raft-orderer.yaml)
  postfix=${old_orderer_service_name%.${DOMAIN}*}
  ORDERER_NO=${postfix##*orderer}
  
  if [ $ORDERER_NO -ge 10 ]; then
    echo "Max number of local orderers reached, can not add any more orderers"
    exit
  fi
  
  docker exec ca-cli.${Org_Name,,}.$DOMAIN bash -c "scripts/registerEnroll-Orderer.sh $Org_Name $DOMAIN $ORDERER_NO"
  
  
  cp crypto-config/ordererOrganizations/$DOMAIN/orderers/orderer$ORDERER_NO.$DOMAIN/tls/server.crt channel-artifacts/orderer$ORDERER_NO.crt
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "scripts/add-orderer.sh $SYS_CHANNEL $ORDERER_NO $BASE_ORDERER $DOMAIN"
  sleep 10
  
  docker-compose -f docker-compose-new-raft-orderer.yaml up -d
  
  cat docker-compose-new-raft-orderer.yaml> dynamic-containers/docker-compose-new-raft-orderer-$ORDERER_NO.yaml
  
  sed -i -e 's/'${old_orderer_service_name::-1}'/orderer'$((ORDERER_NO+1))'.'$DOMAIN'/g' docker-compose-new-raft-orderer.yaml
  
  sleep 10
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "scripts/announce-orderer.sh $SYS_CHANNEL $ORDERER_NO $BASE_ORDERER $DOMAIN"
fi


if [ "$1" == "join-channel-orderer" ]; then
  export ORDERER_NO="$2"
  export CHANNEL_NAME="$3"
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "scripts/add-orderer.sh $CHANNEL_NAME $ORDERER_NO $BASE_ORDERER $DOMAIN"
  sleep 30
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "scripts/announce-orderer.sh $CHANNEL_NAME $ORDERER_NO $BASE_ORDERER $DOMAIN"
 
fi

if [ "$1" == "add-remote-orderer" ]; then
  export ORDERER_NO="$2"
       if [ ! -f  channel-artifacts/orderer$ORDERER_NO.crt ]; then
	 echo "Please copy orderer $ORDERER_NO certificates into channel-artifacts/orderer$ORDERER_NO.crt to add remote orderer"
         exit
	fi
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "scripts/add-orderer.sh $SYS_CHANNEL $ORDERER_NO $BASE_ORDERER $DOMAIN"
  sleep 10

  echo "The Orderer information has been committed to the Orderer's channel"
  echo "Next step: Copy the channel-artifacts/orderer_genesis.pb into channel-artifacts/orderer_genesis.pb of the remote organization and run add-orderer from there"
 
fi

if [ "$1" == "publish-remote-orderer" ]; then
  export ORDERER_NO="$2"
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "scripts/announce-orderer.sh $SYS_CHANNEL $ORDERER_NO $BASE_ORDERER $DOMAIN"
 
fi

if [ "$1" == "package-cc" ]; then
  export CHAINCODE_NAME="$2"
  export LANG="$3"
  export LABEL="$4"
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz --path /opt/gopath/src/github.com/chaincode/go --lang $LANG --label $LABEL"
fi


if [ "$1" == "install-cc" ]; then
  export CHAINCODE_NAME="$2"
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz"
fi

if [ "$1" == "query-installed-cc" ]; then
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "peer lifecycle chaincode queryinstalled"
fi

if [ "$1" == "approve-cc" ]; then

  export CHANNEL_ID="$2"
  export CHAINCODE_NAME="$3"
  export VERSION="$4"
  export PACKAGE_ID="$5"
  export SEQUENCE="$6"
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "peer lifecycle chaincode approveformyorg -o orderer${BASE_ORDERER}.$DOMAIN:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/$DOMAIN/orderers/orderer${BASE_ORDERER}.$DOMAIN/msp/tlscacerts/tlsca.$DOMAIN-cert.pem --channelID $CHANNEL_ID --name $CHAINCODE_NAME --version $VERSION --init-required --package-id $PACKAGE_ID --waitForEvent --sequence $SEQUENCE"
fi

if [ "$1" == "checkcommitreadiness-cc" ]; then
  export CHANNEL_ID="$2"
  export CHAINCODE_NAME="$3"
  export VERSION="$4"
  export SEQUENCE="$5"
  export OUTPUT="$6"
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_ID --name $CHAINCODE_NAME --version $VERSION --sequence $SEQUENCE --output $OUTPUT --init-required"
fi


if [ "$1" == "commit-cc" ]; then
  export CHANNEL_ID="$2"
  export CHAINCODE_NAME="$3"
  export VERSION="$4"
  export SEQUENCE="$5"
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "peer lifecycle chaincode commit -o orderer${BASE_ORDERER}.$DOMAIN:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/$DOMAIN/orderers/orderer${BASE_ORDERER}.$DOMAIN/msp/tlscacerts/tlsca.$DOMAIN-cert.pem --channelID $CHANNEL_ID --name $CHAINCODE_NAME $PEER_CONN_PARMS --version $VERSION --sequence $SEQUENCE --init-required --peerAddresses peer0.${Org_Name,,}.$DOMAIN:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${Org_Name,,}.$DOMAIN/peers/peer0.${Org_Name,,}.$DOMAIN/tls/ca.crt"
fi

if [ "$1" == "query-committed-cc" ]; then
  export CHANNEL_ID="$2"
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "peer lifecycle chaincode querycommitted --channelID $CHANNEL_ID"
fi

if [ "$1" == "init-cc" ]; then
  export CHANNEL_ID="$2"
  export CHAINCODE_NAME="$3"
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "peer chaincode invoke -o orderer${BASE_ORDERER}.$DOMAIN:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/$DOMAIN/orderers/orderer${BASE_ORDERER}.$DOMAIN/msp/tlscacerts/tlsca.$DOMAIN-cert.pem --ordererTLSHostnameOverride orderer${BASE_ORDERER}.$DOMAIN -C $CHANNEL_ID -n $CHAINCODE_NAME --isInit -c '{\"Args\":[]}' --peerAddresses peer0.${Org_Name,,}.$DOMAIN:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${Org_Name,,}.$DOMAIN/peers/peer0.${Org_Name,,}.$DOMAIN/tls/ca.crt"
fi

if [ "$1" == "invoke-function-cc" ]; then
  export CHANNEL_ID="$2"
  export CHAINCODE_NAME="$3"
  export FUNCTION_NAME="$4"
  export ARGS="$5"
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "peer chaincode invoke -o orderer${BASE_ORDERER}.$DOMAIN:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/$DOMAIN/orderers/orderer${BASE_ORDERER}.$DOMAIN/msp/tlscacerts/tlsca.$DOMAIN-cert.pem --ordererTLSHostnameOverride orderer${BASE_ORDERER}.$DOMAIN -C $CHANNEL_ID -n $CHAINCODE_NAME -c '{\"function\":\"'${FUNCTION_NAME}'\",\"Args\":[${ARGS}]}' --peerAddresses peer0.${Org_Name,,}.$DOMAIN:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${Org_Name,,}.$DOMAIN/peers/peer0.${Org_Name,,}.$DOMAIN/tls/ca.crt"
fi

if [ "$1" == "query-function-cc" ]; then
  export CHANNEL_ID="$2"
  export CHAINCODE_NAME="$3"
  export ARGS="$4"
  docker exec cli.${Org_Name,,}.$DOMAIN bash -c "peer chaincode query -C $CHANNEL_ID -n $CHAINCODE_NAME -c '{\"Args\":[\"${ARGS}\"]}'"
fi


if [ "$1" == "bootstrap-explorer" ]; then
#  <replace ./conncection-profile/first-network.json channelname with "$2">
  docker-compose -f docker-compose-explorer.yaml up -d
fi

if [ "$1" == "explorer-down" ]; then
  docker-compose -f docker-compose-explorer.yaml down -v
fi

if [ "$1" == "down" ]; then
  docker-compose down -v
  docker-compose -f docker-compose-orderer-ca.yaml down -v
  docker-compose -f docker-compose-org-ca.yaml down -v
  docker-compose -f docker-compose-new-peer.yaml down -v
#  docker-compose -f docker-compose-new-raft-orderer.yaml down -v
	if [ -d dynamic-containers ]; then
		if    ls -1qA ./dynamic-containers/ | grep -q .
		then  ! 
			cd dynamic-containers/
			for f in *; do
			  mv $f ../$f
			  docker-compose -f ../$f down -v
			  mv ../$f $f
			done
			cd ..
		else  echo dynamic-containers is empty
		fi
	fi
 	if [ "$2" == "cleanup" ]; then
		  rm -rf channel-artifacts/ crypto-config/ dynamic-containers/
	fi
	if [ "$3" == "restore" ]; then
		  cat initial-configtx.yaml > configtx.yaml
	fi
fi
