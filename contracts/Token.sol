import "erc-payable-token/contracts/token/ERC1363/ERC1363.sol";

contract TokenStable is ERC1363 {

    constructor(uint256 totalSupply) ERC20("StableToken", "TKN") {
        _mint(msg.sender, totalSupply);
    }
}