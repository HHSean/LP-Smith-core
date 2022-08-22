pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISmToken is IERC20 {
    /**
     * @dev Emitted after the mint action
     * @param from The address performing the mint
     * @param value The amount being
     * @param index The new liquidity index of the reserve
     **/
    event Mint(address indexed from, uint256 value, uint256 index);

    /**
     * @dev Mints `amount` aTokens to `user`
     * @param user The address receiving the minted tokens
     * @param amount The amount of tokens getting minted
     * @param index The new liquidity index of the reserve
     */
    function mint(
        address user,
        uint256 amount,
        uint256 index
    ) external;

    /**
     * @dev Emitted after aTokens are burned
     * @param from The owner of the aTokens, getting them burned
     * @param value The amount being burned
     * @param index The new liquidity index of the reserve
     **/
    event Burn(address indexed from, uint256 value, uint256 index);

    /**
     * @dev Burns aTokens from `user` and sends the equivalent amount of underlying to `receiverOfUnderlying`
     * @param user The owner of the aTokens, getting them burned
     * @param amount The amount being burned
     * @param liquidityIndex The new liquidity index of the reserve
     **/
    function burn(
        address user,
        uint256 amount,
        uint256 liquidityIndex
    ) external;

    /**
     * @dev Returns the address of the underlying asset of this smToken (E.g. WETH for smWETH)
     **/
    function UNDERLYING_ASSET_ADDRESS() external view returns (address);

    function getUserDepositAmount(address user, uint256 liquidityIndex)
        external
        view
        returns (uint256 _depositAmount);
}
