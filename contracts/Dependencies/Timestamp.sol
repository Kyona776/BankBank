// // SPDX-License-Identifier: GPL-3.0


// The miner could cheat in the timestamp by a tolerance of 900 seconds.
abstract contract Timestamp {
    uint avgBlockTime = 13 seconds; // ETH avg block time  12-14 seconds
    uint interval = 460;
    uint lastBlocknum = block.number;
    uint lastupdate = block.timestamp;

    function _setInterval(uint interval_) internal {
        // 460 blocks ~ 10 mins
        interval = interval_;
    }

    function _update() internal returns (bool){
        if ((block.number - lastBlocknum) >=  interval ) {
            return true;
        } else {
            return false;
        }
    }

    function _timeCall() internal view returns (uint) {
        return block.number;
    }

    modifier _updateModi() {
        if ((block.number - lastBlocknum) >=  interval ) {
            _;
        } else {
            _;
        }
    }
}
