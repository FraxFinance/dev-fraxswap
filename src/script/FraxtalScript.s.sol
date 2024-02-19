// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import { BaseScript } from "frax-std/BaseScript.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import "../Constants.sol" as Constants;

// @dev: Safety to ensure script is deployed to a fraxtal chain
contract FraxtalScript is BaseScript {
    string internal network;

    function setUp() public virtual override {
        BaseScript.setUp();
        network = vm.envString("NETWORK");

        if (
            !Strings.equal(network, Constants.FraxtalDeployment.DEVNET) &&
            !Strings.equal(network, Constants.FraxtalDeployment.TESTNET) &&
            !Strings.equal(network, Constants.FraxtalDeployment.MAINNET)
        ) {
            revert("NETWORK env variable must be either 'devnet' or 'testnet' or 'mainnet'");
        }
    }
}
