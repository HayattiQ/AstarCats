// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

interface IAstarBase {
    function isRegistered(address evmAddress) external view returns (bool);

    function checkStakerStatus(address evmAddress)
        external
        view
        returns (uint128);

    function checkStakerStatusOnContract(address evmAddress, address contract_id)
        external
        view
        returns (uint128);
}