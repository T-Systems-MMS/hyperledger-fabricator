# Template for Fabric Network

This is effort to create a generic template for a reproducible fabric network, that can be configured for various requirements with minimal effort. Currently it is designed for 3 Organizations and it can be easily scaled to more Organizations. Each Organization has its own containers and can be deployed separately in their own machines. All the services/containers are divided in domains of their parent organization i.e. peer.org1.example.com , peer.org2.example.com etc except for orderers. Because of fabric design the orderers can not be divided in domains and they all belong to their own membership service provider i.e. OrdererMSP. Each organization has reservation of 10 orderers each. In our example Org1 has reservation from 0 to 9, Org2 has reservation from 10 to 19 and Org3 has reservation from 20 to 29 and so on and so forth. 

Orgs have their own base orderer (orderer0.<domain> for Org1, orderer1.<domain> for Org2 etc). The organizations join the system channel using their respective orderers and can also add their own local orderer nodes (maximum 10).

Initially each organization has 1 orderer, 2 peers ; More peers and orderers can be dynamically added by following the steps below.

We have provided demos to play around with this tool in 2 ways:

1. Local setup: Setup a local 3 organization network on a single machine.

2. Multi-machine setup: Setup a multi-organization network running on separate machines. 

A basic guide and tutorial for both these ways are explained below. 

## Linux

### Prerequisites

1.Fabric Dependencies can be downloaded to start a new fabric network v2.0.1 from scratch using this command

	./fabric-dependencies.sh -s -- <fabric_version> <fabric-ca_version> <thirdparty_version>
	./fabric-dependencies.sh -s -- 2.0.1 1.4.6 0.4.18
 
2.Install yq, details to install yq are can be found here:

	https://github.com/mikefarah/yq#install
 

### Network Setup 

Our example includes 3 organizations, each generates their crypto material individually stored in their independent folders (in case of local setup)or in their independent machines (in case of multi-machine setup).

Each organization joins the channel and deploy chaincode on it. We will make each organization join our network one by one.

The containers in this example can be deployed in single machine containing all 3 orgs or 3 distinct machines (1 for each org) which are in the same network. 


#### Generating org material
Before we go ahead creating either a local or multi-machine network, we have to first create individual scripts for each organization. To do this easily, we have created a script called generate-org which copies the material from /fabric-template folder (see the code above) and parametrizes it according to each organization.

The command to create org material can be run as:
	
		./generate-org.sh {ORG_NAME} {DOMAIN_NAME} {ORG_NUMBER} {ORG_EXPLORER_PORT}

Run this command for each organization (either in the same machine or in separate machines). This command would also download and resolve dependencies if not done already. For more information on dependencies, see the next section.  

#### Single machine for all Orgs

For single machine we need to open 3 terminals and change directory each terminal in the path of each organization. Then we need to create a bridge network using docker upon which this blockchain would be deployed. 

The network name in this example is "fabric-template-network". This can also be configured in the fabric-network.sh file
	
		docker network create fabric-template-network

A demo of single machine for all Orgs is given in local-startup.sh file. This local-startup.sh file uses the individual fabric-network.sh files of each organization that was created by generate-org command described above. Before using local-startup.sh please do the following two things:

1.Make sure that the fabric-network.sh files have executable permissions

		chmod +x generated-orgs/{ORG_NAME}/fabric-network.sh

2.Open the local-startup.sh file and at the top make sure to change the variables {Org1}, {Org2} and {Org3} according to the names of your organizations. 

The actual shell tool ./fabric-network.sh can also be well understood by reading the local-startup.sh 

A basic network of 1 Orderer, 2 peers for each Org can be bootstrapped and hardcoded channels can be joined in this demo in simple steps.

Run the below command in order to run basic network with 3 organizations. 

		1. ./local-startup.sh bootstrap

Once 3 organizations have been bootstrapped then we can create and join the channels in which these organizations can participate. We have added hardcoded profiles ChannelAll and ChannelAll2 in configtx.yaml files of organizations respectively and these channels can be created from their respective organizations and subsequently be joined by other organizations. In simple steps as demonstrated below.

		2. ./local-startup.sh create-join-channel channelall
		3. ./local-startup.sh create-join-channel channelall2

The channel profiles can be configured to have different rules upon which the channel will operate, these rules are very well explained in fabric docs. In our example the profiles ChannelAll and ChannelAll2 have been configure to have a "Majority" consensus for Admin operations, hence in order to add a new organization to these channel we need majority organizations in the channel to sign and submit to ledger. In order to make it possible we have kept all 3 Orgs as ordering organizations. 

As a counter example we have another channel profile in Org1 i.e. ChannelAllANY. This profiles configures the channel such that "ANY" organization can do Admin operations and hence the requirement of majority is relaxed. Since we have bootstrapped all 3 Orgs as ordering Orgs and the requirements of channel are relaxed so we can also use this profile to create channels in our on going example.

In short: channelall, channelall2 => Majority organizations need to sign
		  channelallany => ANY organization needs to sign

		4. ./local-startup.sh create-join-channel channelallany

At this point, you have achieved to create a local network with 3 organizations joined by two channels.

If you do not wish to delve into multi-machine network right now, please skip to chaincode installation section to see how chaincode installation works. Otherwise, please carry on. 

#### Single machine for each Org (Setting up docker swarm)

Now, we are moving forward to part 2 of this tutorial i.e. creation of a multi-machine network. 

In this case we would have multiple machines where each machine would run the containers of 1 Org. So for 3 Orgs we would have 3 machines, depicting a realworld setting where each organization would run it's own nodes in it's own physical infrastructure. In order to communicate with each other, the machines need an overlay network. In our example, we are using a docker swarm overlay network for this purpose.  

The machines need to join a docker swarm as manager for equal control. One organization would initialize the docker swarm using: 

		docker swarm init

This machine is the first manager of docker swarm. Running this command at base manager gives you exact command that can be used by other machines to join this docker swarm infrastructure. 

		docker swarm join-token manager

Now run the resulting command at each each machine for them to join this docker swarm as manager. 

Once all the machines are docker swarm managers we can create a shared overlay network that all of them would use for this blockchain. Run this command from any of the machines.

		docker network create --driver overlay --attachable {fabric-template-network}

This network can be verified at all machines using 
	
		docker network ls

Now that {fabric-template-network} network has been set up at single machine/multiple machines we can bootstrap our fabric network.

### Bootstrap

The bootstrap process brings up the required containers for each organization. This bootstrap process for local setup is already done in local-startup.sh script. For bootstrapping network with organizations on separate machines, we have a script remote-startup.sh.

You can run the script remote-startup.sh from a single machine (Org1) after you have generated-org for each organization on individual machines. 
Please update the variables at the top of remote-startup.sh with appropriate endpoints for each organization's machine. 

Run the below command from Org1 in order to run basic network with 3 organizations. 

		1. ./remote-startup.sh bootstrap

Once 3 organizations have been bootstrapped then we can create and join the channels in which these organizations can participate. We have added hardcoded profiles ChannelAll, ChannelAll2, ChannelAllANY in configtx.yaml files of organizations respectively and these channels can be created from their respective organizations and subsequently be joined by other organizations. In simple steps as demonstrated below.

		2. ./remote-startup.sh create-join-channel channelall
		3. ./remote-startup.sh create-join-channel channelall2
		4. ./remote-startup.sh create-join-channel channelallany

As explained previously: channelall, channel2 => Majority organizations need to sign
		  				 channelallany => ANY organization needs to sign

At this point, you have achieved to create a remote network with 3 organizations joined by two channels.

If you want to do all these steps manually which are inside remote-startup.sh, the commands are explained below.

For the basic tutorial on setting up 3 organizations, use the following commands:

This series of commands is an interactive process between the organizations so please follow the instructions in the sequence in which they are numbered.

#### ORG 1

To read all the help regarding commands use: ./fabric-network.sh help

To start

		1. ./fabric-network.sh generate-crypto
		2. ./fabric-network.sh up

To bootstrap Org2 from Org1

		4. ./fabric-network.sh add-remote-orderer 10

		In above command 10 refers to orderer number. Since we are bootstrapping Org2's base orderer it is 10, it should be 20 for Org3 and so on..
		As a result of this command for base orderer10 a genesis file will be generated in channel-artifacts folder i.e. channel-artifacts/orderer_genesis.pb
		Next step: Copy the channel-artifacts/orderer_genesis.pb into channel-artifacts/orderer_genesis.pb of the Org2 

		6. ./fabric-network.sh publish-remote-orderer 10

		The above command ensures that the base orderer of Org2 is published and now peers can contact this as an active orderer in the network. 
		This command must be run after the containers of Org2 are up and running
	
#### ORG 2

To start bootstraping Org2, Copy the shared orderer certificates (OrdererSharedCerts folder) from first organization's channel-artifact folder in Org2 i.e. Org2/OrdererSharedCerts. Once the shared certificates are placed as required run following commands.

		3. ./fabric-network.sh generate-crypto
	
		This command generates 2 important files for bootstrapping
		(1) A json file i.e. ./channel-artifacts/Org2.json that contains the Org2 MSP certificates required to join this Org to any channel at any time
		(2) A crt file i.e. ./channel-artifacts/orderer10.crt that contains public certificates of Org2's base orderer required to add this base orderer into system channel to bootstrap
		As a next step copy the ./channel-artifacts/orderer10.crt into channel-artifacts folder of Org1 so that it can bootstrap Org2's base orderer in system channel

In step 4 a genesis file would have been generated in Org1/channel-artifacts/orderer_genesis.pb copy this file to Org2/channel-artifacts/orderer_genesis.pb and then run the following command to start the containers
		5. ./fabric-network.sh up

After the containers of Org2 are up, publish it's orderer details by running the command in step 6.

To Bootstrap Org3 from Org2

		8. ./fabric-network.sh add-remote-orderer 20

		In above command 20 refers to orderer number. Since we are bootstrapping Org3's base orderer it is 20, it should be 30 for Org4 and so on..
		As a result of this command for base orderer20, a genesis file will be generated in channel-artifacts folder i.e. channel-artifacts/orderer_genesis.pb
		Next step: Copy the channel-artifacts/orderer_genesis.pb into channel-artifacts/orderer_genesis.pb of the Org3 

		10. ./fabric-network.sh publish-remote-orderer 20

		The above command ensures that the base orderer of Org3 is published and now peers can contact this as an active orderer in the network. 
		This command must be run after the containers of Org3 are up and running

#### ORG 3

To start bootstraping Org3, Copy the shared orderer certificates (OrdererSharedCerts folder) from first/2nd organization's channel-artifact folder in Org3 i.e. Org3/OrdererSharedCerts. Once the shared certificates are placed as required run following commands.

		7. ./fabric-network.sh generate-crypto 

		This command generates 2 important files for bootstrapping
		(1) A json file i.e. ./channel-artifacts/Org3.json that contains the Org3 MSP certificates required to join this Org to any channel at any time
		(2) A crt file i.e. ./channel-artifacts/orderer20.crt that contains public certificates of Org3's base orderer required to add this base orderer into system channel to bootstrap
		As a next step copy the ./channel-artifacts/orderer20.crt into channel-artifacts folder of Org2 so that it can bootstrap Org3's base orderer in system channel

In step 8 a genesis file would have been generated in Org2/channel-artifacts/orderer_genesis.pb copy this file to Org3/channel-artifacts/orderer_genesis.pb and then run the following command to start the containers
		9. ./fabric-network.sh up 

After the containers of Org3 are up, publish it's orderer details by running the command in step 10.

### Channel Creation & Joining

For the basic tutorial on creating and joining on a channel use the following commands:

Please follow the instructions in the sequence in which they are numbered.

#### ORG 1

To create a channel run following command. This commands creates the channel from achor peer i.e. peer0 and also join it this new channel.

		1. ./fabric-network.sh create-channel ChannelAll channelall

To Add Org 2 configuration in the channel copy Org2.json file in channel-artifacts folder of Org1 and run following commands. Usually add-org-config and add-org-sign are supposed to run from 2 different Orgs (depending upon channel configuration in configtx.yaml), but in this case since we only have Org1 currently added in this channel we can make an exception and add & sign both from Org1. But it would not be possible if there are more than 1 Orgs on a particular channel.

		2. ./fabric-network.sh add-org-config channelall Org2
		3. ./fabric-network.sh add-org-sign channelall Org2

		The channel channelall has been updated with the new organization and new genesis block is now added in ./channel-artifacts/channelall.block file
		Copy this file ./channel-artifacts/channelall.block in new organization's channel-artifacts and join this channel from Org2
	
To Sign Org 3 configuration added by Org2 in step 5, copy channel-artifacts/Org3_update_in_envelope.pb file in channel-artifacts and run following command

		6. ./fabric-network.sh add-org-sign channelall Org3

		The channel channelall has been updated with the new organization and new genesis block is now added in ./channel-artifacts/channelall.block file
		Copy this file ./channel-artifacts/channelall.block in new organization's channel-artifacts and join this channel from anchor peer cli

#### ORG 2

To join a channel by anchor peer i.e. peer0 of Org2 whose configuration is already added and signed, copy <channelall>.block file from Org1 in channel-artifacts folder and run the following command. You can run this command for each peer of Org2 to join the channel by changing peer<number> in the argument.

		4. ./fabric-network.sh join-channel peer0 channelall

To Add Org 3 configuration in the channel copy Org3.json file in channel-artifacts folder of Org2 and run following commands. Now add-org-config and add-org-sign would from 2 different Orgs (depending upon channel configuration in configtx.yaml), as now there are more than 2 Orgs on channelall.

		5. ./fabric-network.sh add-org-config channelall Org3

		(1) The new organization configuration for this channel is exported in channel-artifacts/Org3_update_in_envelope.pb file
		(2) Copy channel-artifacts/Org3_update_in_envelope.pb file in channel-artifacts folder of any other Org in this channel i.e. Org1
		(3) run ./fabric-network add-org-sign from any other organization on this channel to sign this configuration and commit to ledger i.e. Org1

#### ORG 3  

To join a channel by anchor peer i.e. peer0 of Org3 whose configuration is already added and signed, copy <channelall>.block file from Org1 in channel-artifacts folder and run the following command. You can run this command for each peer of Org3 to join the channel by changing peer<number> in the argument.

		7. ./fabric-network.sh join-channel peer0 channelall

### Adding Peers

The following commands can run from any organization as required:

To add a new peer

		./fabric-network.sh add-peer

To join the newer peer to existing channel

	If need be, you can join this newer peer to the existing using the join-channel-peer command by changing the peer <number> as required
		
		./fabric-network.sh join-channel-peer 2 channelall

### Adding Orderers

The following commands can run from any organization as required:

To add a new orderer

		./fabric-network.sh add-local-orderer

To join the newer orderer to existing channel

	If need be, you can join this newer orderer to the existing using the join-channel-orderer command by changing the orderer <number> as required
		
		./fabric-network.sh join-channel-orderer 1 channelall

### Chaincode Deployment & Invocation

Our chaincode needs to be deployed on the channel by one participant and the others need to approve it before it can be committed. The number of participants whose approval is needed is dependent on the endorsement policy, it could be ANY, MAJORITY or ALL. 

For our example, we are approving via every organization. The chaincode example that is being deployed is fabcar which needs to be present in the chaincode folder inside each organization. This chaincode folder is mounted in docker container. 

For easy chaincode deployments, we have created a script (deploy-chaincode.sh) to easily approve and deploy chaincode. The script has to be run once for each organization (in parallel). Only 1 organization would commit the chaincode (we call this organization COMMITTER_OF_CHAINCODE), all the organizations would only approve. This script was written to be used with Jenkins for chaincode CI/CD but can be used for local/remote installations as well by running the script with appropriate parameters.  

Please open 3 terminal instances and cd into the folder where we have deploy-chaincode.sh file.  
		
		./deploy-chaincode.sh {COMMITTER_OF_CHAINCODE} {ORGANIZATION_RUNNING_SCRIPT} {CHANNEL_NAME} {VERSION} {SEQUENCE} 

For this example, please run the commands for the 3 orgs like this (either on the same machine or on different machines):
	
		./deploy-chaincode.sh {Org1} {Org1} channelall 1 1 
		./deploy-chaincode.sh {Org1} {Org2} channelall 1 1 
		./deploy-chaincode.sh {Org1} {Org3} channelall 1 1 

Please make sure that the committer of chaincode is the same in all 3 orgs since this organization would be committing the chaincode, the rest will only approve. 

If you want to do all the steps manually one by one, please follow the instructions as they are numbered. 

To get help regarding the commands use: ./fabric-network.sh help

#### ORG 1

To package the chaincode 

		1. ./fabric-network.sh package-cc fabcar golang 1

To install the chaincode 

		4. ./fabric-network.sh install-cc fabcar

To query the installed chaincode [OPTIONAL]

		7. ./fabric-network.sh query-installed-cc 

Copy the package id you get here. It will be used in the the next commands

To approve a chaincode
	
	Update the package id (long string) with the package id you get in previous command
	
		10. ./fabric-network.sh approve-cc channelall fabcar 1 1:a413310bd764d0e4bfdbe988646b6081f6fcc80c865abd51a1cbc4b570a5feb2 1 

To check commit readiness [OPTIONAL]

		13. ./fabric-network.sh checkcommitreadiness-cc channelall fabcar 1 1 json

To commit a chaincode

		16. ./fabric-network.sh commit-cc channelall fabcar 1 1 

This command would fail if you haven't got required approvals from the organizations

To query a committed chaincode [OPTIONAL]

		17. ./fabric-network.sh query-committed-cc channelall

To initialize a chaincode

		20. ./fabric-network.sh init-cc channelall fabcar

To invoke the fabcar chaincode function

		21. ./fabric-network.sh invoke-function-cc channelall fabcar initLedger

To query the fabcar chaincode function [OPTIONAL]

		22. ./fabric-network.sh query-function-cc channelall fabcar queryAllCars

To invoke a fabcar chaincode function that changes the car owner

		25. ./fabric-network.sh invoke-function-cc channelall fabcar changeCarOwner \"CAR9\",\"XOXO\" 

Invoke functions can be called from any organizations and all other orgs can see the state changes

To query whether the state change has been reflected [OPTIONAL]

		26. ./fabric-network.sh query-function-cc channelall fabcar queryAllCars

#### ORG 2

To package the chaincode 

		2. ./fabric-network.sh package-cc fabcar golang 1

To install the chaincode 

		5. ./fabric-network.sh install-cc fabcar

To query the installed chaincode [OPTIONAL]

		8. ./fabric-network.sh query-installed-cc 

Copy the package id you get here. It will be used in the the next commands

To approve a chaincode

		11. ./fabric-network.sh approve-cc channelall fabcar 1 1:a413310bd764d0e4bfdbe988646b6081f6fcc80c865abd51a1cbc4b570a5feb2 1

To check commit readiness [OPTIONAL]

		14. ./fabric-network.sh checkcommitreadiness-cc channelall fabcar 1 1 json 

Update the package id (long string) with the package id you get in previous command

To query a committed chaincode [OPTIONAL]

		18. ./fabric-network.sh query-committed-cc channelall

To query the fabcar chaincode function [OPTIONAL]

		23. ./fabric-network.sh query-function-cc channelall fabcar queryAllCars

To query whether the state change has been reflected [OPTIONAL]

		27. ./fabric-network.sh query-function-cc channelall fabcar queryAllCars


#### ORG 3

To package the chaincode 

		3. ./fabric-network.sh package-cc fabcar golang 1

To install the chaincode 

		6. ./fabric-network.sh install-cc fabcar

To query the installed chaincode [OPTIONAL]

		9. ./fabric-network.sh query-installed-cc 

Use the package id you get here in the next commands.

To approve a chaincode

		12. ./fabric-network.sh approve-cc channelall fabcar 1 1:a413310bd764d0e4bfdbe988646b6081f6fcc80c865abd51a1cbc4b570a5feb2 1

To check commit readiness [OPTIONAL]

		15. ./fabric-network.sh checkcommitreadiness-cc channelall fabcar 1 1 json 

Update the package id (long string) with the package id you get in previous command

To query a committed chaincode [OPTIONAL]

		19. ./fabric-network.sh query-committed-cc channelall

To query the fabcar chaincode function [OPTIONAL]

		24. ./fabric-network.sh query-function-cc channelall fabcar queryAllCars

To query whether the state change has been reflected [OPTIONAL]

		28. ./fabric-network.sh query-function-cc channelall fabcar queryAllCars

### Down & Cleanup

The following commands can run from any organization as required:

To bring down, cleanup and restore the initial state of configuration files please run the following command

		./fabric-network.sh down cleanup restore

