##################
Adding Orderers
##################

The following commands can run from any organization as required:

To add a new orderer

.. code-block:: bash

	$ ./fabric-network.sh add-local-orderer

.. note::

	If need be, you can join this newer orderer to the existing channel using the command given below, by changing the orderer number as required.

To join the newer peer to existing channel:

.. code-block:: bash

	./fabric-network.sh join-channel-orderer <ORDERER_NO> <CHANNEL_NAME>

For example if you want join *orderer number 1* to the channel called *channelall*

.. code-block:: bash
    
	$ ./fabric-network.sh join-channel-orderer 1 channelall