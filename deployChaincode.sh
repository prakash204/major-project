export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/private.com/orderers/orderer.private.com/msp/tlscacerts/tlsca.private.com-cert.pem
export PEER0_ORG1_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.private.com/peers/peer0.org1.private.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.private.com/peers/peer0.org2.private.com/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org3.private.com/peers/peer0.org3.private.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export CHANNEL_NAME=mychannel

setGlobalsForOrderer() {
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/private.com/orderers/orderer.private.com/msp/tlscacerts/tlsca.private.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/private.com/users/Admin@private.com/msp

}

setGlobalsForPeer0Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.private.com/users/Admin@org1.private.com/msp
    export CORE_PEER_ADDRESS=localhost:7151
}

setGlobalsForPeer0Org2() {
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.private.com/users/Admin@org2.private.com/msp
    export CORE_PEER_ADDRESS=localhost:9151

}

setGlobalsForPeer0Org3(){
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org3.private.com/users/Admin@org3.private.com/msp
    export CORE_PEER_ADDRESS=localhost:11151
    
}

presetup() {
    echo Vendoring Go dependencies ...
    pushd ./artifacts/src/github.com/chaincode/
    GO111MODULE=on go mod vendor
    popd
    echo Finished vendoring Go dependencies
}
# presetup

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
SEQUENCE="1"
CC_SRC_PATH="./artifacts/src/github.com/chaincode/"
CC_NAME="maincode"

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0Org1
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged ===================== "
}
# packageChaincode

installChaincode() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org1 ===================== "

    setGlobalsForPeer0Org2
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org2 ===================== "

    setGlobalsForPeer0Org3
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org3 ===================== "
}

# installChaincode

queryInstalled() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org1 on channel ===================== "
}

# queryInstalled

# --collections-config ./artifacts/private-data/collections_config.json \
#         --signature-policy "OR('Org1MSP.member','Org2MSP.member')" \

approveForMyOrg1() {
    setGlobalsForPeer0Org1
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7150 \
        --ordererTLSHostnameOverride orderer.private.com --tls \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE}
    # set +x

    echo "===================== chaincode approved from org 1 ===================== "

}
# queryInstalled
# approveForMyOrg1

# --signature-policy "OR ('Org1MSP.member')"
# --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA
# --peerAddresses peer0.org1.private.com:7051 --tlsRootCertFiles $PEER0_ORG1_CA --peerAddresses peer0.org2.private.com:9051 --tlsRootCertFiles $PEER0_ORG2_CA
#--channel-config-policy Channel/Application/Admins
# --signature-policy "OR ('Org1MSP.peer','Org2MSP.peer')"

checkCommitReadynessOrg1() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:7151 --tlsRootCertFiles $PEER0_ORG1_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

# checkCommitReadyness

approveForMyOrg2() {
    setGlobalsForPeer0Org2

    peer lifecycle chaincode approveformyorg -o localhost:7150 \
        --ordererTLSHostnameOverride orderer.private.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE}

    echo "===================== chaincode approved from org 2 ===================== "
}

# queryInstalled
# approveForMyOrg2

checkCommitReadynessOrg2() {

    setGlobalsForPeer0Org2
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:9151 --tlsRootCertFiles $PEER0_ORG2_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 2 ===================== "
}

# checkCommitReadyness

approveForMyOrg3() {
    setGlobalsForPeer0Org3

    peer lifecycle chaincode approveformyorg -o localhost:7150 \
        --ordererTLSHostnameOverride orderer.private.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --version ${VERSION} --init-required --package-id ${PACKAGE_ID} \
        --sequence ${SEQUENCE}

    echo "===================== chaincode approved from org 2 ===================== "
}

# queryInstalled
# approveForMyOrg3

checkCommitReadynessOrg3() {

    setGlobalsForPeer0Org3
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:11151 --tlsRootCertFiles $PEER0_ORG3_CA \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json --init-required
    echo "===================== checking commit readyness from org 3 ===================== "
}

# checkCommitReadyness

commitChaincodeDefination() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode commit -o localhost:7150 --ordererTLSHostnameOverride orderer.private.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --peerAddresses localhost:7151 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9151 --tlsRootCertFiles $PEER0_ORG2_CA \
        --peerAddresses localhost:11151 --tlsRootCertFiles $PEER0_ORG3_CA \
        --version ${VERSION} --sequence ${SEQUENCE} --init-required

}

# commitChaincodeDefination

queryCommitted() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

# queryCommitted

chaincodeInvokeInit() {
    setGlobalsForPeer0Org1
    peer chaincode invoke -o localhost:7150 \
        --ordererTLSHostnameOverride orderer.private.com \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7151 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9151 --tlsRootCertFiles $PEER0_ORG2_CA \
         --peerAddresses localhost:11151 --tlsRootCertFiles $PEER0_ORG3_CA \
        --isInit -c '{"Args":[]}'

}

# chaincodeInvokeInit

chaincodeInvoke() {
    setGlobalsForPeer0Org1

    # Create Car
    peer chaincode invoke -o localhost:7150 \
        --ordererTLSHostnameOverride orderer.private.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7151 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9151 --tlsRootCertFiles $PEER0_ORG2_CA   \
        -c '{"function": "createDevice","Args":["{\"id\":\"1\",\"puf\":\"asdfgh\",\"addedAt\":1600138309939}"]}'

}

# chaincodeInvoke

chaincodeInvokeDeleteAsset() {
    setGlobalsForPeer0Org1

    # Create Car
    peer chaincode invoke -o localhost:7150 \
        --ordererTLSHostnameOverride orderer.private.com \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME}  \
        --peerAddresses localhost:7151 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:9151 --tlsRootCertFiles $PEER0_ORG2_CA   \
        -c '{"function": "DeleteDeviceById","Args":["2"]}'

}

# chaincodeInvokeDeleteAsset

chaincodeQuery() {
    setGlobalsForPeer0Org1
    # setGlobalsForOrg1
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "GetDeviceById","Args":["1"]}'
}

# chaincodeQuery

# Run this function if you add any new dependency in chaincode
presetup

packageChaincode
installChaincode
queryInstalled
approveForMyOrg1
checkCommitReadynessOrg1
approveForMyOrg2
checkCommitReadynessOrg2
approveForMyOrg3
checkCommitReadynessOrg3
commitChaincodeDefination
queryCommitted
chaincodeInvokeInit
sleep 5
chaincodeInvoke
sleep 3
chaincodeQuery
