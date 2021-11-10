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

 echo "Reenrolling the peer${IDENTITY_NO} msp"
  set -x
  fabric-ca-client reenroll -u https://peer${IDENTITY_NO}:peer${IDENTITY_NO}pw@ca-org.${Org_name,,}.${DOMAIN}:7054 --caname ca-org.${Org_name,,}.${DOMAIN} -M "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/peers/peer${IDENTITY_NO}.${Org_name,,}.${DOMAIN}/msp" --csr.hosts peer${IDENTITY_NO}.${Org_name,,}.${DOMAIN} --tls.certfiles "${PWD}/fabric-org-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/msp/config.yaml" "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/peers/peer${IDENTITY_NO}.${Org_name,,}.${DOMAIN}/msp/config.yaml"

  echo "Reenrolling the peer${IDENTITY_NO}-tls certificates"
  set -x
  fabric-ca-client reenroll -u https://peer${IDENTITY_NO}:peer${IDENTITY_NO}pw@ca-org.${Org_name,,}.${DOMAIN}:7054 --caname ca-org.${Org_name,,}.${DOMAIN} -M "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/peers/peer${IDENTITY_NO}.${Org_name,,}.${DOMAIN}/tls" --enrollment.profile tls --csr.hosts peer${IDENTITY_NO}.${Org_name,,}.${DOMAIN} --csr.hosts ca-org.${Org_name,,}.${DOMAIN} --tls.certfiles "${PWD}/fabric-org-ca/tls-cert.pem"
  { set +x; } 2>/dev/null
fi  
  
  
if [ "$IDENTITY" == "orderer" ]; then  
 
  echo "Reenrolling the orderer${IDENTITY_NO} msp"
  set -x
  fabric-ca-client reenroll -u https://orderer${IDENTITY_NO}:ordererpw@ca-orderer.${DOMAIN}:9054 --caname ca-orderer.${DOMAIN} -M "${PWD}/ordererOrganizations/${DOMAIN}/orderers/orderer${IDENTITY_NO}.${DOMAIN}/msp" --csr.hosts orderer${IDENTITY_NO}.${DOMAIN} --csr.hosts ca-orderer.${DOMAIN} --tls.certfiles "${PWD}/fabric-orderer-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/ordererOrganizations/${DOMAIN}/msp/config.yaml" "${PWD}/ordererOrganizations/${DOMAIN}/orderers/orderer${IDENTITY_NO}.${DOMAIN}/msp/config.yaml"

  echo "Reenrolling the orderer${IDENTITY_NO}-tls certificates"
  set -x
  fabric-ca-client reenroll -u https://orderer${IDENTITY_NO}:ordererpw@ca-orderer.${DOMAIN}:9054 --caname ca-orderer.${DOMAIN} -M "${PWD}/ordererOrganizations/${DOMAIN}/orderers/orderer${IDENTITY_NO}.${DOMAIN}/tls" --enrollment.profile tls --csr.hosts orderer${IDENTITY_NO}.${DOMAIN} --csr.hosts ca-orderer.${DOMAIN} --tls.certfiles "${PWD}/fabric-orderer-ca/tls-cert.pem"
  { set +x; } 2>/dev/null
 
 fi
 
 if [ "$IDENTITY" == "user" ]; then  
 
  echo "Reenrolling the user msp"
  set -x
  fabric-ca-client reenroll -u https://user${IDENTITY_NO}:user${IDENTITY_NO}pw@ca-org.${Org_name,,}.${DOMAIN}:7054 --caname ca-org.${Org_name,,}.${DOMAIN} -M "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/users/User1@${Org_name,,}.${DOMAIN}/msp" --tls.certfiles "${PWD}/fabric-org-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/msp/config.yaml" "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/users/User1@${Org_name,,}.${DOMAIN}/msp/config.yaml"

fi
 
 if [ "$IDENTITY" == "admin" ]; then  
 
  echo "Reenrolling the org admin msp"
  set -x
  fabric-ca-client reenroll -u https://${Org_name,,}admin:${Org_name,,}adminpw@ca-org.${Org_name,,}.${DOMAIN}:7054 --caname ca-org.${Org_name,,}.${DOMAIN} -M "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/users/Admin@${Org_name,,}.${DOMAIN}/msp" --tls.certfiles "${PWD}/fabric-org-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/msp/config.yaml" "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/users/Admin@${Org_name,,}.${DOMAIN}/msp/config.yaml"
 fi
