pragma solidity ^0.8.0;

import "tests/BaseERC20.sol";
import "tests/TokenBank.sol";

interface TokenRecipient {
    function tokensReceived(
        address from,
        uint256 amount,
        bytes calldata exData
    ) external returns (bool);
}

contract ERC1363 is BaseERC20 {
    function transferAndCall(address _to, uint256 _value)
        external
        returns (bool)
    {
        transfer(_to, _value);
        if (isContract(_to)) {
            bool rv = TokenRecipient(_to).tokensReceived(
                msg.sender,
                _value,
                msg.data
            );
            require(rv, "No tokensReceived");
        }
        return true;
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

contract TokenBankCall is TokenBank, TokenRecipient {
    function tokensReceived(
        address from,
        uint256 amount,
        bytes calldata exData
    ) external returns (bool) {
        record(from, amount);
        return true;
    }
}