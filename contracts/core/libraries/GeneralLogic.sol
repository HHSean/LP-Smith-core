import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

library GeneralLogic {
    using SafeMath for uint256;
    using SafeMath for uint248;

    function getUnderlyingValue(
        uint248 qty,
        uint8 qtyDecimal,
        uint256 price
    ) external pure returns (uint256 _value) {
        _value = qty.mul(price).div(10**qtyDecimal);
    }
}
