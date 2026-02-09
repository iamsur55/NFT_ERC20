// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT

pragma solidity 0.8.33;

import {ERC721} from "@openzeppelin/token/ERC721/ERC721.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/access/Ownable.sol";

/// @title MyNFT
/// @author iamsur
/// @notice ERC721 NFT which can be purchased with an ERC20 token.
/// @dev this is a learning project, as such it should not be relied on; .
contract MyNFT is ERC721, Ownable {
    event NFTPriceSet(uint256 indexed NFTId, uint256 price);
    event Withdrawn(address indexed to, uint256 value);

    IERC20 private erc20;

    uint256 private NFTIdCounter;

    mapping(uint256 => uint256) listingPrices;

    /// @notice Initializes the NFT collection and payment token.
    /// @dev Calls ERC721 and Ownable base constructors.
    /// @param name_ The ERC721 name.
    /// @param symbol_ The ERC721 symbol.
    /// @param ERC20tokenAddress The ERC20 token used to buy NFTs.
    /// @param initialOwner The initial contract owner.
    constructor(string memory name_, string memory symbol_, address initialOwner, address ERC20tokenAddress)
        ERC721(name_, symbol_)
        Ownable(initialOwner)
    {
        erc20 = IERC20(ERC20tokenAddress);
    }

    modifier onlyNFTOwner(uint256 NFTId) {
        _onlyNFTOwner(NFTId);
        _;
    }

    /// @notice Mints a new NFT to the owner with an optional initial sale price.
    /// @dev Set `initialPrice` to 0 to mint without listing for sale.
    /// @param initialPrice The initial listing price for the NFT, set to 0 if you don't want to list your NFT.
    function mint(uint256 initialPrice) external onlyOwner {
        _setNFTPrice(NFTIdCounter, initialPrice);
        _mint(msg.sender, NFTIdCounter);
        NFTIdCounter++;
    }

    /// @notice Buys an NFT using the configured ERC20 token, make sure you
    /// have allowed this contract to spend your token before calling this function.
    /// @dev Reverts if the NFT is not listed or if the ERC20 transfer fails.
    /// @param NFTId The token id to purchase.
    function buy(uint256 NFTId) external {
        uint256 price = NFTPrice(NFTId);
        _setNotForSale(NFTId);
        bool transforOk = erc20.transferFrom(msg.sender, address(this), price);

        //some tokens don't revert but return false instead. We should check the return value for this edge case
        if (!transforOk) revert("could not transfer the required price for this token");
    }

    /// @notice Sets the sale price of an owned NFT
    /// @param NFTId The token id for which to set the price
    /// @param price The listing price
    /// @dev a price of 0 is not allowed, use unlistNFT function to unlist
    function setNFTPrice(uint256 NFTId, uint256 price) external onlyNFTOwner(NFTId) {
        require(price != 0, "a price of 0 is not allowed, use the unlistNFT function to unlist NFT");
        _setNFTPrice(NFTId, price);
    }

    /// @notice Unlists an owned NFT
    /// @param NFTId The token id to unlist
    function unlistNFT(uint256 NFTId) external onlyNFTOwner(NFTId) {
        _setNFTPrice(NFTId, 0);
    }

    /// @notice Withdraws ERC20 proceeds to a recipient
    /// @param to The recipient address
    /// @param value The amount to withdraw
    function withdraw(address to, uint256 value) external onlyOwner {
        _withdraw(to, value);
    }

    /// @notice Returns the current price for a listed NFT
    /// @param NFTId The token id to query
    function NFTPrice(uint256 NFTId) public view returns (uint256) {
        require(isListed(NFTId), "NFT not for sale");
        return listingPrices[NFTId];
    }

    /// @notice Returns true if the NFT is listed for sale
    /// @param NFTId The token id to query
    function isListed(uint256 NFTId) public view returns (bool) {
        return listingPrices[NFTId] != 0 ? true : false;
    }

    function _onlyNFTOwner(uint256 NFTId) internal view {
        require(msg.sender == ownerOf(NFTId));
    }

    function _setNotForSale(uint256 NFTId) internal {
        _setNFTPrice(NFTId, 0);
    }

    function _withdraw(address to, uint256 value) internal {
        bool ok = erc20.transfer(to, value);
        require(ok, "could not withdraw");
        emit Withdrawn(to, value);
    }

    function _setNFTPrice(uint256 NFTId, uint256 price) internal {
        listingPrices[NFTId] = price;
        emit NFTPriceSet(NFTId, price);
    }
}
