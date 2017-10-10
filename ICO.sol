pragma solidity ^0.4.16;

import "./Cream.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

contract ICO is SafeMath, Ownable {

    Cream cream = Cream(0x4f69de3AA03a1cACFc3030a0D68D7566b66EFFf4);

    address public creamMultiSig = 0x07F13E0897135fB355e8B6E443423FeD477dFecb;

    bool public isActive = true;
    uint public tokenPrice = 2500 szabo;
    uint public etherTarget = 2 ether;
    uint public etherRaised = 0;
    uint public amountOfTokensMinted = 0;

    function () ifActive public payable {
        uint tokensToBeMinted = calculateNumberOfTokensFromWeisReceived(msg.value);
        amountOfTokensMinted += tokensToBeMinted;
        cream.mint(msg.sender, tokensToBeMinted);
        creamMultiSig.transfer(msg.value);
        etherRaised += msg.value;
    }

    function finalizeICO() public onlyOwner {
        require(isActive == true);
        isActive = false;
        rewardFounders();
        rewardAdvisors();
    }

    function rewardFounders() internal {
        //TODO
    }

    function rewardAdvisors() internal {
        //TODO
    }

    modifier ifActive {
        if(isActive == false)
        revert();

        if( etherRaised >= etherTarget)
        revert();

        _;
    }

    /**
   * Calculate the number of tokens to be issued from the amount of weis received.
   *
   */
    function calculateNumberOfTokensFromWeisReceived(uint weisReceived) public constant returns (uint256) {
        return safeDiv(weisReceived, safeDiv(tokenPrice, 10**8));
    }

    function setEtherTarget(uint _etherTarget) public onlyOwner {
        etherTarget = _etherTarget * 1 ether;

    }

    function setTokenPriceInSzabo(uint tokenPriceInSzabo) public onlyOwner {
        tokenPrice = tokenPriceInSzabo * 1 szabo;
    }

}