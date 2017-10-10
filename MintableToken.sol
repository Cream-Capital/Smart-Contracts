pragma solidity ^0.4.16;

import "./Ownable.sol";
import "./ERC223Token.sol";


/**
 * A token that can increase its supply by another contract.
 *
 * This allows uncapped crowdsale by dynamically increasing the supply when money pours in.
 * Only mint agents, contracts whitelisted by owner, can mint new tokens.
 *
 */
contract MintableToken is ERC223Token, Ownable {

    /** List of agents that are allowed to create new tokens */
    mapping (address => bool) public mintAgents;

    event MintingAgentChanged(address addr, bool state  );


    /**
     * Create new tokens and allocate them to an address..
     *
     * Only callably by a crowdsale contract (mint agent).
     */
    function mint(address receiver, uint amount) onlyMintAgent public {
        totalSupply = safePlus(totalSupply,amount);
        balances[receiver] = safePlus(balances[receiver],amount);

        // This will make the mint transaction apper in EtherScan.io
        // We can remove this after there is a standardized minting event
        Transfer(0, receiver, amount);
    }

    /**
     * Owner can allow a crowdsale contract to mint new tokens.
     */
    function setMintAgent(address addr, bool state) onlyOwner public {
        mintAgents[addr] = state;
        MintingAgentChanged(addr, state);
    }

    function safePlus(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c>=a);
        return c;
    }

    modifier onlyMintAgent() {
        // Only crowdsale contracts are allowed to mint new tokens
        if(!mintAgents[msg.sender]) {
            revert();
        }
        _;
    }

}