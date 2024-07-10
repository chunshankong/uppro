pragma solidity >=0.7.0 <0.9.0;

contract Counter {

     uint public counter;

     constructor() {
        counter = 0;
     }

    function count() public {
        counter = counter + 1;
    }
    
    function get() public view returns (uint){
        return counter;
    }

    function add(uint x) public  {
        counter = counter + x;
    }
     

}
