// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ========================== FraxswapFactory =========================
// ====================================================================

import { IFraxswapFactory } from "./interfaces/IFraxswapFactory.sol";
import { FraxswapPair } from "./FraxswapPair.sol";

/// @notice TWAMM LP Pair Factory
/// @author Frax Finance: https://github.com/FraxFinance
contract FraxswapFactory is IFraxswapFactory {
    address public override feeTo;
    address public override feeToSetter;
    bool public override globalPause;

    mapping(address => mapping(address => address)) public override getPair;
    address[] public override allPairs;

    error IdenticalAddress();
    error ZeroAddress();
    error PairExists();

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    ///@notice Throws if called by any account other than the feeToSetter.
    modifier onlyFTS() {
        require(msg.sender == feeToSetter); // FORBIDDEN
        _;
    }

    function allPairsLength() external view override returns (uint256) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external override returns (address pair) {
        return createPair(tokenA, tokenB, 30); // default fee 0.30%
    }

    function createPair(address tokenA, address tokenB, uint256 fee) public override returns (address pair) {
        if (tokenA == tokenB) revert IdenticalAddress(); // IDENTICAL_ADDRESSES
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        if (token0 == address(0)) revert ZeroAddress(); // ZERO_ADDRESS
        if (getPair[token0][token1] != address(0)) revert PairExists(); // PAIR_EXISTS // single check is sufficient
        bytes memory bytecode = type(FraxswapPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        FraxswapPair(pair).initialize(token0, token1, fee);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external override onlyFTS {
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external override onlyFTS {
        feeToSetter = _feeToSetter;
    }

    function toggleGlobalPause() external override onlyFTS {
        require(!globalPause);
        globalPause = true;
    }
}
