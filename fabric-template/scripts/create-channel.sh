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
 cd channel-artifacts/
 peer channel create -o orderer${BASE_ORDERER}.${DOMAIN}:7050 -c ${CHANNEL_NAME} -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA
 peer channel join -b ${CHANNEL_NAME}.block --tls --cafile ${ORDERER_CA}
 peer channel update -o orderer${BASE_ORDERER}.${DOMAIN}:7050 -c ${CHANNEL_NAME} -f /opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts/${Org_Name}MSPanchors_${CHANNEL_NAME}.tx --tls --cafile $ORDERER_CA
 peer channel list
 peer channel getinfo -c $CHANNEL_NAME

  echo "The channel ${CHANNEL_NAME} has been successfully created and joined."
