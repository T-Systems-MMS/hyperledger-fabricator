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
  export PEER_NO=$3

  echo "Enrolling the CA admin"
  mkdir -p ${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/

  export FABRIC_CA_CLIENT_HOME=${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/
  export PATH=/home/bin:$PATH

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@ca-org.${Org_name,,}.${DOMAIN}:7054 --caname ca-org.${Org_name,,}.${DOMAIN} --tls.certfiles "${PWD}/fabric-org-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca-org-'${Org_name,,}'-'${DOM}'-7054-ca-org-'${Org_name,,}'-'${DOM}'.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca-org-'${Org_name,,}'-'${DOM}'-7054-ca-org-'${Org_name,,}'-'${DOM}'.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca-org-'${Org_name,,}'-'${DOM}'-7054-ca-org-'${Org_name,,}'-'${DOM}'.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca-org-'${Org_name,,}'-'${DOM}'-7054-ca-org-'${Org_name,,}'-'${DOM}'.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/msp/config.yaml"

  echo "Registering peer${PEER_NO}"
  set -x
  fabric-ca-client register --caname ca-org.${Org_name,,}.${DOMAIN} --id.name peer${PEER_NO} --id.secret peer${PEER_NO}pw --id.type peer --tls.certfiles "${PWD}/fabric-org-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering user"
  set -x
  fabric-ca-client register --caname ca-org.${Org_name,,}.${DOMAIN} --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/fabric-org-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-org.${Org_name,,}.${DOMAIN} --id.name ${Org_name,,}admin --id.secret ${Org_name,,}adminpw --id.type admin --tls.certfiles "${PWD}/fabric-org-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the peer${PEER_NO} msp"
  set -x
  fabric-ca-client enroll -u https://peer${PEER_NO}:peer${PEER_NO}pw@ca-org.${Org_name,,}.${DOMAIN}:7054 --caname ca-org.${Org_name,,}.${DOMAIN} -M "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/peers/peer${PEER_NO}.${Org_name,,}.${DOMAIN}/msp" --csr.hosts peer${PEER_NO}.${Org_name,,}.${DOMAIN} --tls.certfiles "${PWD}/fabric-org-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/msp/config.yaml" "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/peers/peer${PEER_NO}.${Org_name,,}.${DOMAIN}/msp/config.yaml"

  echo "Generating the peer${PEER_NO}-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer${PEER_NO}:peer${PEER_NO}pw@ca-org.${Org_name,,}.${DOMAIN}:7054 --caname ca-org.${Org_name,,}.${DOMAIN} -M "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/peers/peer${PEER_NO}.${Org_name,,}.${DOMAIN}/tls" --enrollment.profile tls --csr.hosts peer${PEER_NO}.${Org_name,,}.${DOMAIN} --csr.hosts ca-org.${Org_name,,}.${DOMAIN} --tls.certfiles "${PWD}/fabric-org-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/peers/peer${PEER_NO}.${Org_name,,}.${DOMAIN}/tls/tlscacerts/"* "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/peers/peer${PEER_NO}.${Org_name,,}.${DOMAIN}/tls/ca.crt"
  cp "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/peers/peer${PEER_NO}.${Org_name,,}.${DOMAIN}/tls/signcerts/"* "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/peers/peer${PEER_NO}.${Org_name,,}.${DOMAIN}/tls/server.crt"
  cp "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/peers/peer${PEER_NO}.${Org_name,,}.${DOMAIN}/tls/keystore/"* "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/peers/peer${PEER_NO}.${Org_name,,}.${DOMAIN}/tls/server.key"

  mkdir -p "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/msp/tlscacerts"
  cp "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/peers/peer${PEER_NO}.${Org_name,,}.${DOMAIN}/tls/tlscacerts/"* "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/tlsca"
  cp "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/peers/peer${PEER_NO}.${Org_name,,}.${DOMAIN}/tls/tlscacerts/"* "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/tlsca/tlsca.${Org_name,,}.${DOMAIN}-cert.pem"

  mkdir -p "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/ca"
  cp "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/peers/peer${PEER_NO}.${Org_name,,}.${DOMAIN}/msp/cacerts/"* "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/ca/ca.${Org_name,,}.${DOMAIN}-cert.pem"

  echo "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@ca-org.${Org_name,,}.${DOMAIN}:7054 --caname ca-org.${Org_name,,}.${DOMAIN} -M "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/users/User1@${Org_name,,}.${DOMAIN}/msp" --tls.certfiles "${PWD}/fabric-org-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/msp/config.yaml" "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/users/User1@${Org_name,,}.${DOMAIN}/msp/config.yaml"

  echo "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://${Org_name,,}admin:${Org_name,,}adminpw@ca-org.${Org_name,,}.${DOMAIN}:7054 --caname ca-org.${Org_name,,}.${DOMAIN} -M "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/users/Admin@${Org_name,,}.${DOMAIN}/msp" --tls.certfiles "${PWD}/fabric-org-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/msp/config.yaml" "${PWD}/peerOrganizations/${Org_name,,}.${DOMAIN}/users/Admin@${Org_name,,}.${DOMAIN}/msp/config.yaml"  
  

