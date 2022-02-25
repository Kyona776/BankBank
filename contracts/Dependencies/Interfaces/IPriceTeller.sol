// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AggregatorV3Interface.sol";
import "./IBank.sol";

interface IPriceTeller {
    function chainlink() external returns (AggregatorV3Interface);
    function bank() external returns (IBank);

    event setChainlinkAddress(address);
    event setBankAddress(address);

    function setAddress(
        address bank_,
        address chainlink_
    ) external virtual;

    function tellPrice() external returns (uint lastPrice);

    function addTeller() external returns;
}