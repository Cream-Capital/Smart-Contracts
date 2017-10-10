pragma solidity ^0.4.16;
/*
* Contract that is working with ERC223 tokens
*/

contract ContractReceiver {

    function tokenFallback(address _from, uint _value, bytes _data) public;
}