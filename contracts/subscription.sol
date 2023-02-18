// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import { ISuperfluid, ISuperToken } from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import {IConstantFlowAgreementV1} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";

import {CFAv1Library} from "@superfluid-finance/ethereum-contracts/contracts/apps/CFAv1Library.sol";

error Unauthorized();

contract SubscriptionFunction {

    using CFAv1Library for CFAv1Library.InitData;
    CFAv1Library.InitData public cfaV1;

    mapping (string => address[]) public subscriptions;

        constructor(ISuperfluid _host) {

        //initialize InitData struct, and set equal to cfaV1        
        cfaV1 = CFAv1Library.InitData(
            _host,
            //here, we are deriving the address of the CFA using the host contract
            IConstantFlowAgreementV1(
                address(_host.getAgreementClass(
                        keccak256("org.superfluid-finance.agreements.ConstantFlowAgreement.v1")
                    ))
            )
        );

    }

    function createStream(int96 flowRate,ISuperToken token, address receiver) external {
        // Create stream
        cfaV1.createFlowByOperator(msg.sender,receiver,token,flowRate);
    }

    function deleteStream(ISuperToken token, address receiver) external {
        // Delete stream
        cfaV1.deleteFlowByOperator(msg.sender,receiver,token);
    }

    function isAddressExist(string memory uid, address addr) public view returns (bool) {
        address[] memory addresses = subscriptions[uid];
        for (uint i = 0; i < addresses.length; i++) {
            if (addresses[i] == addr) {
                return true;
            }
        }
        return false;
    }

}
