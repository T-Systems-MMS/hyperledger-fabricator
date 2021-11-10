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


export CHANNEL_NAME=$1
export Org_Name=$2
export BASE_ORDERER=$3
export DOMAIN=$4
echo $CHANNEL_NAME
echo $Org_Name

peer channel fetch config config_block.pb -o orderer${BASE_ORDERER}.${DOMAIN}:7050 -c ${CHANNEL_NAME} --tls --cafile ${ORDERER_CA}
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"'${Org_Name}'MSP":.[1]}}}}}' config.json ./channel-artifacts/${Org_Name}.json > modified_config.json
configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id ${CHANNEL_NAME} --original config.pb --updated modified_config.pb --output ${Org_Name}_update.pb
configtxlator proto_decode --input ${Org_Name}_update.pb --type common.ConfigUpdate | jq . > ${Org_Name}_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'${CHANNEL_NAME}'", "type":2}},"data":{"config_update":'$(cat ${Org_Name}_update.json)'}}}' | jq . > ${Org_Name}_update_in_envelope.json
configtxlator proto_encode --input ${Org_Name}_update_in_envelope.json --type common.Envelope --output ${Org_Name}_update_in_envelope.pb
chmod 777 ${Org_Name}_update_in_envelope.pb
peer channel signconfigtx -f ${Org_Name}_update_in_envelope.pb

cp ${Org_Name}_update_in_envelope.pb ./channel-artifacts/

rm -f config_block.pb config.json modified_config.json config.pb modified_config.pb ${Org_Name}_update.pb ${Org_Name}_update.json ${Org_Name}_update_in_envelope.json ${Org_Name}_update_in_envelope.pb ${CHANNEL_NAME}.block

  echo "(1) The new organization configuration for this channel is exported in channel-artifacts/${Org_Name}_update_in_envelope.pb file"
  echo "(2) Copy channel-artifacts/${Org_Name}_update_in_envelope.pb file in channel-artifacts folders of all organizations already on this channel"
  echo "(2) run ./fabric-network add-org-sign from all organizations on ledger to sign this configuration and commit to ledger"
