// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IAdapter {
    function stakingToken() external returns (address);

    function rewardToken() external returns (address);

    function addLiquidity(address _token, uint256 _size) external payable returns (uint256);

    function removeLiquidity(address _token, uint256 _size) external payable returns (uint256);

    function pendingReward() external returns (uint256);

    function claim() external returns (uint256);
}
