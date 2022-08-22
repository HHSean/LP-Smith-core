// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.8.9;

/************
@title IPriceOracle interface
@notice Interface for the Aave price oracle.*/
interface IPriceOracle {
    /***********
    @dev returns the asset price in wei
     */
    function getAssetPrice(address asset) external view returns (uint256);

    function setAssetToPriceFeed(address _token, address _dollarPriceFeed) external;
}
