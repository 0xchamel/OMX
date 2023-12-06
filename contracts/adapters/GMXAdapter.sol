// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {IRewardRouter} from "../interfaces/IRewardRouter.sol";
import {IRewardTracker} from "../interfaces/IRewardTracker.sol";

contract GMXAdapter {
    using SafeERC20 for IERC20;

    // address of investment contract
    IRewardRouter public strategy;

    // address of reward tracker
    IRewardTracker public rewardTracker =
        IRewardTracker(0x4e971a87900b931fF39d1Aad67697F49835400b6);

    // stakingToken for GLP
    IERC20 public stakingToken;

    // address of defiPoolRouter
    address public defiPoolRouter;

    // WETH token address
    address public WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    constructor(address defiPoolRouter_, address strategy_, address stakingToken_) {
        strategy = IRewardRouter(strategy_);
        stakingToken = IERC20(stakingToken_);
        defiPoolRouter = defiPoolRouter_;
    }

    modifier onlyDefiPoolRouter() {
        require(msg.sender == defiPoolRouter, "Invalid DefilPoolRouter");
        _;
    }

    modifier onlyValidToken(address token) {
        require(token == address(stakingToken), "Invalid Token");
        _;
    }

    function addLiquidity(
        address _token,
        uint256 _size
    ) external payable onlyDefiPoolRouter onlyValidToken(_token) returns (uint256 amountOut) {
        // transfer tokens from defiPoolRouter
        stakingToken.safeTransferFrom(msg.sender, address(this), _size);

        // approve
        stakingToken.safeApprove(address(strategy), 0);
        stakingToken.safeApprove(address(strategy), _size);

        // stake index token & get glp
        amountOut = strategy.mintAndStakeGlp(_token, _size, 0, 0);
    }

    function removeLiquidity(
        address _tokenOut,
        uint256 _glpAmount
    ) external payable onlyDefiPoolRouter onlyValidToken(_tokenOut) returns (uint256 amountOut) {
        // unstake & get index token
        amountOut = strategy.unstakeAndRedeemGlp(_tokenOut, _glpAmount, 0, address(this));

        // transfer to msg.sedner
        stakingToken.safeTransfer(msg.sender, amountOut);
    }

    function pendingReward() external view returns (uint256 amount) {
        return rewardTracker.claimable(address(this));
    }

    function claim() external returns (uint256) {
        uint256 claimed = rewardTracker.claim(address(this));

        return claimed;
    }
}
