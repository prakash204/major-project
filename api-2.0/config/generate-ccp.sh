#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ./ccp-template.json
}

ORG=1
P0PORT=7151
CAPORT=7154
PEERPEM=../../artifacts/channel/crypto-config/peerOrganizations/org1.private.com/peers/peer0.org1.private.com/tls/tlscacerts/tls-localhost-7154-ca-org1-private-com.pem
CAPEM=../../artifacts/channel/crypto-config/peerOrganizations/org1.private.com/msp/tlscacerts/ca.crt

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM )" > connection-org1.json

ORG=2
P0PORT=9151
CAPORT=8154
PEERPEM=../../artifacts/channel/crypto-config/peerOrganizations/org2.private.com/peers/peer0.org2.private.com/tls/tlscacerts/tls-localhost-8154-ca-org2-private-com.pem
CAPEM=../../artifacts/channel/crypto-config/peerOrganizations/org2.private.com/msp/tlscacerts/ca.crt

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > connection-org2.json

ORG=3
P0PORT=11151
CAPORT=10154
PEERPEM=../../artifacts/channel/crypto-config/peerOrganizations/org3.private.com/peers/peer0.org3.private.com/tls/tlscacerts/tls-localhost-10154-ca-org3-private-com.pem
CAPEM=../../artifacts/channel/crypto-config/peerOrganizations/org3.private.com/msp/tlscacerts/ca.crt


echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > connection-org3.json