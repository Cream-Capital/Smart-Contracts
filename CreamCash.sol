pragma solidity ^0.4.16;

import "./UpgradableToken.sol";
import "./BurnableToken.sol";
import "./MintableToken.sol";
import "./Cream.sol";

contract CreamCash is MintableToken, BurnableToken, UpgradeableToken(msg.sender){

    struct Stake{
    uint amount;
    uint daysCommited;
    uint maxReward;
    uint maxUnlockingFee;
    uint addedAt;
    uint creamToBeMinted;
    }

    Cream cream = Cream(0x4f69de3AA03a1cACFc3030a0D68D7566b66EFFf4);
    uint public maxStakingDays = 365;
    uint public minStakingDays = 0;//0 only for testing
    uint public maxReward = 150;// 15%
    uint public maxUnlockingFee=20; //2%
    uint public totalCurrentStakedTokens = 0;
    uint public totalCreamToBeMinted = 0;
    mapping(address => Stake[]) public stakes;
    event StakeAdded(address sender, uint amount, uint daysCommited, uint maxCurrentReward, uint maxFee, uint creamToBeMinted);
    event Unlock(address sender, uint amount, uint daysStaked);
    event CreamClaimed(address sender, uint amount);

    function CreamCash() public{
        symbol = "CREAM";
        name = "Cream Cash";
        decimals = 2;
    }

    function addStake(uint amount, uint daysCommited) public {
        require(daysCommited <= maxStakingDays);
        require(daysCommited >= minStakingDays);

        uint creamToBeMinted = calculateCreamReward(maxStakingDays, maxReward, daysCommited, amount);
        totalCreamToBeMinted += creamToBeMinted;
        if(totalCreamToBeMinted + cream.totalSupply() > cream.supplyCap() )
        revert();


        balances[msg.sender] = safeSub(balances[msg.sender], amount);

        totalCurrentStakedTokens = safeAdd(totalCurrentStakedTokens, amount);

        Stake storage stake;
        stake.amount=amount;
        stake.daysCommited=daysCommited;
        stake.maxReward=maxReward;
        stake.maxUnlockingFee=maxUnlockingFee;
        stake.addedAt=now;
        stake.creamToBeMinted=creamToBeMinted;

        stakes[msg.sender].push(stake);

        StakeAdded(msg.sender, amount, daysCommited, maxReward, maxUnlockingFee, creamToBeMinted);

    }


    function unlock(uint position) public {
        require(stakes[msg.sender].length > position);
        Stake memory stake = stakes[msg.sender][position];
        uint unlockingFee = calculateUnlockingFee(stake.daysCommited, stake.maxUnlockingFee, (now - stake.addedAt) / 1 minutes, stake.amount);
        balances[msg.sender] = safeAdd(balances[msg.sender], stake.amount - unlockingFee);
        burn(unlockingFee);
        totalCreamToBeMinted -= stake.creamToBeMinted;
        totalCurrentStakedTokens = safeSub(totalCurrentStakedTokens, stakes[msg.sender][position].amount);

        delete stakes[msg.sender][position];
        stakes[msg.sender][position] = stakes[msg.sender][stakes[msg.sender].length-1];
        delete stakes[msg.sender][stakes[msg.sender].length-1];
        stakes[msg.sender].length--;

        Unlock(msg.sender, stake.amount, (now - stake.addedAt) / 1 days);

    }

    function claimCream() public {
        uint creamClaimed = 0;
        for(uint i=0;i<stakes[msg.sender].length;i++){
            Stake memory stake = stakes[msg.sender][i];
            if(stake.addedAt + (stake.daysCommited * 1 minutes) < now){//todo: change with days
                balances[msg.sender] = safeAdd(balances[msg.sender], stake.amount);
                uint creamToBeClaimed = calculateCreamReward(maxStakingDays, stake.maxReward, stake.daysCommited, stake.amount);
                cream.mint(msg.sender, creamToBeClaimed);
                totalCreamToBeMinted -= stake.creamToBeMinted;
                totalCurrentStakedTokens = safeSub(totalCurrentStakedTokens, stake.amount);
                creamClaimed += creamToBeClaimed;
                delete stakes[msg.sender][i];
                stakes[msg.sender][i] = stakes[msg.sender][stakes[msg.sender].length -1];
                stakes[msg.sender].length--;
            }
        }
        CreamClaimed(msg.sender, creamClaimed);
    }

    function getCreamReadyForClaim() public constant returns(uint amount){
        uint creamClaimable = 0;
        for(uint i=0;i<stakes[msg.sender].length;i++){
            Stake memory stake = stakes[msg.sender][i];
            if(stake.addedAt + (stake.daysCommited * 1 minutes) < now){//todo: change with days
                creamClaimable += stake.creamToBeMinted;
            }
        }
        return creamClaimable;
    }

    function getCreamCashReadyForClaim(address _owner) public constant returns(uint amount){
        uint amountStakedReadyForClaim = 0;
        for(uint i=0;i<stakes[_owner].length;i++){
            if(stakes[_owner][i].addedAt + (stakes[_owner][i].daysCommited * 1 minutes) < now)      //todo: change with days
            amountStakedReadyForClaim += stakes[_owner][i].amount;
        }
        return amountStakedReadyForClaim;
    }

    function calculateCreamReward(uint _maxStakingDays, uint reward, uint daysStaked, uint amount) public constant returns(uint){
        assert(_maxStakingDays >= daysStaked);
        return ((amount * reward * (daysStaked**2)) / (_maxStakingDays**2)) * (10 ** 3);
    }

    function calculateUnlockingFee(uint daysCommitedForStaking, uint fee, uint daysStaked, uint amount) public constant returns(uint){
        assert(daysCommitedForStaking > daysStaked);
        return ((amount * fee) / 1000) - (amount * fee * (daysStaked**2)) / (1000 * (daysCommitedForStaking**2));
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
        return balances[_owner] + getCreamCashReadyForClaim(_owner);
    }

    function setMaxStakingDays(uint _maxStakingDays) public onlyOwner {
        maxStakingDays = _maxStakingDays;
    }

    function setMinStakingDays(uint _minStakingDays) public onlyOwner {
        minStakingDays = _minStakingDays;
    }

    function setCreamAddress(address creamAddress) public onlyOwner {
        cream = Cream(creamAddress);
    }

    function setMaxReward(uint _maxReward) public onlyOwner {
        maxReward = _maxReward;
    }

    function setMaxUnlockingFee(uint _maxUnlockingFee) public onlyOwner {
        maxUnlockingFee = _maxUnlockingFee;
    }

    function getNumberOfStakes(address who) constant public returns(uint){
        return stakes[who].length;
    }

}