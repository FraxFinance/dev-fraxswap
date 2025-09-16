// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

import { FraxtalScript } from "./FraxtalScript.s.sol";
import { console } from "frax-std/FraxTest.sol";
import { FraxswapRouter } from "src/updated_router_flat.sol";
import "../Constants.sol" as Constants;
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

function deployFraxswapRouter(
    address _factory,
    address _WETH
) returns (FraxswapRouter iFraxswapRouter, address fraxswapRouter) {
    iFraxswapRouter = new FraxswapRouter{ salt: bytes32(uint256(10_633_823_966_279_326_983_230_456_484_176_685_461)) }({
        _factory: _factory,
        _WETH: _WETH
    });
    fraxswapRouter = address(iFraxswapRouter);
    console.log("Router Deployed to: ", fraxswapRouter);
}

contract DeployFraxswapRouter is FraxtalScript {
    function run() external broadcaster {
        address fraxswapFactory;
        if (Strings.equal(network, Constants.FraxtalDeployment.DEVNET)) {
            fraxswapFactory = Constants.FraxtalL2Devnet.FRAXSWAP_FACTORY;
        } else if (Strings.equal(network, Constants.FraxtalDeployment.TESTNET)) {
            fraxswapFactory = Constants.FraxtalTestnet.FRAXSWAP_FACTORY;
        } else if (Strings.equal(network, Constants.FraxtalDeployment.MAINNET)) {
            // fraxswapFactory = Constants.FraxtalMainnet.FRAXSWAP_FACTORY;
            fraxswapFactory = 0xE30521fe7f3bEB6Ad556887b50739d6C7CA667E6;
        }
        require(fraxswapFactory != address(0), "FraxswapFactory not set in network");

        // console.logBytes(type(FraxswapRouter).creationCode);
        // console.logBytes(abi.encode(fraxswapFactory, Constants.FraxtalProxies.FXS_PROXY));

        deployFraxswapRouter({ _factory: fraxswapFactory, _WETH: Constants.FraxtalProxies.FXS_PROXY });
    }
}
