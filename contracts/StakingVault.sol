// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.13;

//@dev punpom
//@title Staking vault contract for Mobula Finance

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MobulaStakingVault is Ownable {

	IERC20 private MOBULA;
    IERC20 private USDT;
	
    uint256 public maximumLocked = 2000 ** 18;
    uint256 public totalLocked;
    uint256 public rewardsPerBlock;

    mapping(address => uint256) balance;
    mapping(address => uint256) lastUpdate;
    mapping(address => uint256) stakersRewards;

    address[] stakers;
    mapping (address => uint256) stakerIndexes;



	 constructor(IERC20 _MOBULA, IERC20 _USDT) {
        MOBULA = _MOBULA;
        USDT = _USDT;
    }

	 modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

	function deposit(uint256 _amount) public callerIsUser {
        require(_amount > 0 && totalLocked + _amount <= maximumLocked);
        USDT.transferFrom(msg.sender, address(this), _amount);
        totalLocked += _amount;
        uint256 _lastUpdate = lastUpdate[msg.sender];
        lastUpdate[msg.sender] = block.number;
        if (balance[msg.sender] > 0) {
			stakersRewards[msg.sender] += (balance[msg.sender] * rewardsPerBlock * (block.number - _lastUpdate)) / 1e16;
		} else {
			addStaker(msg.sender);
		}
        balance[msg.sender] += _amount;
    }

    function withdraw(uint256 amount) public {
		require(amount > 0 && amount <= balance[msg.sender], "You cannot withdraw more than what you have!");
		uint256 _lastUpdate = lastUpdate[msg.sender];
		lastUpdate[msg.sender] = block.number;
		stakersRewards[msg.sender] += (balance[msg.sender] * rewardsPerBlock * (block.number - _lastUpdate)) / 1e16;
		balance[msg.sender] -= amount;
		if (balance[msg.sender] == 0) {
			removeStaker(msg.sender);
		}
		MOBULA.transfer(msg.sender, amount);
        totalLocked -= amount;
    }

       function claim() public {	
        require(stakersRewards[msg.sender] > 0, "No rewards to claim!");
		uint256 _lastUpdate = lastUpdate[msg.sender];
		lastUpdate[msg.sender] = block.number;
		stakersRewards[msg.sender] += (balance[msg.sender] * rewardsPerBlock * (block.number - _lastUpdate)) / 1e16;
		uint256 rewards = stakersRewards[msg.sender];
		stakersRewards[msg.sender] = 0;
		USDT.transfer(msg.sender, rewards);
    }
    
	function modifyRewards(uint256 amount) public onlyOwner {

		for (uint256 i = 0; i < stakers.length; i++) {
			uint256 _lastUpdate = lastUpdate[stakers[i]];
			lastUpdate[stakers[i]] = block.number;
			stakersRewards[stakers[i]] += (balance[stakers[i]] * rewardsPerBlock * (block.number - _lastUpdate)) / 1e16;
		}

		rewardsPerBlock = amount;

	}

    function addStaker(address staker) internal {
        stakerIndexes[staker] = stakers.length;
        stakers.push(staker);
    }

    function removeStaker(address staker) internal {
        stakers[stakerIndexes[staker]] = stakers[stakers.length-1];
        stakerIndexes[stakers[stakers.length-1]] = stakerIndexes[staker];
        stakers.pop();
    }
}