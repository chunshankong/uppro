pragma solidity >=0.7.0 <0.9.0;
import "src/erc20/ERC1363.sol";

contract TokenBank is IERC1363Receiver{
    mapping(address => uint256) public balances;
    address[3] public top3;
    uint8 private index;
    IERC20 public immutable tokenContract;

    constructor(address tokenAddress) {
        index = 0;
        tokenContract = IERC20(tokenAddress)  ;
    }

    event EventName(uint256 top3min);

    function tokensReceived(
        address from,
        uint256 amount,
        bytes calldata exData
    ) external returns (bool) {
        require(msg.sender == address(tokenContract), "Invalid token contract");
        record(from, amount);
        return true;
    }

    function deposit(address tokenAddress, uint256 _value) public {
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _value);

        record(msg.sender, _value);
    }

    function record(address sender, uint256 _value) internal {
        //记录地址余额
        uint256 blc = balances[sender];
        if (0 == blc) {
            balances[sender] = _value;
        } else {
            balances[sender] = _value + blc;
        }
        //更新top3地址
        if (2 <= index) {
            if (!existed(sender)) {
                uint8 top3min = minIndex();
                emit EventName(top3min);
                if (balances[sender] > balances[top3[top3min]]) {
                    top3[top3min] = sender;
                }
            }
        } else {
            if (!existed(sender)) {
                top3[index++] = sender;
            }
        }
    }

    function existed(address add) private view returns (bool) {
        if (top3[0] == add || top3[1] == add || top3[2] == add) {
            return true;
        } else {
            return false;
        }
    }

    function minIndex() private view returns (uint8) {
        if (
            balances[top3[0]] <= balances[top3[1]] &&
            balances[top3[0]] <= balances[top3[2]]
        ) {
            return 0;
        } else if (
            balances[top3[1]] <= balances[top3[0]] &&
            balances[top3[1]] <= balances[top3[2]]
        ) {
            return 1;
        } else {
            return 2;
        }
    }

    function withdraw(address tokenAddress, uint256 _value) public {
        require(
            _value <= balances[msg.sender],
            "transfer amount exceeds balance"
        );
        IERC20(tokenAddress).transfer(msg.sender, _value);
        balances[msg.sender] -= _value;
    }
}
