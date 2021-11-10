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
  export ORG_NAME=$2
  export ORG_MSP=$3
  export BASE_ORDERER=$4
  export DOMAIN=$5

export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp/

export CORE_PEER_ADDRESS=orderer${BASE_ORDERER}.${DOMAIN}:7050

export CORE_PEER_LOCALMSPID=OrdererMSP

export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN}/orderers/orderer${BASE_ORDERER}.${DOMAIN}/tls/ca.crt

export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN}/orderers/orderer${BASE_ORDERER}.${DOMAIN}/msp/tlscacerts/tlsca.${DOMAIN}-cert.pem


peer channel fetch config config_block.pb -o ${CORE_PEER_ADDRESS} -c ${CHANNEL_NAME} --tls --cafile ${ORDERER_CA}

configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

jq -s '.[0] * {"channel_group":{"groups":{"Consortiums":{"groups": {"BaseConsortium": {"groups": {"'${ORG_MSP}'":.[1]}}}}}}}' config.json ./channel-artifacts/${ORG_NAME}.json > modified_config.json

 configtxlator proto_encode --input config.json --type common.Config --output config.pb

 configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

 configtxlator compute_update --channel_id ${CHANNEL_NAME} --original config.pb --updated modified_config.pb --output org_update.pb

 configtxlator proto_decode --input  org_update.pb --type common.ConfigUpdate | jq . > org_update.json

  echo '{"payload":{"header":{"channel_header":{"channel_id":"'${CHANNEL_NAME}'", "type":2}},"data":{"config_update":'$(cat org_update.json)'}}}' | jq . > org_update_in_envelope.json

 configtxlator proto_encode --input org_update_in_envelope.json --type common.Envelope --output org_update_in_envelope.pb

 peer channel signconfigtx -f org_update_in_envelope.pb

 peer channel update -f org_update_in_envelope.pb -c ${CHANNEL_NAME} -o orderer${BASE_ORDERER}.${DOMAIN}:7050 --tls --cafile $ORDERER_CA
