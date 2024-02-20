// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

import { FraxtalScript } from "./FraxtalScript.s.sol";
import { console } from "frax-std/FraxTest.sol";
import { FraxswapRouterMultihop } from "src/contracts/periphery/FraxswapRouterMultihop.sol";
import { IWETH } from "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import "../Constants.sol" as Constants;

function deployFraxswapRouterMultihop(
    address _WETH9,
    address _FRAX,
    bool _CHECK_AMOUNTOUT_IN_ROUTER
) returns (FraxswapRouterMultihop iFraxswapRouterMultihop, address fraxswapRouterMultihop) {
    iFraxswapRouterMultihop = new FraxswapRouterMultihop({
        _WETH9: IWETH(_WETH9),
        _FRAX: _FRAX,
        _CHECK_AMOUNTOUT_IN_ROUTER: _CHECK_AMOUNTOUT_IN_ROUTER
    });
    fraxswapRouterMultihop = address(iFraxswapRouterMultihop);
}

contract DeployFraxswapRouterMultihop is FraxtalScript {
    function run() public broadcaster {
        (, address fraxswapRouterMultihop) = deployFraxswapRouterMultihop({
            _WETH9: Constants.FraxtalProxies.WFRXETH_PROXY,
            _FRAX: Constants.FraxtalProxies.FRAX_PROXY,
            _CHECK_AMOUNTOUT_IN_ROUTER: true
        });
        console.log("FraxswapRouterMultihop deployed to: ", fraxswapRouterMultihop);
    }
}
