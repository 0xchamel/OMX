// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract BaseAdapter {
    struct UserInfo {
        address user;
        uint256 amount;
    }

    function addLiquidity(address _token, uint256 _size) external payable virtual {}

    function removeLiquidity(address _token, uint256 _size) external payable virtual {}
}
