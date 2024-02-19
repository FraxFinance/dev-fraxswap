// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

import { FraxtalScript } from "./FraxtalScript.s.sol";
import { console } from "frax-std/FraxTest.sol";
import { FraxswapFactory } from "src/contracts/core/FraxswapFactory.sol";
import "../Constants.sol" as Constants;
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

function deployFraxswapFactory(
    address _feeToSetter
) returns (FraxswapFactory iFraxswapFactory, address fraxswapFactory) {
    iFraxswapFactory = new FraxswapFactory({ _feeToSetter: _feeToSetter });
    fraxswapFactory = address(iFraxswapFactory);
}

contract DeployFraxswapFactory is FraxtalScript {
    function run() public broadcaster {
        address feeToSetter;
        if (Strings.equal(network, Constants.FraxtalDeployment.DEVNET)) {
            feeToSetter = Constants.FraxtalL2Devnet.FEE_TO_SETTER;
        } else if (Strings.equal(network, Constants.FraxtalDeployment.TESTNET)) {
            feeToSetter = Constants.FraxtalTestnet.FEE_TO_SETTER;
        } else if (Strings.equal(network, Constants.FraxtalDeployment.MAINNET)) {
            feeToSetter = Constants.FraxtalMainnet.FEE_TO_SETTER;
        }
        require(feeToSetter != address(0), "FraxswapFactory not set in network");

        (, address fraxswapFactory) = deployFraxswapFactory({ _feeToSetter: feeToSetter });
        console.log("FraxswapFactory deployed to: ", fraxswapFactory);
    }
}
