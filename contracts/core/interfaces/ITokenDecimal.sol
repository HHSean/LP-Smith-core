// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.9;

interface ITokenDecimal {
    function getDecimal(address _address)
        external
        view
        returns (uint256 _decimal);

    function setDecimal(address _address, uint256 _decimal) external;
}
