// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface ILiquidityHandler {
    function createAddLiquidityOrder(
        address _tokenBuy,
        uint256 _amountIn,
        uint256 _minOut,
        uint256 _executionFee,
        bool _shouldUnwrap
    ) external payable returns (uint256);

    function createRemoveLiquidityOrder(
        address _tokenSell,
        uint256 _amountIn,
        uint256 _minOut,
        uint256 _executionFee,
        bool _shouldUnwrap
    ) external payable returns (uint256);

    function executeOrder(
        uint256 _endIndex,
        address payable _feeReceiver,
        bytes32[] calldata _priceData,
        bytes32[] calldata _publishTimeData,
        uint256 _minPublishTime,
        bytes32 _encodedVaas
    ) external;
}
