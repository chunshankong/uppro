pragma solidity >=0.7.0 <0.9.0;

interface IBank {
    function withdraw() external ;

}

abstract contract Bank is IBank{
    address payable internal  owner;
    mapping(address => uint256) public balances;
    address[3] public top3;
    uint8 private index;

    constructor() {
        address add = 0x831e722fe6B1832EAebD9D008E91C4dF1f7d042a;
        owner = payable(add);
        index = 0;
    }

    receive() external payable {}

    event EventName(uint top3min);

    
    function deposit() virtual public payable {
          
        //记录地址余额
        uint256 blc = balances[msg.sender];
        if (0 == blc) {
            balances[msg.sender] = msg.value;
        } else {
            balances[msg.sender] = msg.value + blc;
        }
        //更新top3地址
        if (2 <= index){
             if (!existed(msg.sender)){
               uint8 top3min = minIndex();
               emit EventName(top3min);
               if (balances[msg.sender] > balances[top3[top3min]]){
                    top3[top3min] = msg.sender;
               }
            }
        }else {
            if (!existed(msg.sender)){
                top3[index++] = msg.sender;
            }
        }
    }
    function existed(address add) private view returns(bool){
        if (top3[0] == add || top3[1] == add || top3[2] == add) {
            return true;
        }else{
            return false;
        }
    }
    function minIndex() private view returns(uint8){
        if (balances[top3[0]] <= balances[top3[1]]   && balances[top3[0]]  <= balances[top3[2]] ) {
            return 0;
        } else if(balances[top3[1]] <= balances[top3[0]]   && balances[top3[1]]  <= balances[top3[2]] ){
            return 1;
        } else {
            return 2;
        }
    }

     function withdraw() virtual public   {
    
         uint256 b = address(this).balance;
         owner.transfer(b);
    }

  
}

contract BigBank is Bank{

       modifier checkValue () {
        require(msg.value > 0.001 ether, "Must be greater than 0.001 ether");
        _;
    }
        modifier onlyOwner () {
         require(msg.sender == owner, "Only owner can call this function");
        _;
    }

     function deposit() override public payable checkValue {
       super.deposit();
    }

     function withdraw() override public onlyOwner  {
        super.withdraw();
    }
    
}

contract Ownable  {


     function withdraw(address bank) external  {
       
           IBank(bank).withdraw();
     }

     receive() external payable { }

}
