pragma solidity ^0.8.9;

interface ILendingPool {
    /**
     * @dev Deposits an `amount` of lp token into the reserve, receiving in return overlying smTokens.
     * - E.g. User deposits 100 USDC/ETH and gets in return 100 smUSDC
     * @param asset The address of the underlying asset to deposit
     * @param amount The amount to be deposited
     **/
    function depositERC20LpToken(address asset, uint256 amount) external;

    /**
     * @dev Withdraws an `amount` of lp token from the reserve, burning the equivalent smLpTokens owned
     * E.g. User has 100 smUSDC, calls withdraw() and receives 100 USDC, burning the 100 smUSDC
     * @param asset The address of the underlying asset to withdraw
     * @param amount The underlying amount to be withdrawn
     *   - Send the value type(uint256).max in order to withdraw the whole smLpToken balance
     * @return The final amount withdrawn
     **/
    function withdrawERC20LpToken(address asset, uint256 amount)
        external
        returns (uint256);

    /**
     * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying smTokens.
     * - E.g. User deposits 100 USDC and gets in return 100 smUSDC
     * @param asset The address of the underlying asset to deposit
     * @param amount The amount to be deposited
     **/
    function deposit(address asset, uint256 amount) external;

    /**
     * @dev Withdraws an `amount` of underlying asset from the reserve, burning the equivalent smTokens owned
     * E.g. User has 100 smUSDC, calls withdraw() and receives 100 USDC, burning the 100 smUSDC
     * @param asset The address of the underlying asset to withdraw
     * @param amount The underlying amount to be withdrawn
     *   - Send the value type(uint256).max in order to withdraw the whole smToken balance
     * @return The final amount withdrawn
     **/
    function withdraw(address asset, uint256 amount) external returns (uint256);

    /**
     * @dev Allows users to borrow a specific `amount` of the reserve underlying asset, provided that the borrower
     * already deposited enough collateral, or he was given enough allowance by a credit delegator on the
     * corresponding debt token (StableDebtToken or VariableDebtToken)
     * - E.g. User borrows 100 USDC passing as `onBehalfOf` his own address, receiving the 100 USDC in his wallet
     *   and 100 stable/variable debt tokens, depending on the `interestRateMode`
     * @param asset The address of the underlying asset to borrow
     * @param amount The amount to be borrowed
     **/
    function borrow(address asset, uint256 amount) external;

    /**
     * @notice Repays a borrowed `amount` on a specific reserve, burning the equivalent debt tokens owned
     * - E.g. User repays 100 USDC, burning 100 variable/stable debt tokens of the `onBehalfOf` address
     * @param asset The address of the borrowed underlying asset previously borrowed
     * @param amount The amount to repay
     * - Send the value type(uint256).max in order to repay the whole debt for `asset` on the specific `debtMode`
     * @return The final amount repaid
     **/
    function repay(address asset, uint256 amount) external returns (uint256);

    function requestFund(address asset, uint256 amount) external;

    function getLiquidityIndex(address asset)
        external
        view
        returns (uint256 _liquidityIndex);

    function getDepositedLpValue(address user)
        external
        view
        returns (uint256 _depositValue);

    function getBorrowableValue(address user)
        external
        view
        returns (uint256 _borrowableValue);

    function getHealthFactor(address user)
        external
        view
        returns (
            uint256 _healthFactor // decimal 6
        );

    function getReserveData(address user, address asset)
        external
        view
        returns (
            uint256 _depositAmount,
            uint256 _availAmount,
            uint256 _borrowAmount,
            uint256 _userDepositAmount,
            uint256 _userBorrowAmount
        );

    function getLpTokenData(address user, address lpTokenAddress)
        external
        view
        returns (
            uint256 _totalDeposit,
            uint _userDeposit,
            uint256 _totalValue,
            uint256 _userValue
        );
}
