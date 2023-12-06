// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IAdapter.sol";

contract DeFiPoolRouter is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 userShare;
        uint256 rewardDebt;
    }

    struct PoolInfo {
        address adapter;
        uint256 tvl;
        uint256 accTokenShare;
    }

    // length of pools array
    uint256 public poolLen;

    // pool id => adapter address
    mapping(uint256 => PoolInfo) public poolInfos;

    // pool id => user address => UserInfo
    mapping(uint256 => mapping(address => UserInfo)) public userInfos;

    /// @dev events
    event AddLiquidity(uint256 indexed poolId, address indexed token, uint256 amount);
    event RemoveLiquidity(uint256 indexed poolId, address indexed token, uint256 amount);
    event Claimed(uint256 indexed poolId, address user, uint256 amount);

    modifier _updatePool(uint256 _poolId) {
        PoolInfo storage poolInfo = poolInfos[_poolId];
        uint256 rewards = _claim(_poolId);

        if (poolInfo.tvl != 0) {
            poolInfo.accTokenShare += (rewards * 1e12) / poolInfo.tvl;
        }
        _;
    }

    /**
     * @notice Add liquidity via Pool
     * @param _poolId strategy pool index
     * @param _token index token address
     * @param _amount amount of index token
     */
    function deposit(
        uint256 _poolId,
        address _token,
        uint256 _amount
    ) external payable whenNotPaused nonReentrant _updatePool(_poolId) {
        address _adapter = poolInfos[_poolId].adapter;
        UserInfo storage userInfo = userInfos[_poolId][msg.sender];
        PoolInfo storage poolInfo = poolInfos[_poolId];

        // 1. token transfer
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

        // 2. approve pool to use
        IERC20(_token).safeApprove(_adapter, 0);
        IERC20(_token).safeApprove(_adapter, _amount);

        // 3. add liquidity
        IAdapter(_adapter).addLiquidity(_token, _amount);

        // 4. update poolInfo, userInfo
        poolInfo.tvl += _amount;
        if (userInfo.amount != 0) {
            userInfo.rewardDebt +=
                ((poolInfo.accTokenShare - userInfo.userShare) * userInfo.amount) /
                1e12;
        }
        userInfo.userShare = poolInfo.accTokenShare;
        userInfo.amount += _amount;

        emit AddLiquidity(_poolId, _token, _amount);
    }

    /**
     * @notice Remove liquidity via Pool
     * @param _poolId strategy pool index
     * @param _token index token address
     * @param _amount amount of index token
     */
    function withdraw(
        uint256 _poolId,
        address _token,
        uint256 _amount
    ) external payable whenNotPaused nonReentrant {
        address _adapter = poolInfos[_poolId].adapter;
        UserInfo storage userInfo = userInfos[_poolId][msg.sender];
        PoolInfo storage poolInfo = poolInfos[_poolId];

        // 1. remove liquidity
        uint bal = IERC20(_token).balanceOf(address(this));
        IAdapter(_adapter).removeLiquidity(_token, _amount);

        // 2. check token received
        bal = IERC20(_token).balanceOf(address(this));
        require(bal >= _amount, "Failed: Remove Liquidity");

        // 3. send user
        IERC20(_token).safeTransfer(msg.sender, _amount);

        // 4. update poolInfo, userInfo
        poolInfo.tvl -= bal;
        userInfo.amount -= bal;
        userInfo.rewardDebt = 0;

        // 5. claim rewards
        claim(_poolId);

        emit RemoveLiquidity(_poolId, _token, _amount);
    }

    function pendingReward(uint256 _poolId, address _user) public returns (uint256 amountOut) {
        UserInfo memory userInfo = userInfos[_poolId][_user];
        PoolInfo memory poolInfo = poolInfos[_poolId];

        uint256 pending = IAdapter(poolInfos[_poolId].adapter).pendingReward();
        uint256 updatedAccTokenShare = poolInfo.accTokenShare + (pending * 1e12) / poolInfo.tvl;

        amountOut =
            (updatedAccTokenShare - userInfo.userShare) *
            userInfo.amount +
            userInfo.rewardDebt;
    }

    function claim(uint256 _poolId) public returns (uint256 rewards) {
        UserInfo storage userInfo = userInfos[_poolId][msg.sender];
        PoolInfo storage poolInfo = poolInfos[_poolId];

        rewards =
            ((poolInfo.accTokenShare - userInfo.userShare) * userInfo.amount) /
            1e12 +
            userInfo.rewardDebt;
        userInfo.rewardDebt = 0;
        userInfo.userShare = poolInfo.accTokenShare;

        IERC20(IAdapter(poolInfo.adapter).stakingToken()).safeTransfer(msg.sender, rewards);
        emit Claimed(_poolId, msg.sender, rewards);
    }

    function _claim(uint256 _poolId) internal returns (uint256 rewards) {
        rewards = IAdapter(poolInfos[_poolId].adapter).claim();
    }

    //////////////////
    /// Owner Func ///
    //////////////////

    function addPool(address[] memory _adapters) external onlyOwner {
        require(_adapters.length != 0, "Invalid array");
        uint256 len = _adapters.length;

        for (uint i = 0; i < len; ) {
            poolInfos[poolLen] = PoolInfo(_adapters[i], 0, 0);

            unchecked {
                ++i;
                ++poolLen;
            }
        }
    }

    function setPool(uint256 _poolId, address _adapter) external onlyOwner {
        poolInfos[_poolId].adapter = _adapter;
    }

    receive() external payable {}
}
