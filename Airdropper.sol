pragma solidity ^0.4.0;

import "./Ownable.sol";
import "./ERC20.sol";

contract Airdropper is Ownable {

    function multisend(address _tokenAddr, address[] dests, uint256[] values) onlyOwner returns (uint256) {
        uint256 i = 0;
        while (i < dests.length) {
            ERC20(_tokenAddr).transfer(dests[i], values[i]);
            i += 1;
        }
        return (i);
    }
}
