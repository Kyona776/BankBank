pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./BaseMath.sol";

library Liquidate_Math {
    using SafeMath for uint;

    uint internal constant DECIMAL_PRECISION = 1e18;
    uint internal constant PERCENTAGE_PRECISION = 1e20;

    function CollRate(uint coll, uint debt) internal pure returns (uint) {
        if (debt > 0) {
            return coll.div(debt).mul(PERCENTAGE_PRECISION);
        } else {
            return 2**256 -1; // reutrn inf CR
        }
    }
    // num_token = num_weth *  weth in usd / token in usd 
    // factor = WETH / Token(1 usd)
    function amountInRate(uint rate, uint factor, uint collAmount) internal pure returns (uint) {
        return factor.mul(collAmount).div(1e2).mul(rate); // TODO handling for decimal rounding
    }
    // rate = coll*collP / debt*debtP
    // rate * debt = coll*collP /debtP
    // rate * debt = (coll/debtP)*(collP/debtP)


    function CalRate(uint coll, uint collP, uint debt, uint debtP) internal pure returns (uint rate) {
        uint collPrice = coll.mul(collP).div(DECIMAL_PRECISION);
        uint debtPrice = debt.mul(debtP).div(DECIMAL_PRECISION);
        rate = collPrice.div(debtPrice);
    }
}