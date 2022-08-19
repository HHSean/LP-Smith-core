pragma solidity ^0.8.9;

interface ILendingPool {
    /**
     * @param asset The address of the ERC20 asset
     **/
    function getLpDebts(address asset) external view returns (uint256 _debt);

    /**
     * @dev Deposits an `amount` of lp token into the reserve, receiving in return overlying smTokens.
     * - E.g. User deposits 100 USDC/ETH and gets in return 100 smUSDC
     * @param asset The address of the underlying asset to deposit
     * @param amount The amount to be deposited
     * @param onBehalfOf The address that will receive the smTokens, same as msg.sender if the user
     *   wants to receive them on his own wallet, or a different address if the beneficiary of smTokens
     *   is a different wallet
     **/
    function depositERC20LpToken(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external;

    /**
     * @dev Withdraws an `amount` of lp token from the reserve, burning the equivalent smLpTokens owned
     * E.g. User has 100 smUSDC, calls withdraw() and receives 100 USDC, burning the 100 smUSDC
     * @param asset The address of the underlying asset to withdraw
     * @param amount The underlying amount to be withdrawn
     *   - Send the value type(uint256).max in order to withdraw the whole smLpToken balance
     * @param to Address that will receive the underlying, same as msg.sender if the user
     *   wants to receive it on his own wallet, or a different address if the beneficiary is a
     *   different wallet
     * @return The final amount withdrawn
     **/
    function withdrawERC20LpToken(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);

    /**
     * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying smTokens.
     * - E.g. User deposits 100 USDC and gets in return 100 smUSDC
     * @param asset The address of the underlying asset to deposit
     * @param amount The amount to be deposited
     * @param onBehalfOf The address that will receive the smTokens, same as msg.sender if the user
     *   wants to receive them on his own wallet, or a different address if the beneficiary of smTokens
     *   is a different wallet
     **/
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external;

    /**
     * @dev Withdraws an `amount` of underlying asset from the reserve, burning the equivalent smTokens owned
     * E.g. User has 100 smUSDC, calls withdraw() and receives 100 USDC, burning the 100 smUSDC
     * @param asset The address of the underlying asset to withdraw
     * @param amount The underlying amount to be withdrawn
     *   - Send the value type(uint256).max in order to withdraw the whole smToken balance
     * @param to Address that will receive the underlying, same as msg.sender if the user
     *   wants to receive it on his own wallet, or a different address if the beneficiary is a
     *   different wallet
     * @return The final amount withdrawn
     **/
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);

    /**
     * @dev Allows users to borrow a specific `amount` of the reserve underlying asset, provided that the borrower
     * already deposited enough collateral, or he was given enough allowance by a credit delegator on the
     * corresponding debt token (StableDebtToken or VariableDebtToken)
     * - E.g. User borrows 100 USDC passing as `onBehalfOf` his own address, receiving the 100 USDC in his wallet
     *   and 100 stable/variable debt tokens, depending on the `interestRateMode`
     * @param asset The address of the underlying asset to borrow
     * @param amount The amount to be borrowed
     * @param onBehalfOf Address of the user who will receive the debt. Should be the address of the borrower itself
     * calling the function if he wants to borrow against his own collateral, or the address of the credit delegator
     * if he has been given credit delegation allowance
     **/
    function borrow(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external;

    /**
     * @notice Repays a borrowed `amount` on a specific reserve, burning the equivalent debt tokens owned
     * - E.g. User repays 100 USDC, burning 100 variable/stable debt tokens of the `onBehalfOf` address
     * @param asset The address of the borrowed underlying asset previously borrowed
     * @param amount The amount to repay
     * - Send the value type(uint256).max in order to repay the whole debt for `asset` on the specific `debtMode`
     * @param onBehalfOf Address of the user who will get his debt reduced/removed. Should be the address of the
     * user calling the function if he wants to reduce/remove his own debt, or the address of any other
     * other borrower whose debt should be removed
     * @return The final amount repaid
     **/
    function repay(
        address asset,
        uint256 amount,
        address onBehalfOf
    ) external returns (uint256);
}
