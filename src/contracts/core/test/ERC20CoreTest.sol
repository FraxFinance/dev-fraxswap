pragma solidity >=0.5.16;

import "../FraxswapERC20.sol";

contract ERC20CoreTest is FraxswapERC20 {
    constructor(uint256 _totalSupply) {
        _mint(msg.sender, _totalSupply);
    }
}
