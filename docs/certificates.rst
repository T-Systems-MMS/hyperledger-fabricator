##################
Certificate reenrollment & revocation  
##################
A permissioned blockchain requires that an entity, be it a network user (client), an admin, or a network component (peers or orderers), must be identified and permissioned before accessing a consortium network.
Every entity in the network is granted some digital certificates in order for them to be able to identify themselves as an identity in the network. These digital certificates are generated along with some other
crypto material. There are two ways to generate crypto materials in Hyperledger Fabric: **Cryptogen and CA (Certificate Authority) Server**.

Fabricator uses the CA server, particularly the Hyperledger Fabric CA, in order to generate the crypto material. 
A detailed documentation about the Fabric CA can be found in `Fabric CA User's Guide`_.

.. note::

    With respect to the arguments ``<identity>`` and ``<identity_no>`` for the commands given below, an ``identity`` can be a *user, admin, peer* or an *orderer* for which you may want to reenroll or revoke certificates.
    Since Fabricator allows you to add as many *users, admins*, new *peers* you may want and up to *10 orderers* dynamically, the ``identity_no`` is to indicate which *identity* you want
    to address. For example: *peer 1* or *orderer 6*.

Renew enrollment certificate
##############
In case if the enrollment certificate has been expired or compromised, it can be renewed using the following command:

.. code-block:: bash
        
	    $ ./fabric-network.sh reenroll-certificate <identity> <identity_no>
 

Revoke a certificate or identity
##############

Revoking an identity will revoke all the certificates owned by the identity and will also prevent the identity from getting any new certificates.
Revoking a certificate will invalidate a single certificate. An identity or a certificate can be revoked using the following command:

.. code-block:: bash
        
	    $ ./fabric-network.sh revoke-certificate <identity> <identity_no>        


.. _Fabric CA User's Guide: https://hyperledger-fabric-ca.readthedocs.io/en/release-1.4/users-guide.html#fabric-ca-user-s-guide