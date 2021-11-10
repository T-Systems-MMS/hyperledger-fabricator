##################
Easy chaincode deployments with CI/CD 
##################

For easy chaincode deployments, we have created a script (``deploy-chaincode.sh``) to easily approve and deploy chaincode. The script has to be run once for each organization (in parallel). Only 1 organization would commit the chaincode (we call this organization ``COMMITTER_OF_CHAINCODE``), all the organizations would only approve. This script was written to be used with Jenkins for chaincode CI/CD but can be used for local/remote installations as well by running the script with appropriate parameters.


If you want to do all the steps manually one by one yourself rather than using our script, please skip to the next section.

Please open 3 terminal instances and cd into the folder where we have ``deploy-chaincode.sh`` file.


.. code-block:: bash

	    $ ./deploy-chaincode.sh {COMMITTER_OF_CHAINCODE} {ORGANIZATION_RUNNING_SCRIPT} {CHANNEL_NAME} {VERSION} {SEQUENCE} 

For this example, please run the commands for the 3 orgs like this (either on the same machine or on different machines):


.. code-block:: bash

        $ ./deploy-chaincode.sh {Org1} {Org1} channelall 1 1 
	
        $ ./deploy-chaincode.sh {Org1} {Org2} channelall 1 1 
	
        $ ./deploy-chaincode.sh {Org1} {Org3} channelall 1 1 

Please make sure that the committer of chaincode is the same in all 3 orgs since this organization would be committing the chaincode, the rest will only approve.
