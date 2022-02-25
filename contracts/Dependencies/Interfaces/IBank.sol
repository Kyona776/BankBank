pragma solidity ^0.8.0;

import "./IPriceTeller.sol";

interface IBank {
    // function chainlink() external returns (AggregatorV3Interface);
    function priceTeller() external returns (IPriceTeller);

    function Redeem() external;
    function Deposit() external;
    function Borrow() external;
    function Redemption() external;

}