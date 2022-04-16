// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/**
 * @title Mobula Private Sale contract
 * @dev punpom on github
 **/

contract MobulaPrivateSale is Ownable {

    IERC20 private MOBULA;
    IERC20 private USDC;

    uint private constant MAX_USDC_ALLOWED = 1000 ** 6;
    uint private constant MAX_USDC_ALLOWED_PER_USER = 10 ** 6;

    bool public privateSaleended;

    uint public tokenPerUSDC = 1;

    bytes32 public merkleRoot;

    mapping(address => uint) public amountUSDCPerWallet;

    constructor(bytes32 _merkleRoot, IERC20 _MOBULA, IERC20 _USDC) {
        merkleRoot = _merkleRoot;
        MOBULA = _MOBULA;
        USDC = _USDC;
    }

     modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    function deposit(uint256 _amount, bytes32[] calldata _proof) public callerIsUser {
        require(USDC.balanceOf(address(this)) + _amount <= MAX_USDC_ALLOWED);
        require(privateSaleended == false, "Private Sale ended");
        require(amountUSDCPerWallet[msg.sender] < MAX_USDC_ALLOWED_PER_USER, "You have used all of ur whitelist");
        require(isWhiteListed(msg.sender, _proof));
        USDC.transferFrom(msg.sender, address(this), _amount);
    }

    function claim(bytes32[] calldata _proof) external callerIsUser {
        require(privateSaleended == false, "Private Sale ended");
        require(isWhiteListed(msg.sender, _proof));
        require(amountUSDCPerWallet[msg.sender] > 1);
        MOBULA.transferFrom(address(this), msg.sender, amountUSDCPerWallet[msg.sender] * tokenPerUSDC);
    }

    function endPrivateSale(bool _end) public onlyOwner {
        privateSaleended = _end;
    }

    function withdraw() external onlyOwner {
        USDC.transfer(msg.sender, USDC.balanceOf(address(this)));
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function isWhiteListed(address _account, bytes32[] calldata _proof) internal view returns(bool) {
        return _verify(leaf(_account), _proof);
    }

    function leaf(address _account) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(_account));
    }

    function _verify(bytes32 _leaf, bytes32[] memory _proof) internal view returns(bool) {
        return MerkleProof.verify(_proof, merkleRoot, _leaf);
    }

}
