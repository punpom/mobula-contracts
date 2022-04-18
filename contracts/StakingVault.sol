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
	
	int public REWARD_PER_BLOCK;

	 constructor(IERC20 _MOBULA, IERC20 _USDT) {
        MOBULA = _MOBULA;
        USDT = _USDT;
    }

	 modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

	function deposit(uint256 _amount) public callerIsUser {
        USDT.transferFrom(msg.sender, address(this), _amount);
    }

}