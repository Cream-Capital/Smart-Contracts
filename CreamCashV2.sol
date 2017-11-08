pragma solidity ^0.4.16;

import "./UpgradableToken.sol";
import "./BurnableToken.sol";
import "./MintableToken.sol";
import "./Cream.sol";

contract CreamCash is MintableToken, BurnableToken, UpgradeableToken(msg.sender){
    
    Cream cream;
   
    uint public yearlyRewardInCream;
    mapping(address => uint) lastClaimedDates;
    event CreamClaimed(address sender, uint amount);
    
    function CreamCash() public{
        symbol = "CREAM";
        name = "Cream Cash";
        decimals = 2;
        cream = Cream(0x4f69de3AA03a1cACFc3030a0D68D7566b66EFFf4);
        yearlyRewardInCream = cream.supplyCap() / 20; // 5M Cream yearly
        
    }
    
    
    function claimCream() public {
        uint creamClaimed = getCreamReadyForClaim(msg.sender);
        cream.mint(msg.sender, creamClaimed);
        lastClaimedDates[msg.sender] = now;
        CreamClaimed(msg.sender, creamClaimed);
    }
    
    function getCreamReadyForClaim(address who) public constant returns(uint amount){
        return calculateCreamReadyForClaim(lastClaimedDates[who], now, totalSupply, balances[who], yearlyRewardInCream);
    }
    
    function calculateCreamReadyForClaim(uint beginning, uint end, uint creamCashInCirculation, uint creamCashOwned,uint _yearlyRewardInCream) constant returns(uint) {
        return ((((end - beginning) * _yearlyRewardInCream) / (1 years)) * creamCashOwned) / creamCashInCirculation;
    }
    
    function mint(address receiver, uint amount) onlyMintAgent public {
        lastClaimedDates[receiver] = now;
        super.mint(receiver, amount);
  }
    
    function transfer(address _to, uint _value) public returns (bool success){
        claimCream();
        return super.transfer( _to, _value);
    }
    
    function transfer(address _to, uint _value, bytes _data) public returns (bool success){
        claimCream();
        return super.transfer(_to, _value, _data);
    }
    
    function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
        claimCream();
        return super.transfer(_to, _value, _data, _custom_fallback);
    }
    
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }
    
    function setCreamAddress(address creamAddress) public onlyOwner {
        cream = Cream(creamAddress);
    }
    
    function setYearlyRewardInCream(uint _yearlyRewardInCream) public onlyOwner {
        yearlyRewardInCream = _yearlyRewardInCream;
    }

}