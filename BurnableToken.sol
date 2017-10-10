pragma solidity ^0.4.16;

import "./ERC223Token.sol";


contract BurnableToken is ERC223Token {

    /** How many tokens we burned */
    event Burned(address burner, uint burnedAmount);

    /**
     * Burn extra tokens from a balance.
     *
     */
    function burn(uint burnAmount) {
        address burner = msg.sender;
        balances[burner] = safeSub(balances[burner], burnAmount);
        totalSupply = safeSub(totalSupply, burnAmount);
        Burned(burner, burnAmount);
    }
}