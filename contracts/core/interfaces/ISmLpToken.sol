pragma solidity ^0.8.9;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISmLpToken is IERC20 {
    function getDebt(address tokenAddress)
        external
        view
        returns (uint256 _debt);

    function getPotentialOnSale(address asset)
        external
        view
        returns (bool _isPositive, uint256 _potentialOnSale);

    function getPendingOnSale(address asset)
        external
        view
        returns (bool _isPositive, uint256 _pendingOnSale);

    function decreasePendingOnSale(address asset, uint256 saledAmount) external;

    function getDepositValue(address user) external view returns (uint256);

    function getBorrowableValue(address user) external view returns (uint256);

    function tokenX() external view returns (address);

    function tokenY() external view returns (address);

    function mint(address user, uint256 amount)
        external
        returns (
            uint256 _amountX,
            uint256 _amountY,
            bool _isFirstDeposit
        );

    function burn(
        address user,
        address recipient,
        uint256 amount
    ) external returns (bool _isCloseAll);

    function liquidate(
        address liquidator,
        address user,
        uint256 repaidValue
    ) external returns (uint256 _returnAmount);

    function realizeLp(address user, uint256 amount) external;

    /**
     * @dev Returns the address of the underlying asset of this smToken (E.g. WETH for smWETH)
     **/
    function UNDERLYING_ASSET_ADDRESS() external view returns (address);
}
