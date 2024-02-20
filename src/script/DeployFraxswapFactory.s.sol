// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

import { FraxtalScript } from "./FraxtalScript.s.sol";
import { console } from "frax-std/FraxTest.sol";
import { FraxswapFactory } from "src/contracts/core/FraxswapFactory.sol";
import "../Constants.sol" as Constants;
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

function deployFraxswapFactory(address _owner) returns (FraxswapFactory iFraxswapFactory, address fraxswapFactory) {
    iFraxswapFactory = new FraxswapFactory({ _owner: _owner });
    fraxswapFactory = address(iFraxswapFactory);
}

contract DeployFraxswapFactory is FraxtalScript {
    function run() public broadcaster {
        address owner;
        if (Strings.equal(network, Constants.FraxtalDeployment.DEVNET)) {
            owner = Constants.FraxtalL2Devnet.COMPTROLLER;
        } else if (Strings.equal(network, Constants.FraxtalDeployment.TESTNET)) {
            owner = Constants.FraxtalTestnet.COMPTROLLER;
        } else if (Strings.equal(network, Constants.FraxtalDeployment.MAINNET)) {
            owner = Constants.FraxtalMainnet.COMPTROLLER;
        }
        require(owner != address(0), "FraxswapFactory not set in network");

        (, address fraxswapFactory) = deployFraxswapFactory({ _owner: owner });
        console.log("FraxswapFactory deployed to: ", fraxswapFactory);
    }
}
