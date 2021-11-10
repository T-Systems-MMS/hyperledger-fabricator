##################
Chaincode Deployment & Invocation
##################


Our chaincode needs to be deployed on the channel by one participant and the others need to approve it before it can be committed. The number of participants whose approval is needed is dependent on the endorsement policy, it could be ``ANY``, ``MAJORITY`` or ``ALL``.

For our example, we are approving via every organization. The chaincode example that is being deployed is ``fabcar`` which needs to be present in the ``chaincode`` folder inside each organization. This ``chaincode`` folder is mounted in docker container.


To get help regarding the commands use: ./fabric-network.sh help

Organization 1
##############

To package the chaincode

.. code-block:: bash

	    $ ./fabric-network.sh package-cc fabcar golang 1

To install the chaincode

.. code-block:: bash

	    $ ./fabric-network.sh install-cc fabcar

To query the installed chaincode [OPTIONAL]

.. code-block:: bash

	    $ ./fabric-network.sh query-installed-cc 

Copy the package id you get here. It will be used in the the next commands

To approve a chaincode

.. code-block:: bash

	    $ ./fabric-network.sh query-installed-cc

            Update the package id (long string) with the package id you get in previous command

	    $ ./fabric-network.sh approve-cc channelall fabcar 1 1:a413310bd764d0e4bfdbe988646b6081f6fcc80c865abd51a1cbc4b570a5feb2 1 

To check commit readiness [OPTIONAL]

.. code-block:: bash

	    $ ./fabric-network.sh checkcommitreadiness-cc channelall fabcar 1 1 json

To commit a chaincode

.. code-block:: bash

        $ ./fabric-network.sh commit-cc channelall fabcar 1 1 

This command would fail if you haven't got required approvals from the organizations

To query a committed chaincode [OPTIONAL]

.. code-block:: bash

	    $ ./fabric-network.sh query-committed-cc channelall

To initialize a chaincode

.. code-block:: bash

	    $ ./fabric-network.sh init-cc channelall fabcar



To invoke the fabcar chaincode function

.. code-block:: bash
        
        $ ./fabric-network.sh invoke-function-cc channelall fabcar initLedger

To query the fabcar chaincode function [OPTIONAL]

.. code-block:: bash
        
	    $ ./fabric-network.sh query-function-cc channelall fabcar queryAllCars

To invoke a fabcar chaincode function that changes the car owner

.. code-block:: bash
        
	    $ ./fabric-network.sh invoke-function-cc channelall fabcar changeCarOwner \"CAR9\",\"XOXO\" 

Invoke functions can be called from any organizations and all other orgs can see the state changes

To query whether the state change has been reflected [OPTIONAL]

.. code-block:: bash
        
	    $ ./fabric-network.sh query-function-cc channelall fabcar queryAllCars


Organization 2
##############

To package the chaincode

.. code-block:: bash

	    $ ./fabric-network.sh package-cc fabcar golang 1



To install the chaincode

.. code-block:: bash

	    $ ./fabric-network.sh install-cc fabcar

To query the installed chaincode [OPTIONAL]

.. code-block:: bash

	    $ ./fabric-network.sh query-installed-cc 

Copy the package id you get here. It will be used in the the next commands

To approve a chaincode

.. code-block:: bash

	    $ ./fabric-network.sh approve-cc channelall fabcar 1 1:a413310bd764d0e4bfdbe988646b6081f6fcc80c865abd51a1cbc4b570a5feb2 1


To check commit readiness [OPTIONAL]

.. code-block:: bash

	    $ ./fabric-network.sh checkcommitreadiness-cc channelall fabcar 1 1 json

Update the package id (long string) with the package id you get in previous command

To query a committed chaincode [OPTIONAL]

.. code-block:: bash

	    $ ./fabric-network.sh query-committed-cc channelall    


To query the fabcar chaincode function [OPTIONAL]

.. code-block:: bash
        
	    $ ./fabric-network.sh query-function-cc channelall fabcar queryAllCars


To query whether the state change has been reflected [OPTIONAL]

.. code-block:: bash
        
	    $ ./fabric-network.sh query-function-cc channelall fabcar queryAllCars



Organization 3
##############

To package the chaincode

.. code-block:: bash

	    $ ./fabric-network.sh package-cc fabcar golang 1



To install the chaincode

.. code-block:: bash

	    $ ./fabric-network.sh install-cc fabcar

To query the installed chaincode [OPTIONAL]

.. code-block:: bash

	    $ ./fabric-network.sh query-installed-cc  

Use the package id you get here in the next commands.

To approve a chaincode

.. code-block:: bash

	    $ ./fabric-network.sh approve-cc channelall fabcar 1 1:a413310bd764d0e4bfdbe988646b6081f6fcc80c865abd51a1cbc4b570a5feb2 1


To check commit readiness [OPTIONAL]

.. code-block:: bash

	    $ ./fabric-network.sh checkcommitreadiness-cc channelall fabcar 1 1 json 

Update the package id (long string) with the package id you get in previous command

To query a committed chaincode [OPTIONAL]

.. code-block:: bash

	    $ ./fabric-network.sh query-committed-cc channelall    


To query the fabcar chaincode function [OPTIONAL]

.. code-block:: bash
        
	    $ ./fabric-network.sh query-function-cc channelall fabcar queryAllCars


To query whether the state change has been reflected [OPTIONAL]

.. code-block:: bash
        
	    $ ./fabric-network.sh query-function-cc channelall fabcar queryAllCars











