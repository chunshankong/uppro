// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function transfer(
        address _to,
        uint256 _value
    ) external returns (bool success);
}

contract BaseERC20 is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor() {
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100000000000000000000000000;

        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        // write your code here
        return balances[_owner];
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        // write your code here
        require(
            _value <= balances[msg.sender],
            "ERC20: transfer amount exceeds balance"
        );

        _transfer(msg.sender, _to, _value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        // write your code here
        require(
            _value <= balances[_from],
            "ERC20: transfer amount exceeds balance"
        );
        uint256 currentAllowance = allowances[_from][msg.sender];
        require(
            _value <= currentAllowance,
            "ERC20: transfer amount exceeds allowance"
        );

        _transfer(_from, _to, _value);
        _approve(_from, msg.sender, currentAllowance - _value);

        emit Transfer(_from, _to, _value);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _update(sender, recipient, amount);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            totalSupply += value;
        } else {
            uint256 fromBalance = balances[from];
            if (fromBalance < value) {
                revert("error");
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert("ERC20InvalidReceiver");
        }
        _update(address(0), account, value);
    }
    function issuance(address account, uint256 value) public {
        _mint(account, value);
    }

    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        // write your code here
        _approve(msg.sender, _spender, _value);

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256 remaining) {
        // write your code here
        return allowances[_owner][_spender];
    }
}
