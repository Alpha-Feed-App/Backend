// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract AlphaFeedToken is ERC20 {
    constructor() ERC20("AlphaFeed", "AF") {
        _mint(msg.sender, 1000000 * 1000000000000000000 /*1 mil*/);
    }
}