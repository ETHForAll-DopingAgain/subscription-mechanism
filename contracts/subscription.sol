// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import {ISuperfluid, ISuperToken} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import {IConstantFlowAgreementV1} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";

import {CFAv1Library} from "@superfluid-finance/ethereum-contracts/contracts/apps/CFAv1Library.sol";

error Unauthorized();

contract SubscriptionFunction {
    struct dataInfo {
        string descirption;
        uint256 charges;
    }

    using CFAv1Library for CFAv1Library.InitData;
    CFAv1Library.InitData public cfaV1;

    mapping(address => mapping(string => dataInfo)) public dataProviders;
    mapping(string => address[]) public subscriptions;

    constructor(ISuperfluid _host) {
        //initialize InitData struct, and set equal to cfaV1
        cfaV1 = CFAv1Library.InitData(
            _host,
            //here, we are deriving the address of the CFA using the host contract
            IConstantFlowAgreementV1(
                address(
                    _host.getAgreementClass(
                        keccak256(
                            "org.superfluid-finance.agreements.ConstantFlowAgreement.v1"
                        )
                    )
                )
            )
        );
    }

    function createStream(
        int96 flowRate,
        ISuperToken token,
        address receiver,
        string memory uid
    ) external {
        // Create stream
        cfaV1.createFlowByOperator(msg.sender, receiver, token, flowRate);
        subscriptions[uid].push(msg.sender);
    }

    function indexOf(
        address[] storage array,
        address item
    ) internal view returns (uint) {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == item) {
                return i;
            }
        }
        return array.length;
    }

    function remove(address[] storage array, uint index) internal {
        if (index >= array.length) return;

        for (uint i = index; i < array.length - 1; i++) {
            array[i] = array[i + 1];
        }
        array.pop();
    }

    function deleteStream(
        ISuperToken token,
        address receiver,
        string memory uid
    ) external {
        // Get the subscriptions array for the given key
        address[] storage subs = subscriptions[uid];

        // Find the index of the subscriber address in the subscriptions array
        uint index = indexOf(subs, msg.sender);

        // If the subscriber address is not in the subscriptions array, return
        if (index == subs.length) {
            revert("Not Subscribed");
        }

        // Remove the subscriber address from the subscriptions array
        remove(subs, index);
        cfaV1.deleteFlowByOperator(msg.sender, receiver, token);
    }

    function checkIsSubscribed(string memory uid) public view returns (bool) {
        // Get the subscriptions array for the given key
        address[] storage subs = subscriptions[uid];

        // Find the index of the subscriber address in the subscriptions array
        uint index = indexOf(subs, msg.sender);

        // If the subscriber address is not in the subscriptions array, return false
        if (index == subs.length) {
            return false;
        }

        // Otherwise, return true
        return true;
    }

    function addData(
        string memory uid,
        string memory description,
        uint256 charges
    ) public {
        // Check that the uid is not an empty string
        if (bytes(uid).length == 0) {
            revert("UID cannot be an empty string");
        }

        // Check that the description is not an empty string
        if (bytes(description).length == 0) {
            revert("Description cannot be an empty string");
        }

        // Check that the charges are non-zero
        if (charges == 0) {
            revert("Charges must be non-zero");
        }

        // Check that the caller does not already have a dataInfo struct with the given uid
        if (bytes(dataProviders[msg.sender][uid].descirption).length != 0) {
            revert("Data with this UID already exists for this address");
        }

        // Create a new dataInfo struct with the given description and charges
        dataInfo memory newInfo = dataInfo(description, charges);

        // Store the new dataInfo struct in the dataProviders mapping
        dataProviders[msg.sender][uid] = newInfo;
    }

    function deleteData(string memory uid) public {
        // Check that the caller has a dataInfo struct with the given uid
        if (bytes(dataProviders[msg.sender][uid].descirption).length == 0) {
            revert("Data with this UID does not exist for this address");
        }

        // Delete the dataInfo struct
        delete dataProviders[msg.sender][uid];

        // Check that the dataInfo struct was actually deleted
        if (bytes(dataProviders[msg.sender][uid].descirption).length != 0) {
            revert("Failed to delete data with this UID for this address");
        }
    }
}
