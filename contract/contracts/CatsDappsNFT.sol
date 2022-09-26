// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import "./IAstarBase.sol";

contract CatsDappsNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string baseURI = "";
    string public baseExtension = ".json";
    uint256 public publicMaxPerTx = 1;
    bool public paused = true;
    mapping(address => uint256) public claimed;
    IAstarBase public ASTARBASE = IAstarBase(0xF183f51D3E8dfb2513c15B046F848D4a68bd3F5D); //Shibuya deployment
    address MY_STAKING_PROJECT = 0x8b5d62f396Ca3C6cF19803234685e693733f9779; // Uniswap on Shibuya


    constructor() ERC721("CatsDappsNFT", "CATD") {
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    /// @notice this function verifies staker status on a contract by using caller's account
    /// @param user caller's account
    /// @return passHolderStatus boolean
    function isPassHolder(address user) private view returns (bool) {
        // The returned value from checkStakerStatus() call is the staked amount,
        // but we don't use it in this smart contract,
        // we only check if staked amount is > 0
        uint128 staker = ASTARBASE.checkStakerStatusOnContract(user, MY_STAKING_PROJECT);

        return staker > 0;
    }

    // public mint
    function publicMint() public {
        uint256 supply = totalSupply();
        require(isPassHolder(msg.sender), "Claim allowed only for stakers registered in AstarPass");

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


    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }
}
