pragma solidity ^0.4.16;

import "./MintableToken.sol";

contract CappedMintableToken is MintableToken{
    uint256 public supplyCap;

    function CappedMintableToken(uint _supplyCap){
        supplyCap = _supplyCap;
    }

    function mint(address receiver, uint amount) onlyMintAgent public {
        assert(totalSupply_.add(amount) <= supplyCap);
        MintableToken.mint(receiver, amount);
    }
}