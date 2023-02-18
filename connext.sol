// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {IConnext} from "@connext/smart-contracts/contracts/core/connext/interfaces/IConnext.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISimpleBridge {
  function xTransfer (
    address token,
    uint256 amount, 
    address recipient, 
    uint32 destinationDomain,
    uint256 slippage, 
    uint256 relayerFee
  ) external payable;
}

contract SimpleBridge {
  IConnext public immutable connext;

  constructor(address _connext) {
    connext = IConnext(_connext);
  }

  function xTransfer(
    address token,
    uint256 amount,
    address recipient,
    uint32 destinationDomain,
    uint256 slippage,
    uint256 relayerFee
  ) external payable {
    IERC20 _token = IERC20(token);

    require(
      _token.allowance(msg.sender, address(this)) >= amount,
      "User must approve amount"
    );

    _token.transferFrom(msg.sender, address(this), amount);

    _token.approve(address(connext), amount);

    connext.xcall{value: relayerFee}(
      destinationDomain,
      recipient,
      token,
      msg.sender,
      amount,
      slippage,
      bytes("")
    );
  }
}