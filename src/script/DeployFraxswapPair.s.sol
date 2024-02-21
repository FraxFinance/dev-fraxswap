// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

import { FraxtalScript } from "./FraxtalScript.s.sol";
import { console } from "frax-std/FraxTest.sol";
import { FraxswapPair } from "src/contracts/core/FraxswapPair.sol";
import "../Constants.sol" as Constants;
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

contract DeployFraxswapPair is FraxtalScript {
    function run() public broadcaster {
        address owner;
        if (Strings.equal(network, Constants.FraxtalDeployment.DEVNET)) {
            owner = Constants.FraxtalL2Devnet.COMPTROLLER;
        } else if (Strings.equal(network, Constants.FraxtalDeployment.TESTNET)) {
            owner = Constants.FraxtalTestnet.COMPTROLLER;
        } else if (Strings.equal(network, Constants.FraxtalDeployment.MAINNET)) {
            owner = Constants.FraxtalMainnet.COMPTROLLER;
        }
        require(owner != address(0), "FraxswapPair not set in network");

        FraxswapPair iPair = new FraxswapPair();
        console.log("FraxswapPair deployed to: ", address(iPair));
    }
}
