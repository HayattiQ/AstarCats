// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import '@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "hardhat/console.sol";
import "./IAstarBase.sol";

contract CatsDappsNFT is ERC1155URIStorage, Ownable {
    using Strings for uint256;
    uint256 public publicMaxPerTx = 1;
    mapping(address => uint256) public claimed;
    IAstarBase public ASTARBASE = IAstarBase(0x8E2fa5A4D4e4f0581B69aF2f8F2Ef2CF205aE8F0);
    address MY_STAKING_PROJECT = 0x8b5d62f396Ca3C6cF19803234685e693733f9779;
    string public name = 'CatsDappsNFT';
    string public symbol = 'CATD';


    constructor() ERC1155("") {
      setBaseURI("https://arweave.net/yqjVjrr5jhFdIeae0dA3yQRwCSAcwd1uVdhbif7Wjkk/");
      setURI(1, "dapps.json");
    }

    function setURI(uint256 tokenId, string memory _tokenURI) public onlyOwner {
        _setURI(tokenId, _tokenURI);
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
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

        require(
            claimed[msg.sender] + 1 <= publicMaxPerTx,
            "Already claimed max"
        );

        claimed[msg.sender] += 1;
        _mint(msg.sender, 1, 1, "");

    }


    function mint(
        address to,
        uint256 id,
        uint256 amount
    ) public onlyOwner  {
        _mint(to, id, amount, '');
    }


}
