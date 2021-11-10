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


# Script to add an orderer in running network

  export CHANNEL_NAME=$1
  export ORDERER_NO=$2
  export BASE_ORDERER=$3
  export DOMAIN=$4

export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp/

export CORE_PEER_ADDRESS=orderer${BASE_ORDERER}.${DOMAIN}:7050

export CORE_PEER_LOCALMSPID=OrdererMSP

export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN}/orderers/orderer${BASE_ORDERER}.${DOMAIN}/tls/ca.crt

export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN}/orderers/orderer${BASE_ORDERER}.${DOMAIN}/msp/tlscacerts/tlsca.${DOMAIN}-cert.pem


peer channel fetch config config_block.pb -o $CORE_PEER_ADDRESS -c ${CHANNEL_NAME} --tls --cafile ${ORDERER_CA}
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json


CERT=$(cat channel-artifacts/orderer$ORDERER_NO.crt | base64 | tr -d "\n\r") jq -s '.[0].channel_group.groups.Orderer.values.ConsensusType.value.metadata.consenters += [{"client_tls_cert": env.CERT, "host": "orderer'${ORDERER_NO}'.'${DOMAIN}'", "port": 7050, "server_tls_cert": env.CERT}]' config.json > config1.json

jq '.[0]' config1.json > modified_config.json



configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output orderer_update.pb
configtxlator proto_decode --input orderer_update.pb --type common.ConfigUpdate | jq . > orderer_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'${CHANNEL_NAME}'", "type":2}},"data":{"config_update":'$(cat orderer_update.json)'}}}' | jq . > orderer_update_in_envelope.json
configtxlator proto_encode --input orderer_update_in_envelope.json --type common.Envelope --output orderer_update_in_envelope.pb
peer channel update -f orderer_update_in_envelope.pb -c $CHANNEL_NAME -o $CORE_PEER_ADDRESS --tls --cafile $ORDERER_CA
peer channel fetch config config_block.pb -o $CORE_PEER_ADDRESS -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
cp config_block.pb channel-artifacts/orderer_genesis.pb
