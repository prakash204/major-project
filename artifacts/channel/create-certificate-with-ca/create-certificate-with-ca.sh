createcertificatesForOrg1() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/peerOrganizations/org1.private.com/
  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/org1.private.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7154 --caname ca.org1.private.com --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7154-ca-org1-private-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7154-ca-org1-private-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7154-ca-org1-private-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7154-ca-org1-private-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/org1.private.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
  fabric-ca-client register --caname ca.org1.private.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  echo
  echo "Register user"
  echo
  fabric-ca-client register --caname ca.org1.private.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  echo
  echo "Register the org admin"
  echo
  fabric-ca-client register --caname ca.org1.private.com --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  mkdir -p ../crypto-config/peerOrganizations/org1.private.com/peers

  # -----------------------------------------------------------------------------------
  #  Peer 0
  mkdir -p ../crypto-config/peerOrganizations/org1.private.com/peers/peer0.org1.private.com

  echo
  echo "## Generate the peer0 msp"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7154 --caname ca.org1.private.com -M ${PWD}/../crypto-config/peerOrganizations/org1.private.com/peers/peer0.org1.private.com/msp --csr.hosts peer0.org1.private.com --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/org1.private.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/org1.private.com/peers/peer0.org1.private.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7154 --caname ca.org1.private.com -M ${PWD}/../crypto-config/peerOrganizations/org1.private.com/peers/peer0.org1.private.com/tls --enrollment.profile tls --csr.hosts peer0.org1.private.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/org1.private.com/peers/peer0.org1.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/org1.private.com/peers/peer0.org1.private.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/org1.private.com/peers/peer0.org1.private.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/org1.private.com/peers/peer0.org1.private.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/org1.private.com/peers/peer0.org1.private.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/org1.private.com/peers/peer0.org1.private.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/org1.private.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/org1.private.com/peers/peer0.org1.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/org1.private.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/org1.private.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/org1.private.com/peers/peer0.org1.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/org1.private.com/tlsca/tlsca.org1.private.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/org1.private.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/org1.private.com/peers/peer0.org1.private.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/org1.private.com/ca/ca.org1.private.com-cert.pem

  # --------------------------------------------------------------------------------------------------

  mkdir -p ../crypto-config/peerOrganizations/org1.private.com/users
  mkdir -p ../crypto-config/peerOrganizations/org1.private.com/users/User1@org1.private.com

  echo
  echo "## Generate the user msp"
  echo
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7154 --caname ca.org1.private.com -M ${PWD}/../crypto-config/peerOrganizations/org1.private.com/users/User1@org1.private.com/msp --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  mkdir -p ../crypto-config/peerOrganizations/org1.private.com/users/Admin@org1.private.com

  echo
  echo "## Generate the org admin msp"
  echo
  fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7154 --caname ca.org1.private.com -M ${PWD}/../crypto-config/peerOrganizations/org1.private.com/users/Admin@org1.private.com/msp --tls.certfiles ${PWD}/fabric-ca/org1/tls-cert.pem

  cp ${PWD}/../crypto-config/peerOrganizations/org1.private.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/org1.private.com/users/Admin@org1.private.com/msp/config.yaml

}

# createcertificatesForOrg1

createCertificatesForOrg2() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p /../crypto-config/peerOrganizations/org2.private.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/org2.private.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8154 --caname ca.org2.private.com --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8154-ca-org2-private-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8154-ca-org2-private-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8154-ca-org2-private-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8154-ca-org2-private-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/org2.private.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca.org2.private.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca.org2.private.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca.org2.private.com --id.name org2admin --id.secret org2adminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/org2.private.com/peers
  mkdir -p ../crypto-config/peerOrganizations/org2.private.com/peers/peer0.org2.private.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8154 --caname ca.org2.private.com -M ${PWD}/../crypto-config/peerOrganizations/org2.private.com/peers/peer0.org2.private.com/msp --csr.hosts peer0.org2.private.com --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/org2.private.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/org2.private.com/peers/peer0.org2.private.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8154 --caname ca.org2.private.com -M ${PWD}/../crypto-config/peerOrganizations/org2.private.com/peers/peer0.org2.private.com/tls --enrollment.profile tls --csr.hosts peer0.org2.private.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/org2.private.com/peers/peer0.org2.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/org2.private.com/peers/peer0.org2.private.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/org2.private.com/peers/peer0.org2.private.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/org2.private.com/peers/peer0.org2.private.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/org2.private.com/peers/peer0.org2.private.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/org2.private.com/peers/peer0.org2.private.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/org2.private.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/org2.private.com/peers/peer0.org2.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/org2.private.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/org2.private.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/org2.private.com/peers/peer0.org2.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/org2.private.com/tlsca/tlsca.org2.private.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/org2.private.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/org2.private.com/peers/peer0.org2.private.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/org2.private.com/ca/ca.org2.private.com-cert.pem

  # --------------------------------------------------------------------------------
 
  mkdir -p ../crypto-config/peerOrganizations/org2.private.com/users
  mkdir -p ../crypto-config/peerOrganizations/org2.private.com/users/User1@org2.private.com

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8154 --caname ca.org2.private.com -M ${PWD}/../crypto-config/peerOrganizations/org2.private.com/users/User1@org2.private.com/msp --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/org2.private.com/users/Admin@org2.private.com

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://org2admin:org2adminpw@localhost:8154 --caname ca.org2.private.com -M ${PWD}/../crypto-config/peerOrganizations/org2.private.com/users/Admin@org2.private.com/msp --tls.certfiles ${PWD}/fabric-ca/org2/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/org2.private.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/org2.private.com/users/Admin@org2.private.com/msp/config.yaml

}

# createCertificateForOrg2

createCertificatesForOrg3() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/peerOrganizations/org3.private.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/peerOrganizations/org3.private.com/

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:10154 --caname ca.org3.private.com --tls.certfiles ${PWD}/fabric-ca/org3/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-10154-ca-org3-private-com.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-10154-ca-org3-private-com.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-10154-ca-org3-private-com.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-10154-ca-org3-private-com.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/peerOrganizations/org3.private.com/msp/config.yaml

  echo
  echo "Register peer0"
  echo
   
  fabric-ca-client register --caname ca.org3.private.com --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/fabric-ca/org3/tls-cert.pem
   

  echo
  echo "Register user"
  echo
   
  fabric-ca-client register --caname ca.org3.private.com --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/fabric-ca/org3/tls-cert.pem
   

  echo
  echo "Register the org admin"
  echo
   
  fabric-ca-client register --caname ca.org3.private.com --id.name org3admin --id.secret org3adminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/org3/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/org3.private.com/peers
  mkdir -p ../crypto-config/peerOrganizations/org3.private.com/peers/peer0.org3.private.com

  # --------------------------------------------------------------
  # Peer 0
  echo
  echo "## Generate the peer0 msp"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10154 --caname ca.org3.private.com -M ${PWD}/../crypto-config/peerOrganizations/org3.private.com/peers/peer0.org3.private.com/msp --csr.hosts peer0.org3.private.com --tls.certfiles ${PWD}/fabric-ca/org3/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/org3.private.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/org3.private.com/peers/peer0.org3.private.com/msp/config.yaml

  echo
  echo "## Generate the peer0-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:10154 --caname ca.org3.private.com -M ${PWD}/../crypto-config/peerOrganizations/org3.private.com/peers/peer0.org3.private.com/tls --enrollment.profile tls --csr.hosts peer0.org3.private.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/org3/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/org3.private.com/peers/peer0.org3.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/org3.private.com/peers/peer0.org3.private.com/tls/ca.crt
  cp ${PWD}/../crypto-config/peerOrganizations/org3.private.com/peers/peer0.org3.private.com/tls/signcerts/* ${PWD}/../crypto-config/peerOrganizations/org3.private.com/peers/peer0.org3.private.com/tls/server.crt
  cp ${PWD}/../crypto-config/peerOrganizations/org3.private.com/peers/peer0.org3.private.com/tls/keystore/* ${PWD}/../crypto-config/peerOrganizations/org3.private.com/peers/peer0.org3.private.com/tls/server.key

  mkdir ${PWD}/../crypto-config/peerOrganizations/org3.private.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/peerOrganizations/org3.private.com/peers/peer0.org3.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/org3.private.com/msp/tlscacerts/ca.crt

  mkdir ${PWD}/../crypto-config/peerOrganizations/org3.private.com/tlsca
  cp ${PWD}/../crypto-config/peerOrganizations/org3.private.com/peers/peer0.org3.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/peerOrganizations/org3.private.com/tlsca/tlsca.org3.private.com-cert.pem

  mkdir ${PWD}/../crypto-config/peerOrganizations/org3.private.com/ca
  cp ${PWD}/../crypto-config/peerOrganizations/org3.private.com/peers/peer0.org3.private.com/msp/cacerts/* ${PWD}/../crypto-config/peerOrganizations/org3.private.com/ca/ca.org3.private.com-cert.pem

  # --------------------------------------------------------------------------------

  mkdir -p ../crypto-config/peerOrganizations/org3.private.com/users
  mkdir -p ../crypto-config/peerOrganizations/org3.private.com/users/User1@org3.private.com

  echo
  echo "## Generate the user msp"
  echo
   
  fabric-ca-client enroll -u https://user1:user1pw@localhost:10154 --caname ca.org3.private.com -M ${PWD}/../crypto-config/peerOrganizations/org3.private.com/users/User1@org3.private.com/msp --tls.certfiles ${PWD}/fabric-ca/org3/tls-cert.pem
   

  mkdir -p ../crypto-config/peerOrganizations/org3.private.com/users/Admin@org3.private.com

  echo
  echo "## Generate the org admin msp"
  echo
   
  fabric-ca-client enroll -u https://org3admin:org3adminpw@localhost:10154 --caname ca.org3.private.com -M ${PWD}/../crypto-config/peerOrganizations/org3.private.com/users/Admin@org3.private.com/msp --tls.certfiles ${PWD}/fabric-ca/org3/tls-cert.pem
   

  cp ${PWD}/../crypto-config/peerOrganizations/org3.private.com/msp/config.yaml ${PWD}/../crypto-config/peerOrganizations/org3.private.com/users/Admin@org3.private.com/msp/config.yaml

}

createCretificatesForOrderer() {
  echo
  echo "Enroll the CA admin"
  echo
  mkdir -p ../crypto-config/ordererOrganizations/private.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/../crypto-config/ordererOrganizations/private.com

   
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9154 --caname ca-orderer-private --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9154-ca-orderer-private.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9154-ca-orderer-private.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9154-ca-orderer-private.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9154-ca-orderer-private.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/../crypto-config/ordererOrganizations/private.com/msp/config.yaml

  echo
  echo "Register orderer"
  echo
   
  fabric-ca-client register --caname ca-orderer-private --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register orderer2"
  echo
   
  fabric-ca-client register --caname ca-orderer-private --id.name orderer2 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register orderer3"
  echo
   
  fabric-ca-client register --caname ca-orderer-private --id.name orderer3 --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  echo
  echo "Register the orderer admin"
  echo
   
  fabric-ca-client register --caname ca-orderer-private --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  mkdir -p ../crypto-config/ordererOrganizations/private.com/orderers
  # mkdir -p ../crypto-config/ordererOrganizations/private.com/orderers/private.com

  # ---------------------------------------------------------------------------
  #  Orderer

  mkdir -p ../crypto-config/ordererOrganizations/private.com/orderers/orderer.private.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9154 --caname ca-orderer-private -M ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer.private.com/msp --csr.hosts orderer.private.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer.private.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9154 --caname ca-orderer-private -M ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer.private.com/tls --enrollment.profile tls --csr.hosts orderer.private.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer.private.com/tls/ca.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer.private.com/tls/signcerts/* ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer.private.com/tls/server.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer.private.com/tls/keystore/* ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer.private.com/tls/server.key

  mkdir ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer.private.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer.private.com/msp/tlscacerts/tlsca.private.com-cert.pem

  mkdir ${PWD}/../crypto-config/ordererOrganizations/private.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/private.com/msp/tlscacerts/tlsca.private.com-cert.pem

  # -----------------------------------------------------------------------
  #  Orderer 2

  mkdir -p ../crypto-config/ordererOrganizations/private.com/orderers/orderer2.private.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9154 --caname ca-orderer-private -M ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer2.private.com/msp --csr.hosts orderer2.private.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer2.private.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer2:ordererpw@localhost:9154 --caname ca-orderer-private -M ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer2.private.com/tls --enrollment.profile tls --csr.hosts orderer2.private.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer2.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer2.private.com/tls/ca.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer2.private.com/tls/signcerts/* ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer2.private.com/tls/server.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer2.private.com/tls/keystore/* ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer2.private.com/tls/server.key

  mkdir ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer2.private.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer2.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer2.private.com/msp/tlscacerts/tlsca.private.com-cert.pem

  # mkdir ${PWD}/../crypto-config/ordererOrganizations/private.com/msp/tlscacerts
  # cp ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer2.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/private.com/msp/tlscacerts/tlsca.private.com-cert.pem

  # ---------------------------------------------------------------------------
  #  Orderer 3
  mkdir -p ../crypto-config/ordererOrganizations/private.com/orderers/orderer3.private.com

  echo
  echo "## Generate the orderer msp"
  echo
   
  fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:9154 --caname ca-orderer-private -M ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer3.private.com/msp --csr.hosts orderer3.private.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer3.private.com/msp/config.yaml

  echo
  echo "## Generate the orderer-tls certificates"
  echo
   
  fabric-ca-client enroll -u https://orderer3:ordererpw@localhost:9154 --caname ca-orderer-private -M ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer3.private.com/tls --enrollment.profile tls --csr.hosts orderer3.private.com --csr.hosts localhost --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer3.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer3.private.com/tls/ca.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer3.private.com/tls/signcerts/* ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer3.private.com/tls/server.crt
  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer3.private.com/tls/keystore/* ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer3.private.com/tls/server.key

  mkdir ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer3.private.com/msp/tlscacerts
  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer3.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer3.private.com/msp/tlscacerts/tlsca.private.com-cert.pem

  # mkdir ${PWD}/../crypto-config/ordererOrganizations/private.com/msp/tlscacerts
  # cp ${PWD}/../crypto-config/ordererOrganizations/private.com/orderers/orderer3.private.com/tls/tlscacerts/* ${PWD}/../crypto-config/ordererOrganizations/private.com/msp/tlscacerts/tlsca.private.com-cert.pem

  # ---------------------------------------------------------------------------

  mkdir -p ../crypto-config/ordererOrganizations/private.com/users
  mkdir -p ../crypto-config/ordererOrganizations/private.com/users/Admin@private.com

  echo
  echo "## Generate the admin msp"
  echo
   
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9154 --caname ca-orderer-private -M ${PWD}/../crypto-config/ordererOrganizations/private.com/users/Admin@private.com/msp --tls.certfiles ${PWD}/fabric-ca/ordererOrg/tls-cert.pem
   

  cp ${PWD}/../crypto-config/ordererOrganizations/private.com/msp/config.yaml ${PWD}/../crypto-config/ordererOrganizations/private.com/users/Admin@private.com/msp/config.yaml

}

# createCretificateForOrderer

sudo rm -rf ../crypto-config/*
# sudo rm -rf fabric-ca/*
createcertificatesForOrg1
createCertificatesForOrg2
createCertificatesForOrg3

createCretificatesForOrderer

