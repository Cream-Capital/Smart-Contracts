pragma solidity ^0.4.16;

import "./UpgradableToken.sol";
import "./BurnableToken.sol";
import "./CappedMintableToken.sol";

contract Cream is CappedMintableToken, UpgradeableToken(msg.sender), BurnableToken {


    function Cream() CappedMintableToken(100000000 * (10 ** 8)){
        symbol = "CREAM";
        name = "Cream";
        decimals = 8;

    }
}