pragma solidity ^0.4.16;

import "./CreamCash.sol";

contract CreamCashTests {
    event Calculated(uint);

    function testAddStakeOK(){
        CreamCash creamCash = new CreamCash();
        Cream cream = new Cream();
        creamCash.setCreamAddress(cream);
        creamCash.setMintAgent(this,true);
        cream.setMintAgent(this,true);
        creamCash.setCreamAddress(cream);
        creamCash.setMintAgent(this,true);
        uint amount = 10000 * 100;
        uint daysCommited = 365;
        creamCash.mint(this, amount);
        cream.mint(0x14723a09acff6d2a60dcdf7aa4aff308fddc160c, cream.supplyCap() - (creamCash.calculateCreamReward(365, 150, 365, amount) + 1));
        creamCash.addStake(amount, daysCommited);
        assert(creamCash.getNumberOfStakes(this) == 1);
        assert(creamCash.totalCurrentStakedTokens() == amount);
        assert(creamCash.totalCreamToBeMinted() != 0);

    }

    function BAD_testAddStakeLimitReached(){
        CreamCash creamCash = new CreamCash();
        Cream cream = new Cream();
        creamCash.setCreamAddress(cream);
        creamCash.setMintAgent(this,true);
        cream.setMintAgent(this,true);
        creamCash.setCreamAddress(cream);
        creamCash.setMintAgent(this,true);
        uint amount = 10000 * 100;
        uint daysCommited = 365;
        creamCash.mint(this, amount);
        Calculated(100000000*(10**8));
        Calculated(((((amount * creamCash.maxReward())/1000) * (10 ** 8)) - 1));
        cream.mint(0x14723a09acff6d2a60dcdf7aa4aff308fddc160c, cream.supplyCap() - (creamCash.calculateCreamReward(365, 150, 365, amount) - 1));
        creamCash.addStake(amount, daysCommited);


    }

    function BAD_testAddBadStake(){
        CreamCash creamCash = new CreamCash();
        Cream cream = new Cream();
        creamCash.setCreamAddress(cream);
        creamCash.setMintAgent(this,true);
        uint amount = 10000 * 100;
        uint daysCommited = 365;
        creamCash.mint(this, amount);
        creamCash.addStake(amount +1 , daysCommited);
    }

    function BAD_testAddBadStake_CreamLimitReached(){
        CreamCash creamCash = new CreamCash();
        Cream cream = new Cream();
        creamCash.setCreamAddress(cream);
        creamCash.setMintAgent(this,true);
        cream.setMintAgent(this,true);
        uint amount = 10000 * 100;
        uint daysCommited = 365;
        creamCash.mint(this, amount);
        cream.mint(this, (100000000*(10**8))-1);
        creamCash.addStake(amount +1 , daysCommited);
    }

    function testUnlock(){
        CreamCash creamCash = new CreamCash();
        Cream cream = new Cream();
        creamCash.setCreamAddress(cream);
        creamCash.setMintAgent(this,true);
        cream.setMintAgent(this,true);
        creamCash.setCreamAddress(cream);
        creamCash.setMintAgent(this,true);
        uint amount = 10000 * 100;
        uint daysCommited = 365;
        creamCash.mint(this, amount);
        cream.mint(0x14723a09acff6d2a60dcdf7aa4aff308fddc160c, cream.supplyCap() - (creamCash.calculateCreamReward(365, 150, 365, amount) + 1));
        creamCash.addStake(amount, daysCommited);
        assert(creamCash.getNumberOfStakes(this) == 1);
        creamCash.unlock(0);
        assert(creamCash.getNumberOfStakes(this) == 0);
    }

    function BAD_testUnlock(){
        CreamCash creamCash = new CreamCash();
        creamCash.unlock(0);
    }

    function testUnlockFeeMin(){
        CreamCash creamCash = new CreamCash();
        uint amountCreamCash = 10000;
        assert( creamCash.calculateUnlockingFee(365, 20, 364, amountCreamCash) == 2);
    }

    function testUnlockFeeMax(){
        CreamCash creamCash = new CreamCash();
        uint amountCreamCash = 10000;
        assert( creamCash.calculateUnlockingFee(365, 20, 0, amountCreamCash) == 200);
    }

    function testUnlockFeeBeteen(){
        CreamCash creamCash = new CreamCash();
        uint amountCreamCash = 10000;
        assert( creamCash.calculateUnlockingFee(365, 20, 182, amountCreamCash) == 151);
    }

    function BAD_testUnlockFeeBeteen(){
        CreamCash creamCash = new CreamCash();
        uint amountCreamCash = 10000;
        assert( creamCash.calculateUnlockingFee(365, 20, 182, amountCreamCash) != 152);
    }

    function testCreamRewardMin(){
        CreamCash creamCash = new CreamCash();
        uint amountCreamCash = 10000;
        assert( creamCash.calculateCreamReward(365, 150, 0, amountCreamCash) == 0);
    }

    function testCreamRewardMax(){
        CreamCash creamCash = new CreamCash();
        uint amountCreamCash = 10000;
        assert( creamCash.calculateCreamReward(365, 150, 365, amountCreamCash) == ((amountCreamCash * 15) / 100) * (10 ** 6));
    }

    function testCreamRewardBetween(){
        CreamCash creamCash = new CreamCash();
        uint amountCreamCash = 10000;
        assert( creamCash.calculateCreamReward(365, 150, 182, amountCreamCash) == 372948000);
    }

    function BAD_testCreamRewardBetween(){
        CreamCash creamCash = new CreamCash();
        uint amountCreamCash = 10000;
        assert( creamCash.calculateCreamReward(365, 150, 182, amountCreamCash) != 372948001);
    }

}