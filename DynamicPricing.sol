pragma solidity ^0.4.16;

import "./SafeMath.sol";
import "./Ownable.sol";

/**
 * Dynamic pricing in ETH-Wei so that everybody gets the same price in USD.
 */
contract DynamicPricing is SafeMath, Ownable {


    uint public buyPriceInWei  = 4000000000000000;//250 Cream/ETH
    uint public sellPriceInWei = 3500000000000000;//285 Cream/ETH
    event PricingChanged(uint _buyPriceInWei, uint _sellPriceInWei);
    /** List of agents that are allowed to set the price of the tokens */
    mapping (address => bool) public pricingAgents;

    event PricingAgentChanged(address addr, bool state);

    /**
     * Calculate the number of tokens to be issued from the amount of weis received.
     *
     */
    function calculateNumberOfTokensFromWei(uint weiReceived) public constant returns (uint256) {
        return safeDiv(weiReceived, safeDiv(buyPriceInWei, 100));//assuming 2 decimals
    }

    /**
     * Calculate the number of weis to be transferred from the amount of Cream Cash received.
     *
     */
    function calculateNumberOfWeiFromTokens(uint tokensReceived) public constant returns (uint) {
        return safeDiv(safeMul(sellPriceInWei, tokensReceived), 100);//assuming 2 decimals
    }

    function setTokenPriceInWei(uint _buyPriceInWei, uint _sellPriceInWei) public onlyPricingAgent {
        require(_buyPriceInWei > 0);
        require(_sellPriceInWei > 0);
        require(_buyPriceInWei > _sellPriceInWei );
        buyPriceInWei = _buyPriceInWei;
        sellPriceInWei = _sellPriceInWei;
        PricingChanged(_buyPriceInWei, _sellPriceInWei);
    }

    /**
     * Owner can allow a crowdsale contract to mint new tokens.
     */
    function setPricingAgent(address addr, bool state) onlyOwner public {
        pricingAgents[addr] = state;
        PricingAgentChanged(addr, state);
    }

    function safePlus(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c>=a);
        return c;
    }

    modifier onlyPricingAgent() {
        // Only pricing agents are allowed to set the price
        if(!pricingAgents[msg.sender]) {
            revert();
        }
        _;
    }

}