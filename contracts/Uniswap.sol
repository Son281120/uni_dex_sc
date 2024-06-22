// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Uniswap is Ownable(msg.sender) {
    uint256 public fee = 2;

    function getBalanceOfToken(address token) public view returns (uint256) {
        uint balanceOfToken = IERC20(token).balanceOf(msg.sender);
        return balanceOfToken;
    }

    function getAmountInMax(address token) public view returns (uint256) {
        uint256 balance = IERC20(token).balanceOf(msg.sender);
        uint256 amountInMax = (balance * (100 - fee)) / 100;
        return amountInMax;
    }

    function getAmountOut(
        address token1,
        address token2,
        uint256 priceToken1,
        uint256 priceToken2,
        uint256 amountIn
    ) public view returns (uint256) {
        require(amountIn > 0, "AmountIn must be greater than 0");
        uint256 balanceOfToken1 = IERC20(token1).balanceOf(msg.sender);
        require(
            amountIn <= balanceOfToken1,
            "Your token1 balance is insufficient"
        );
        uint256 amountInAfterFee = (amountIn * (100 - fee)) / 100;
        uint256 amountOut = (amountInAfterFee * priceToken1) / priceToken2;
        uint256 contractToken2Balance = IERC20(token2).balanceOf(address(this));
        require(
            amountOut <= contractToken2Balance,
            "Insufficient token2 balance in contract"
        );
        return amountOut;
    }

    function getAmountIn(
        address token1,
        address token2,
        uint256 priceToken1,
        uint256 priceToken2,
        uint256 amountOut
    ) public view returns (uint256) {
        require(amountOut > 0, "AmountOut must be greater than 0");
        uint256 contractToken2Balance = IERC20(token2).balanceOf(address(this));
        require(
            amountOut <= contractToken2Balance,
            "Insufficient token2 balance in contract"
        );

        uint256 amountIn = (amountOut * priceToken2) / priceToken1;

        uint256 amountInAfterFee = (amountIn * (100 + fee)) / 100;
        uint256 balanceOfToken1 = IERC20(token1).balanceOf(msg.sender);
        require(
            amountInAfterFee <= balanceOfToken1,
            "Insufficient token1 balance after fee"
        );
        return amountInAfterFee;
    }

    function swapToken(
        address token1,
        address token2,
        uint256 amountToken1,
        uint256 amountToken2
    ) public {
        uint256 balanceOfToken1 = IERC20(token1).balanceOf(msg.sender);
        require(
            amountToken1 <= balanceOfToken1,
            "Your token1 balance is insufficient"
        );
        // Chuyển token1 từ msg.sender đến contract
        require(
            IERC20(token1).allowance(msg.sender, address(this)) >= amountToken1,
            "Must approve token1 first"
        );
        require(
            IERC20(token1).transferFrom(
                msg.sender,
                address(this),
                amountToken1
            ),
            "Transfer of token1 failed"
        );

        // Chuyển token2 từ contract đến msg.sender
        require(
            IERC20(token2).transfer(msg.sender, amountToken2),
            "Transfer of token2 failed"
        );
    }

    function transferToAddress(
        address token,
        address receiver,
        uint256 amount
    ) public {
        require(amount > 0, "AmountIn must be greater than 0");
        uint256 balanceOfToken = IERC20(token).balanceOf(msg.sender);
        uint256 amountAfterFee = (amount * (100 + fee)) / 100;
        uint256 feeDex = (amount * fee) / 100;
        require(
            amountAfterFee <= balanceOfToken,
            "Insufficient token balance after fee"
        );
        require(
            IERC20(token).allowance(msg.sender, address(this)) >= amount,
            "Must approve token1 first"
        );
        IERC20(token).transferFrom(msg.sender, receiver, amount);
        IERC20(token).transferFrom(msg.sender, address(this), feeDex);
    }

    function getEthAmountOut(
        address token,
        uint256 amountIn,
        uint256 priceToken
    ) public view returns (uint) {
        uint256 amountOut = (amountIn / priceToken) * 10 ** 18;
        uint256 contractTokenBalance = IERC20(token).balanceOf(address(this));
        require(
            amountOut <= contractTokenBalance,
            "Insufficient token balance in contract"
        );
        return amountOut;
    }

    function getEthAmountIn(
        address token,
        uint256 amountOut,
        uint256 priceToken
    ) public view returns (uint) {
        uint256 contractTokenBalance = IERC20(token).balanceOf(address(this));
        require(
            amountOut <= contractTokenBalance,
            "Insufficient token balance in contract"
        );
        uint256 amountIn = (amountOut * priceToken) / 10 ** 18;
        return amountIn;
    }

    function BuyTokenWithETH(
        address token,
        uint256 priceToken
    ) public payable returns (uint256) {
        require(msg.value >= 1000000000000000, "Not enough eth");
        uint256 amountOut = (msg.value / priceToken) * 10 ** 18;
        IERC20(token).transfer(msg.sender, amountOut);
        return amountOut;
    }

    function withdrawETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function withdrawTokens(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        token.transfer(owner(), token.balanceOf(address(this)));
    }
}
