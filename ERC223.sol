pragma solidity ^0.4.16;


/* New ERC223 contract interface
https://github.com/ethereum/EIPs/issues/223
*/

contract ERC223 {
    uint public totalSupply;
    function balanceOf(address who) public constant returns (uint);

    function transfer(address to, uint value) public returns (bool ok);
    function transfer(address to, uint value, bytes data) public returns (bool ok);
    function transfer(address to, uint value, bytes data, string custom_fallback) returns (bool ok);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
    event Transfer(address indexed from, address indexed to, uint value);
}