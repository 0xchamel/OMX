# Overview

The DeFiPoolRouter is a smart contract written in Solidity that serves as a router for interacting with different DeFi pools. It allows users to deposit and withdraw liquidity from various pools, as well as claim rewards. This readme provides detailed instructions on adding pools to the router.
##Pools

In the context of this contract, a "pool" refers to a DeFi strategy or adapter that implements the IAdapter interface. Each pool is associated with a specific adapter contract that defines how to add and remove liquidity for a particular protocol.  <br/>

## Adding Pools
##### Owner Functions

The ability to add pools is restricted to the owner of the contract. The owner can add pools using the addPool and setPool functions.

**1. Add Pools**
To add multiple pools at once, use the addPool function. The function takes an array of adapter addresses as an argument.

> function addPool(address[] memory _adapters) external onlyOwner

  - _adapters: An array of addresses representing the adapters for the new pools.

Example:
`
// Adding three pools with corresponding adapters
address[] memory adapters = [0xAdapter1, 0xAdapter2, 0xAdapter3];
addPool(adapters);
`

**2. Set Pool**
If you need to modify the adapter address for an existing pool, use the setPool function.

> function setPool(uint256 _poolId, address _adapter) external onlyOwner

 - _poolId: The index of the pool to be modified.
 - _adapter: The new address of the adapter for the specified pool.

Example:

`// Changing the adapter for pool with index 0

setPool(0, 0xNewAdapter);`

##### User Functions

Users interact with the contract by depositing and withdrawing liquidity from the pools.
**1. Deposit**

To add liquidity to a specific pool, users can call the deposit function.

solidity

function deposit(uint256 _poolId, address _token, uint256 _amount) external payable whenNotPaused nonReentrant

    _poolId: The index of the pool where liquidity will be added.
    _token: The address of the token being deposited.
    _amount: The amount of tokens to deposit.

Example:

solidity

// Depositing 10 tokens into pool with index 1
deposit(1, 0xToken, 10);

**2. Withdraw**

Users can also withdraw liquidity from a pool using the withdraw function.

> function withdraw(uint256 _poolId, address _token, uint256 _amount) external payable whenNotPaused nonReentrant

    _poolId: The index of the pool from which liquidity will be withdrawn.
    _token: The address of the token being withdrawn.
    _amount: The amount of tokens to withdraw.

Example:

`// Withdrawing 5 tokens from pool with index 2

withdraw(2, 0xToken, 5);
`

#### Rewards

Users can check and claim pending rewards from a pool.
**1. Pending Rewards**

To check the pending rewards for a user in a pool, use the pendingReward function.

solidity

function pendingReward(uint256 _poolId, address _user) public returns (uint256 amountOut)

    _poolId: The index of the pool for which to check pending rewards.
    _user: The address of the user for whom to check pending rewards.

Example:

solidity

// Checking pending rewards for the user in pool with index 1
uint256 pendingRewards = pendingReward(1, 0xUserAddress);

**2. Claim Rewards**

To claim rewards from a pool, users can call the claim function.

function claim(uint256 _poolId) public returns (uint256 amountOut)

 -  _poolId: The index of the pool from which to claim rewards.

Example:

// Claiming rewards from pool with index 0
uint256 claimedRewards = claim(0);

##### Events

The contract emits two events for tracking liquidity-related activities:

> event AddLiquidity(uint256 indexed poolId, address indexed token, uint256 amount);
> event RemoveLiquidity(uint256 indexed poolId, address indexed token, uint256 amount);
> event Claimed(uint256 indexed poolId, address indexed user, uint256 amount);

These events can be used to monitor and analyze the liquidity movements within the contract.
Security Considerations

The contract utilizes OpenZeppelin libraries for access control, pausing functionality, and reentrancy protection.
Ensure that the IAdapter interface is implemented correctly by any adapter contracts added to the router.

### Disclaimer

This readme provides an overview of the DeFiPoolRouter contract and its functionality. Users and developers should thoroughly review the contract code and perform due diligence before interacting with the contract or adding custom adapter contracts. Use at your own risk.
