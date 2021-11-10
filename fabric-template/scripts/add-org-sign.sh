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


peer channel update -f channel-artifacts/${Org_Name}_update_in_envelope.pb -c ${CHANNEL_NAME} -o orderer${BASE_ORDERER}.${DOMAIN}:7050 --tls --cafile ${ORDERER_CA}
peer channel fetch 0 ${CHANNEL_NAME}.block -o orderer${BASE_ORDERER}.${DOMAIN}:7050 -c ${CHANNEL_NAME} --tls --cafile ${ORDERER_CA}
peer channel getinfo -c $CHANNEL_NAME
cp ${CHANNEL_NAME}.block ./channel-artifacts/

rm -f config_block.pb config.json modified_config.json config.pb modified_config.pb ${Org_Name}_update.pb ${Org_Name}_update.json ${Org_Name}_update_in_envelope.json ${Org_Name}_update_in_envelope.pb ${CHANNEL_NAME}.block

  echo "The channel ${CHANNEL_NAME} has been updated with the new organization and new genesis block is now added in ./channel-artifacts/${CHANNEL_NAME}.block file"
  echo "Copy this file ./channel-artifacts/${CHANNEL_NAME}.block in new organization's channel-artifacts and join this channel from anchor peer cli"
