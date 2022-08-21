pragma solidity ^0.8.9;

interface ISmLpToken {
    function getDebt(address tokenAddress)
        external
        view
        returns (uint256 _debt);

    function getPotentialOnSale(address asset)
        external
        view
        returns (bool sign, uint256 _potentialOnSale);

    function getPendingOnSale(address asset)
        external
        view
        returns (bool sign, uint256 _pendingOnSale);

    function getPositionValue(address user) external view;

    function LP_TOKEN_CONTRACT_ADDRESS() external view returns (address);

    function tokenX() external view returns (address);

    function tokenY() external view returns (address);
}
