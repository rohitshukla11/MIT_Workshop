// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SimpleDeFiPool {
    IERC20 public token;
    address public owner;
    uint256 public totalLiquidity;
    mapping(address => uint256) public liquidity;

    event LiquidityAdded(address indexed provider, uint256 ethAmount, uint256 tokenAmount);
    event LiquidityRemoved(address indexed provider, uint256 ethAmount, uint256 tokenAmount);
    event Swapped(address indexed trader, uint256 ethIn, uint256 tokenOut);

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    // Add Liquidity (Requires equal ETH & Token amount)
    function addLiquidity(uint256 tokenAmount) external payable {
        require(msg.value > 0, "Must provide ETH");
        require(tokenAmount > 0, "Must provide tokens");
        require(token.transferFrom(msg.sender, address(this), tokenAmount), "Token transfer failed");
        
        liquidity[msg.sender] += msg.value;
        totalLiquidity += msg.value;
        
        emit LiquidityAdded(msg.sender, msg.value, tokenAmount);
    }

    // Remove Liquidity
    function removeLiquidity() external {
        uint256 ethAmount = liquidity[msg.sender];
        require(ethAmount > 0, "No liquidity provided");
        
        uint256 tokenAmount = (token.balanceOf(address(this)) * ethAmount) / totalLiquidity;
        liquidity[msg.sender] = 0;
        totalLiquidity -= ethAmount;
        
        payable(msg.sender).transfer(ethAmount);
        require(token.transfer(msg.sender, tokenAmount), "Token transfer failed");
        
        emit LiquidityRemoved(msg.sender, ethAmount, tokenAmount);
    }

    // Swap ETH to Token
    function swapETHForToken() external payable {
        require(msg.value > 0, "Must send ETH");
        uint256 tokenAmount = (token.balanceOf(address(this)) * msg.value) / (address(this).balance - msg.value);
        require(token.transfer(msg.sender, tokenAmount), "Token transfer failed");
        
        emit Swapped(msg.sender, msg.value, tokenAmount);
    }
}
