##################
Single machine for all Organizations
##################


For single machine we need to open 3 terminals and change directory each terminal in the path of each organization. Then we need to create a bridge network using docker upon which this blockchain would be deployed.

The network name in this example is *fabric-template-network*. This can also be configured in the ``fabric-network.sh`` file

.. code-block:: bash

	docker network create fabric-template-network

A demo of single machine for all Orgs is given in ``local-startup.sh`` file. This ``local-startup.sh`` file uses the individual ``fabric-network.sh`` files of each organization that was created by ``generate-org`` command described above. Before using ``local-startup.sh`` please do the following two things:

1.Make sure that the fabric-network.sh files have executable permissions

.. code-block:: bash

	$ chmod +x generated-orgs/{ORG_NAME}/fabric-network.sh

2.Open the ``local-startup.sh`` file and at the top make sure to change the variables {Org1}, {Org2} and {Org3} according to the names of your organizations.

The actual shell tool ``./fabric-network.sh`` can also be well understood by reading the ``local-startup.sh``

A basic network of 1 Orderer, 2 peers for each Org can be bootstrapped and hardcoded channels can be joined in this demo in simple steps.

Run the below command in order to run basic network with 3 organizations.

.. code-block:: bash

	$ ./local-startup.sh bootstrap

Once 3 organizations have been bootstrapped then we can create and join the channels in which these organizations can participate. We have added hardcoded profiles ``ChannelAll`` and ``ChannelAll2`` in ``configtx.yaml`` files of organizations respectively and these channels can be created from their respective organizations and subsequently be joined by other organizations. In simple steps as demonstrated below.


.. code-block:: bash

    $ ./local-startup.sh create-join-channel channelall
    
    $ ./local-startup.sh create-join-channel channelall2

The channel profiles can be configured to have different rules upon which the channel will operate, these rules are very well explained in fabric docs. In our example the profiles ``ChannelAll`` and ``ChannelAll2`` have been configure to have a ``"Majority"`` consensus for Admin operations, hence in order to add a new organization to these channel we need majority organizations in the channel to sign and submit to ledger. In order to make it possible we have kept all 3 Orgs as ordering organizations.

As a counter example we have another channel profile in Org1 i.e. ``ChannelAllANY``. This profiles configures the channel such that ``"ANY"`` organization can do Admin operations and hence the requirement of majority is relaxed. Since we have bootstrapped all 3 Orgs as ordering Orgs and the requirements of channel are relaxed so we can also use this profile to create channels in our on going example.

In short: ``channelall``, ``channelall2`` => ``Majority`` organizations need to sign ``channelallany`` => ``ANY`` organization needs to sign

.. code-block:: bash

    $ ./local-startup.sh create-join-channel channelallany

At this point, you have achieved to create a local network with 3 organizations joined by two channels.

If you do not wish to delve into multi-machine network right now, please skip to chaincode installation section to see how chaincode installation works. Otherwise, please carry on.