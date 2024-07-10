// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BaseERC20 {
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

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
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

        balances[sender] = balances[sender] - amount;
        balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
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

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {
        // write your code here
        return allowances[_owner][_spender];
    }
}
