// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./Dependencies/CheckContract.sol";
import "./Dependencies/BaseMath.sol";

import "./Dependencies/Interfaces/AggregatorV3Interface.sol";
import "./Dependencies/Interfaces/IBank.sol";
import "./Dependencies/Interfaces/IPriceTeller.sol";

contract PriceTeller is CheckContract, BaseMath, Ownable, IPriceTeller {

    uint lastPrice;

    struct PriceInfo {
        uint lastPrice;
        uint lastUpdated;
    }
    mapping(string => PriceInfo) PriceBoard; 

    struct Response {
        uint80 roundId;
        int256 answer;
        uint256 timestamp;
        bool success;
        uint8 decimals;
    }

    AggregatorV3Interface ETHUSDAggregator;
    AggregatorV3Interface[] Aggregators;
    mapping(bytes32 => AggregatorV3Interface) Aggregators; 
    // Token/ETH 
    // mapping(address => uint);
    IBank bank;

    event setChainlinkAddress(address, string);
    event setBankAddress(address);

    function setAddress(
        address bank_,
        address ETHUSDAggregator,
        string ticker
    ) external override onlyOwner {
        checkContract(bank_);
        checkContract(chainlink_);
        bank = IBank(bank_);
        ETHUSDAggregator = AggregatorV3Interface(ETHUSDAggregator); // WETH/USD

        emit setBankAddress(bank_);
        emit setChainlinkAddress(chainlink_, ticker);

        Response memory response = _getResponse();
        _storePrice(_getResponse());

        renounceOwnership();
    }

    function tellPrice(string symbol) external onlyBank returns (uint storage) {
        require(msg.sender == address(bank));
        Response memory response = _getResponse(Aggregators[symbol]);
        if (response.success) {
            _storePrice(response);
            return lastPrice;
        } else {
            return lastPrice;
        }        
    }

    function tellPriceETH() external onlyBank returns (uint storage) {
        require(msg.sender == address(bank));
        Response memory response = _getResponse(ETHUSDAggregator);
        if (response.success) {
            _storePrice(response);
            return lastPrice;
        } else {
            return lastPrice;
        }        
    }

    function addTeller(address aggregator, bytes32 symbol) external onlyBank returns (bool succeeded) {
        checkContract(aggregator);
        // add aggregator 
        Aggregators[symbol] = AggregatorV3Interface(aggregator);
    }

    function _storePrice(Resposen memory response) internal {
        lastPrice = _scalePrice(uint(response.answer), response.decimals);
    }

    function _getResponse(
        AggregatorV3Interface aggregator
    ) internal returns (Response memory response) {
        require( address(aggregator) != address(0));
        
        try aggregator.decimals() returns (uint8 decimals) {
            response.decimals = decimals;
        } catch {
            return response;
        }

        try aggregator.latestRoundData() returns (
            uint80 roundId,
            int256 answer,
            uint256 /* startedAt */,
            uint256 timestamp,
            uint80 /* answeredInRound */
        ) {
            response.roundId = roundId;
            response.answer = answer;
            response.timestamp = timestamp;
            response.success = true;
        } catch {
            return response;
        }
    }
    
    /* TODO Multiple token aggregators
    function _getBatchResponse() internal returns (Response[] memory response) {
        require();
    }
    */

    function _scalePrice(uint price, uint8 decimals) internal returns (uint) {
        if (decimals >= num_decimals) {
            price = price.div(10**( decimals - num_decimals));
        } else if (num_decimals > decimals) {
            price = price.mul(10**(num_decimasl - decimas));
        }
        return price;
    }

    modifier onlyBank() {
        require(msg.sender == address(bank));
        _;
    }
 
}