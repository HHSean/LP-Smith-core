import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";

library UnsignedCalc {
    using SafeMath for uint256;

    function calculateUnsignedAdd(
        bool isPositiveA,
        uint256 numA,
        bool isPositiveB,
        uint256 numB
    ) internal pure returns (bool _isPositive, uint256 resNum) {
        if (isPositiveA == isPositiveB) {
            return (isPositiveA, numA.add(numB));
        } else {
            if (numA > numB) {
                return (isPositiveA, numA.sub(numB));
            } else {
                return (isPositiveB, numB.sub(numA));
            }
        }
    }

    function calculateUnsignedSub(
        bool isPositiveA,
        uint256 numA,
        bool isPositiveB,
        uint256 numB
    ) internal pure returns (bool _isPositive, uint256 resNum) {
        if (isPositiveA != isPositiveB) {
            return (isPositiveA, numA.add(numB));
        } else {
            if (numA > numB) {
                return (isPositiveA, numA.sub(numB));
            } else {
                if (isPositiveA == true) {
                    return (false, numB.sub(numA));
                } else {
                    return (true, numB.sub(numA));
                }
            }
        }
    }
}
