##################
Organizations in a distributed setup
##################

Now, we are moving forward to part 2 of this tutorial i.e. creation of a multi-machine network.

In this case we would have multiple machines where each machine would run the containers of 1 Org. So for 3 Orgs we would have 3 machines, depicting a realworld setting where each organization would run it's own nodes in it's own physical infrastructure. In order to communicate with each other, the machines need an overlay network. In our example, we are using a docker swarm overlay network for this purpose.

The machines need to join a docker swarm as manager for equal control. One organization would initialize the docker swarm using:


.. code-block:: bash

	docker swarm init

This machine is the first manager of docker swarm. Running this command at base manager gives you exact command that can be used by other machines to join this docker swarm infrastructure.

.. code-block:: bash

	docker swarm join-token manager

Now run the resulting command at each each machine for them to join this docker swarm as manager.

Once all the machines are docker swarm managers we can create a shared overlay network that all of them would use for this blockchain. Run this command from any of the machines.

.. code-block:: bash

	docker network create --driver overlay --attachable {fabric-template-network}

This network can be verified at all machines using

.. code-block:: bash

	docker network ls

Now that the *fabric-template-network* network has been set up at single machine/multiple machines we can bootstrap our fabric network.




