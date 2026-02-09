// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {ERC721} from "@openzeppelin/token/ERC721/ERC721.sol";
import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

contract MyNFT is ERC721 {
    ERC20 private erc20;

    constructor(string memory name_, string memory symbol_, address ERC20tokenAddress) ERC721(name_, symbol_) {
        erc20 = ERC20(ERC20tokenAddress);
    }
}
