#!/usr/bin/env bash
set -e

forge script src/script/DeployFraxswapRouterMultihop.s.sol:DeployFraxswapRouterMultihop --rpc-url fraxtal --chain 252 --broadcast --verify --watch