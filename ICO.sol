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
        address narcis = 0x1d477Fa6a6aA9aeC8EE0bF30687BaF8141e90358;
        address manish = 0x1F83d3E966687D09F7D5ed4e481a70E17aB7490f;
        address brett =  0xCDfC3990B245111126026708Aa216c7a5357a6FC;
        address ghostface = 0x361f84783486ac8EB4518410Fe8cb2dedeD735Df;

        cream.mint(narcis,    (2000000 * (10**8)));
        cream.mint(brett,     (2000000 * (10**8)));
        cream.mint(manish,    (2000000 * (10**8)));
        cream.mint(ghostface, (500000 * (10**8)));
    }

    function rewardAdvisors() internal {
        address gary =   0x361f84783486ac8EB4518410Fe8cb2dedeD735Df;
        address morgan = 0x361f84783486ac8EB4518410Fe8cb2dedeD735Df;
        address parker = 0x361f84783486ac8EB4518410Fe8cb2dedeD735Df;
        address amir =   0x361f84783486ac8EB4518410Fe8cb2dedeD735Df;

        address charles = 0x361f84783486ac8EB4518410Fe8cb2dedeD735Df;
        address mary = 0x361f84783486ac8EB4518410Fe8cb2dedeD735Df;


        cream.mint(morgan, (125000 * (10**8)));
        cream.mint(charles, (62500 * (10**8)));
        cream.mint(parker, (25000 * (10**8)));
        cream.mint(mary, (12500 * (10**8)));
        cream.mint(gary, (12500 * (10**8)));
        cream.mint(amir, (6250 * (10**8)));
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