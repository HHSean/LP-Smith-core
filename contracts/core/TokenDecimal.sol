import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TokenDecimal is Ownable {
    mapping(address => uint256) public decimals;

    constructor() {
        address USDC = address(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
        address USDT = address(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
        address WETH = address(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619);
        address WMATIC = address(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
        address WBTC = address(0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6);

        decimals[USDC] = 6;
        decimals[USDT] = 6;
        decimals[WETH] = 18;
        decimals[WMATIC] = 18;
        decimals[WBTC] = 8;
    }

    function getDecimal(address _address)
        external
        view
        returns (uint256 _decimal)
    {
        _decimal = decimals[_address];
    }

    function setDecimal(address _address, uint256 _decimal) external onlyOwner {
        decimals[_address] = _decimal;
    }
}
