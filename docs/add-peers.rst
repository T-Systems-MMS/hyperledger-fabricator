##################
Adding Peers
##################

The following commands can run from any organization as required:

To add a new peer

.. code-block:: bash

	$ ./fabric-network.sh add-peer


.. note::

	If need be, you can join this newer peer to the existing channel by changing the peer number using the command given below.

To join the newer peer to existing channel:

.. code-block:: bash
 
 	./fabric-network.sh join-channel-peer <PEER_NO> <CHANNEL_NAME>

For example if you want join *peer number 2* to the channel called *channelall*

.. code-block:: bash
    	
	$ ./fabric-network.sh join-channel-peer 2 channelall