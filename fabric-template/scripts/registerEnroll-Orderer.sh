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
  export ORDERER_NO=$3
  
  echo "Enrolling the CA admin"
  mkdir -p ${PWD}/ordererOrganizations/${DOMAIN}

  export FABRIC_CA_CLIENT_HOME=${PWD}/ordererOrganizations/${DOMAIN}
  export PATH=/home/bin:$PATH

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@ca-orderer.${DOMAIN}:9054 --caname ca-orderer.${DOMAIN} --tls.certfiles "${PWD}/fabric-orderer-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/ca-orderer-'${DOM}'-9054-ca-orderer-'${DOM}'.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/ca-orderer-'${DOM}'-9054-ca-orderer-'${DOM}'.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/ca-orderer-'${DOM}'-9054-ca-orderer-'${DOM}'.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/ca-orderer-'${DOM}'-9054-ca-orderer-'${DOM}'.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/ordererOrganizations/${DOMAIN}/msp/config.yaml"

  echo "Registering orderer${ORDERER_NO}"
  set -x
  fabric-ca-client register --caname ca-orderer.${DOMAIN} --id.name orderer${ORDERER_NO} --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/fabric-orderer-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "Registering the orderer${ORDERER_NO} admin"
  set -x
  fabric-ca-client register --caname ca-orderer.${DOMAIN} --id.name orderer${ORDERER_NO}Admin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/fabric-orderer-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo "Generating the orderer${ORDERER_NO} msp"
  set -x
  fabric-ca-client enroll -u https://orderer${ORDERER_NO}:ordererpw@ca-orderer.${DOMAIN}:9054 --caname ca-orderer.${DOMAIN} -M "${PWD}/ordererOrganizations/${DOMAIN}/orderers/orderer${ORDERER_NO}.${DOMAIN}/msp" --csr.hosts orderer${ORDERER_NO}.${DOMAIN} --csr.hosts ca-orderer.${DOMAIN} --tls.certfiles "${PWD}/fabric-orderer-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/ordererOrganizations/${DOMAIN}/msp/config.yaml" "${PWD}/ordererOrganizations/${DOMAIN}/orderers/orderer${ORDERER_NO}.${DOMAIN}/msp/config.yaml"

  echo "Generating the orderer${ORDERER_NO}-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer${ORDERER_NO}:ordererpw@ca-orderer.${DOMAIN}:9054 --caname ca-orderer.${DOMAIN} -M "${PWD}/ordererOrganizations/${DOMAIN}/orderers/orderer${ORDERER_NO}.${DOMAIN}/tls" --enrollment.profile tls --csr.hosts orderer${ORDERER_NO}.${DOMAIN} --csr.hosts ca-orderer.${DOMAIN} --tls.certfiles "${PWD}/fabric-orderer-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/ordererOrganizations/${DOMAIN}/orderers/orderer${ORDERER_NO}.${DOMAIN}/tls/tlscacerts/"* "${PWD}/ordererOrganizations/${DOMAIN}/orderers/orderer${ORDERER_NO}.${DOMAIN}/tls/ca.crt"
  cp "${PWD}/ordererOrganizations/${DOMAIN}/orderers/orderer${ORDERER_NO}.${DOMAIN}/tls/signcerts/"* "${PWD}/ordererOrganizations/${DOMAIN}/orderers/orderer${ORDERER_NO}.${DOMAIN}/tls/server.crt"
  cp "${PWD}/ordererOrganizations/${DOMAIN}/orderers/orderer${ORDERER_NO}.${DOMAIN}/tls/keystore/"* "${PWD}/ordererOrganizations/${DOMAIN}/orderers/orderer${ORDERER_NO}.${DOMAIN}/tls/server.key"

  mkdir -p "${PWD}/ordererOrganizations/${DOMAIN}/orderers/orderer${ORDERER_NO}.${DOMAIN}/msp/tlscacerts"
  cp "${PWD}/ordererOrganizations/${DOMAIN}/orderers/orderer${ORDERER_NO}.${DOMAIN}/tls/tlscacerts/"* "${PWD}/ordererOrganizations/${DOMAIN}/orderers/orderer${ORDERER_NO}.${DOMAIN}/msp/tlscacerts/tlsca.${DOMAIN}-cert.pem"

  mkdir -p "${PWD}/ordererOrganizations/${DOMAIN}/msp/tlscacerts"
  cp "${PWD}/ordererOrganizations/${DOMAIN}/orderers/orderer${ORDERER_NO}.${DOMAIN}/tls/tlscacerts/"* "${PWD}/ordererOrganizations/${DOMAIN}/msp/tlscacerts/tlsca.${DOMAIN}-cert.pem"

  echo "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://orderer${ORDERER_NO}Admin:ordererAdminpw@ca-orderer.${DOMAIN}:9054 --caname ca-orderer.${DOMAIN} -M "${PWD}/ordererOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp" --tls.certfiles "${PWD}/fabric-orderer-ca/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/ordererOrganizations/${DOMAIN}/msp/config.yaml" "${PWD}/ordererOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp/config.yaml"
  
  

