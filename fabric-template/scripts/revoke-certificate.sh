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

  export Org_name=$1
  export DOMAIN=$2
  export DOM=${DOMAIN/\./\-}
  export IDENTITY=$3
  export IDENTITY_NO=$4
  
  export FABRIC_CA_CLIENT_HOME=${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/
  export PATH=/home/bin:$PATH
  
if [ "$IDENTITY" == "peer" ]; then

 echo "Revoking the peer${IDENTITY_NO} msp"
  fabric-ca-client revoke -e peer${IDENTITY_NO} --gencrl --tls.certfiles "${PWD}/fabric-org-ca/tls-cert.pem" 
fi  

if [ "$IDENTITY" == "orderer" ]; then

 echo "Revoking the orderer${IDENTITY_NO} msp"
  fabric-ca-client revoke -e orderer${IDENTITY_NO} --gencrl --tls.certfiles "${PWD}/fabric-org-ca/tls-cert.pem" 
fi

if [ "$IDENTITY" == "user" ]; then

 echo "Revoking the user${IDENTITY_NO} msp"
  fabric-ca-client revoke -e user${IDENTITY_NO} --gencrl --tls.certfiles "${PWD}/fabric-org-ca/tls-cert.pem" 
fi
