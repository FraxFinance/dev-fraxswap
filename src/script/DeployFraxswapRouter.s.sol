// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

import { FraxtalScript } from "./FraxtalScript.s.sol";
import { console } from "frax-std/FraxTest.sol";
import { FraxswapRouter } from "src/contracts/periphery/FraxswapRouter.sol";
import "../Constants.sol" as Constants;
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

function deployFraxswapRouter(
    address _factory,
    address _WETH
) returns (FraxswapRouter iFraxswapRouter, address fraxswapRouter) {
    iFraxswapRouter = new FraxswapRouter({ _factory: _factory, _WETH: _WETH });
    fraxswapRouter = address(iFraxswapRouter);
}

contract DeployFraxswapRouter is FraxtalScript {
    function run() external broadcaster {
        address fraxswapFactory;
        if (Strings.equal(network, Constants.FraxtalDeployment.DEVNET)) {
            fraxswapFactory = Constants.FraxtalL2Devnet.FRAXSWAP_FACTORY;
        } else if (Strings.equal(network, Constants.FraxtalDeployment.TESTNET)) {
            fraxswapFactory = Constants.FraxtalTestnet.FRAXSWAP_FACTORY;
        } else if (Strings.equal(network, Constants.FraxtalDeployment.MAINNET)) {
            fraxswapFactory = Constants.FraxtalMainnet.FRAXSWAP_FACTORY;
        }
        require(fraxswapFactory != address(0), "FraxswapFactory not set in network");

        deployFraxswapRouter({ _factory: fraxswapFactory, _WETH: Constants.FraxtalProxies.WFRXETH_PROXY });
    }
}
