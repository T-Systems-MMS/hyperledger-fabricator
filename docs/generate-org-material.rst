Generate organizations
=====

Before we go ahead creating either a local or multi-machine network, we have to first create individual scripts for each organization. To do this easily, we have created a script called generate-org.sh which copies the material from the :file:`./fabric-template` folder and parametrizes it according to each organization.

Make sure you are present in the root directory of the repository:

.. code-block:: bash

	└── ./blockchain-common-fabric-net
    		├── ./blockchain-common-fabric-net/deploy-chaincode.sh
    		├── ./blockchain-common-fabric-net/fabric-dependencies.sh
    		├── ./blockchain-common-fabric-net/fabric-template
    		├── ./blockchain-common-fabric-net/generate-org.sh
    		├── ./blockchain-common-fabric-net/local-startup.sh
    		├── ./blockchain-common-fabric-net/readme.md
    		└── ./blockchain-common-fabric-net/remote-startup.sh


The command to create organization material can be run as:

.. code-block:: bash

    	$ ./generate-org.sh <ORG_NAME> <DOMAIN_NAME> <ORG_NUMBER> <ORG_EXPLORER_PORT>
		
After running the above command, all organization directories should be created inside the :file:`./generated-orgs` directory:

.. code-block:: bash
	
	└── ./blockchain-common-fabric-net
    	├── ./blockchain-common-fabric-net/generated-orgs



As an example we generate an organization called the MMS:

.. code-block:: bash

        $ ./generate-org.sh MMS t-systems.com 1 7040


Therefore you should have created the :file:`./MMS` directory along with the organization scripts that looks like this:

.. code-block:: bash

	generated-orgs
	└── generated-orgs/MMS
		├── generated-orgs/MMS/base
		├── generated-orgs/MMS/chaincode
		├── generated-orgs/MMS/configtx.yaml
		├── generated-orgs/MMS/connection-profile
		├── generated-orgs/MMS/docker-compose-explorer.yaml
		├── generated-orgs/MMS/docker-compose-new-peer.yaml
		├── generated-orgs/MMS/docker-compose-new-raft-orderer.yaml
		├── generated-orgs/MMS/docker-compose-orderer-ca.yaml
		├── generated-orgs/MMS/docker-compose-org-ca.yaml
		├── generated-orgs/MMS/docker-compose.yaml
		├── generated-orgs/MMS/explorer-config.json
		├── generated-orgs/MMS/fabric-network.sh
		├── generated-orgs/MMS/fabric-orderer-ca
		├── generated-orgs/MMS/fabric-org-ca
		├── generated-orgs/MMS/initial-configtx.yaml
		└── generated-orgs/MMS/scripts


You can create as many organizations you want in the similar fashion as mentioned above.  

.. note::

	Once organzations have been generated, each organization can be manipulated using the :file:`fabric-network.sh` script present inside each
	organzation folder as shown in the example above for the organization called **MMS**.

