pragma solidity ^0.8.0;

import "src/erc20/BaseERC20.sol";

interface IERC1363Receiver {
    function tokensReceived(
        address from,
        uint256 amount,
        bytes calldata exData
    ) external returns (bool);
}


contract ERC1363 is BaseERC20 {
    function transferAndCall(address to, uint256 value)
        external
        returns (bool)
    {
        transfer(to, value);
        if (isContract(to)) {
            bool rv = IERC1363Receiver(to).tokensReceived(
                msg.sender,
                value,
                msg.data
            );
            require(rv, "No tokensReceived");
        }
        return true;
    }
       
       event EventName(address to, uint256 value);

    function transferAndCall(address to, uint256 value, bytes calldata data) public returns (bool) {

         emit  EventName(to,value);

        transfer(to, value);
        if (isContract(to)) {
            bool rv = IERC1363Receiver(to).tokensReceived(
                msg.sender,
                value,
                data
            );
            require(rv, "No tokensReceived");
        }
        return true;
    }

    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

