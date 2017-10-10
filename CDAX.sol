pragma solidity ^0.4.16;

import "./DynamicPricing.sol";
import "./CreamCash.sol";
import "./Pausable.sol";
import "./ContractReceiver.sol";

contract CDAX is DynamicPricing, ContractReceiver, Pausable{
    address creamCashAddress = 0x3970e0E44a024cdD30bb04EcdE910E18a53480f9;
    CreamCash creamCash = CreamCash(creamCashAddress);
    event AddressChanged(address newCreamCashAddress);
    event CreamCashPurchased(uint amount, uint _buyPriceInWei, address who);
    event CreamCashSold(uint amount, uint _sellPriceInWei, address who);

    function () whenNotPaused public payable {
        uint amount = calculateNumberOfTokensFromWei(msg.value);
        creamCash.mint(msg.sender, amount);
        CreamCashPurchased(amount, buyPriceInWei, msg.sender);
    }

    /**
     * Called when Cream Cash has been sent to be exchanged with ETH
     */
    function tokenFallback(address from, uint amount, bytes data) public whenNotPaused onlyCreamCash {
        uint weiValue = calculateNumberOfWeiFromTokens(amount);
        from.transfer(weiValue);
        creamCash.burn(amount);
        CreamCashSold(amount, sellPriceInWei, from);
    }

    function depositFunds() public payable {

    }

    function withdraw (uint amountInWei, address where) public onlyOwner {
        where.transfer(amountInWei);
    }

    /**
    * @dev Throws if called by any contract other than the CreamCash contract.
    */
    modifier onlyCreamCash() {
        require(msg.sender == creamCashAddress);
        _;
    }


    /**
     * @dev Allows the current owner to change the address of the CreamCash contract in case an upgrade has been made
     */
    function setCreamCashAddress(address newCreamCashAddress) public onlyOwner {
        creamCashAddress = newCreamCashAddress;
        creamCash = CreamCash(creamCashAddress);
        AddressChanged(creamCashAddress);
    }
}