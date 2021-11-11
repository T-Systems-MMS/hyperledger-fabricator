##################
Command-Line
##################
  
**Welcome to Fabric setup utility**



The command works as shown below:
  
.. code-block:: bash
      
  ./fabric-network.sh COMMAND_NAME <ARGS>
  
1. To generate crypto material for this organization use:

  .. code-block:: bash
      
    ./fabric-network.sh generate-crypto

2. To bring up the organization:

  .. code-block:: bash
      
    ./fabric-network.sh up
  
3. To add config of another organization:

  .. code-block:: bash
      
    ./fabric-network.sh add-org-config <CHANNEL_NAME> <ORG_TO_BE_ADDED_NAME>
 
4. To sign config of another organization:

  .. code-block:: bash
      
    ./fabric-network.sh add-org-sign <CHANNEL_NAME> <ORG_TO_BE_SIGNED_NAME>
  
5. To create a channel:

  .. code-block:: bash
      
    ./fabric-network.sh create-channel <CHANNEL_PROFILE> <CHANNEL_NAME>
  
6. To join a peer to a channel:

  .. code-block:: bash
      
    ./fabric-network.sh join-channel-peer <PEER_NO> <CHANNEL_NAME>
  
7. To add another peer:

  .. code-block:: bash
      
    ./fabric-network.sh add-peer
  
8. To add another local orderer of an organization:

  .. code-block:: bash
      
    ./fabric-network.sh add-local-orderer
  
9. To add orderer to a channel: 

  .. code-block:: bash
      
    ./fabric-network.sh join-channel-orderer <ORDERER_NO> <CHANNEL_NAME>
  
10. To add remote orderer of another organization:

  .. code-block:: bash
      
    ./fabric-network.sh add-remote-orderer <ORDERER_NO>
  
11. To publish remote orderer of another organization:

    .. code-block:: bash
      
     ./fabric-network.sh publish-remote-orderer <ORDERER_NO>
  
12. To package a chaincode:

    .. code-block:: bash
      
     ./fabric-network.sh package-cc <CHAINCODE_NAME> <CHAINCODE_LANGUAGE> <CHAINCODE_LABEL>
  
13. To install a chaincode:

    .. code-block:: bash
      
     ./fabric-network.sh install-cc <CHAINCODE_NAME>
  
14. To query whether a chaincode has installed:

    .. code-block:: bash
      
     ./fabric-network.sh query-installed-cc
  
15. To approve a chaincode from your organization:

    .. code-block:: bash
      
     ./fabric-network.sh approve-cc <CHANNEL_NAME> <CHAINCODE_NAME> <VERSION> <PACKAGE_ID> <SEQUENCE>
  
16. To check commit-readiness of a chaincode:

    .. code-block:: bash
      
     ./fabric-network.sh checkcommitreadiness-cc <CHANNEL_NAME> <CHAINCODE_NAME> <VERSION> <SEQUENCE> <OUTPUT>
 
17. To commit a chaincode:

    .. code-block:: bash
      
     ./fabric-network.sh commit-cc <CHANNEL_NAME> <CHAINCODE_NAME> <VERSION> <SEQUENCE>
  
18. To query committed chaincodes on a channel:

    .. code-block:: bash
      
     ./fabric-network.sh query-committed-cc <CHANNEL_NAME>
  
19. To initialize a chaincode:

    .. code-block:: bash
      
     ./fabric-network.sh init-cc <CHANNEL_NAME> <CHAINCODE_NAME>
  
20. To invoke a chaincode:

    .. code-block:: bash
      
     ./fabric-network.sh invoke-function-cc <CHANNEL_NAME> <CHAINCODE_NAME> <FUNCTION> <ARGS>
  
21. To query a chaincode:

    .. code-block:: bash
      
     ./fabric-network.sh query-function-cc <CHANNEL_NAME> <CHAINCODE_NAME> <ARGS>
  
22. To start explorer:

    .. code-block:: bash
      
      ./fabric-network.sh bootstrap-explorer
  
23. To down explorer:

    .. code-block:: bash
      
      ./fabric-network.sh explorer-down
  
24. To display help:

    .. code-block:: bash
      
      ./fabric-network.sh help
  
25. To shut down the organization and cleanup: 

    .. code-block:: bash
      
      ./fabric-network.sh down cleanup

26. To reenroll certificates

    .. code-block:: bash
      
     ./fabric-network.sh reenroll-certificate <identity> <identity_no>

27.  To revoke certificates    

    .. code-block:: bash
      
     ./fabric-network.sh revoke-certificate <identity> <identity_no>
