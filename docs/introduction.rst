##################
Introduction
##################
The Hyperledger Fabric network can get too complicated to set up and scale. 
Organizations that want to participate in a consortium or in a permissioned network generally would want that 
bootstrapping and managing such a network should be a simple and hassle-free task. They would want to bring up
the network and its components without understanding and being involved in depth of the technical details.
Fabricator enables this.   

*****************
What is Fabricator?
*****************
Fabricator is a tool that can setup and bootstrap the fabric network, bring up organizations and make them join the network with just a single command.
It provides a generic template that contains script that are tailored in a way which makes it simple for organizations to configure
the network according to their own needs. It enables scaling a running fabric network by allowing the dynamic addition of new network components, users and organizations.
It is well suited for production environments since it uses the Fabric-CA server for certificate generation, rotation and revocation.   

*****************
How does Fabricator works?
*****************
In order to understand how Fabricator works, it is essential to understand its design.
Currently it is designed for 3 organizations and it can be easily scaled to more organizations.

=================
Certificate authorities for organizations and orderers
=================
In order to generate the certificates for the orderers of all organizations there is a single `Orderer CA Server` container running, called ``ca-orderer.t-systems.com`` . 
This is the first container that should be up when we bootstrap the network.
This Orderer CA Server generates the crypto material and subsequently the certificates for the orderers of the first organization using the configuration present in the ``fabric-ca-server-config.yaml`` which is located inside the folder ``fabric-orderer-ca``.
The crypto material along with the certificates is also generated inside the folder ``fabric-orderer-ca``.
After this, ``fabric-orderer-ca`` is copied to every new organization, which means that the Orderer CA Server uses the crypto material of the first organization in order to generate the certificates for the orderers of each organization.
This explains why we have a single Orderer CA Server for the orderers of all organizations.
Each organization has their own CA server that is responsible to generate their certificates.
Therefore, there is a CA Server container running for every organization and should be the first container that should be up when we bootstrap the organization.
For example for an ``organization 1`` we have the `organization CA Server` container called ``ca-org.organization1.t-systems.com``.
Since in our current tutorial is for 3 organizations, this means there are 3 CA's for 3 organizations in a similar fashion as described above.   

=================
General design
=================
Each organization has its own containers and can be deployed separately in their own machines. All the services/containers are divided in domains of their parent organization i.e. ``peer.org1.example.com`` , ``peer.org2.example.com`` etc except for orderers. Because of fabric design the orderers can not be divided in domains and they all belong to their own membership service provider i.e. OrdererMSP. Each organization has reservation of 10 orderers each. In our example Org1 has reservation from 0 to 9, Org2 has reservation from 10 to 19 and Org3 has reservation from 20 to 29 and so on and so forth.
Orgs have their own base orderer (orderer0. for Org1, orderer1. for Org2 etc). The organizations join the system channel using their respective orderers and can also add their own local orderer nodes (maximum 10).
Initially each organization has 1 orderer, 2 peers ; More peers and orderers can be dynamically added by following the steps below.
We have provided demos to play around with this tool in 2 ways:
Local setup: Setup a local 3 organization network on a single machine.
Multi-machine setup: Setup a multi-organization network running on separate machines.
A basic guide and tutorial for both these ways are explained below.