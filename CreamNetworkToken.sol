pragma solidity ^0.4.16;

import "./UpgradableToken.sol";
import "./BurnableToken.sol";
import "./CappedMintableToken.sol";
import "./DetailedERC20.sol";

contract CreamNetworkToken is CappedMintableToken, DetailedERC20, UpgradeableToken(msg.sender), BurnableToken {


    function CreamNetworkToken() CappedMintableToken(100000000 * (10 ** 8)) DetailedERC20("Cream Network Token", "CNT", 8){
    }
}