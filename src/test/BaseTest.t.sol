// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "frax-std/FraxTest.sol";
import "./Helpers.sol";
import "../Constants.sol" as Constants;

contract BaseTest is FraxTest, Constants.Helper {
    address timelock = Constants.Mainnet.TIMELOCK_ADDRESS;
}
