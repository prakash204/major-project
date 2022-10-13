package main

import (
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/hyperledger/fabric/common/flogging"
	"maincode/contracts"
)

var logger = flogging.MustGetLogger("mp_cc")


func main() {

	chaincode, err := contractapi.NewChaincode(
				new(contracts.StudentContract))
				
	if err != nil {
		fmt.Printf("Error create major-project chaincode: %s", err.Error())
		return
	}
	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting chaincodes: %s", err.Error())
	}

}