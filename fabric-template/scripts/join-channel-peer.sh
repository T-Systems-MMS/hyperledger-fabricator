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


# Script to join a peer to a channel

  export CHANNEL_NAME=$1
  export Org_Name_Lower=${2,,}
  export PEER_NO=$3
  export DOMAIN=$4



  CORE_PEER_ADDRESS=peer${PEER_NO}.${Org_Name_Lower}.${DOMAIN}:7051
  CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${Org_Name_Lower}.${DOMAIN}/peers/peer${PEER_NO}.${Org_Name_Lower}.${DOMAIN}/tls/server.crt
  CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${Org_Name_Lower}.${DOMAIN}/peers/peer${PEER_NO}.${Org_Name_Lower}.${DOMAIN}/tls/server.key
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${Org_Name_Lower}.${DOMAIN}/peers/peer${PEER_NO}.${Org_Name_Lower}.${DOMAIN}/tls/ca.crt

  echo "Attempting to join channel"


  cd channel-artifacts/
  peer channel join -b ${CHANNEL_NAME}.block --tls --cafile ${ORDERER_CA}
  sleep 10
  peer channel list
  peer channel getinfo -c $CHANNEL_NAME

  echo "The channel ${CHANNEL_NAME} has been successfully joined."
