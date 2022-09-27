// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "hardhat/console.sol";
import "./IAstarBase.sol";

contract CatsDappsNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string baseURI = "https://arweave.net/dcGGZIY6krXymT0m2ZG_iq2gtZslrSbQZV0EX1N7l0Y";
    uint256 public publicMaxPerTx = 1;
    mapping(address => uint256) public claimed;
    IAstarBase public ASTARBASE = IAstarBase(0x8E2fa5A4D4e4f0581B69aF2f8F2Ef2CF205aE8F0);
    address MY_STAKING_PROJECT = 0x8b5d62f396Ca3C6cF19803234685e693733f9779;

    constructor() ERC721("CatsDappsNFT", "CATD") {
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return baseURI;
    }

    /// @notice this function verifies staker status on a contract by using caller's account
    /// @param user caller's account
    /// @return passHolderStatus boolean
    function isPassHolder(address user) public view returns (bool) {
        // The returned value from checkStakerStatus() call is the staked amount,
        // but we don't use it in this smart contract,
        // we only check if staked amount is > 0
        uint128 staker = ASTARBASE.checkStakerStatusOnContract(user, MY_STAKING_PROJECT);

        return staker > 0;
    }

    // public mint
    function publicMint() public {
        require(isPassHolder(msg.sender), "Claim allowed only for stakers registered in AstarPass");
        uint256 supply = totalSupply();

        require(
            claimed[msg.sender] + 1 <= publicMaxPerTx,
            "Already claimed max"
        );

        claimed[msg.sender] += 1;
        _safeMint(msg.sender, supply + 1);

    }

    function ownerMint(uint256 count) public onlyOwner {
        uint256 supply = totalSupply();

        for (uint256 i = 1; i <= count; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }

}
