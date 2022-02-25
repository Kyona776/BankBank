// import "erc-payable-token/contracts/token/ERC1363/ERC1363.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
// import "erc-payable-token/contracts/payment/ERC1363Payable.sol";

import "./Dependencies/ERC1363Payables.sol";
import "./Dependencies/Liquidate_Math.sol";
import "./Dependencies/BaseUnits.sol";
import "./Dependencies/Interfaces/AggregatorV3Interface.sol";
import "./Dependencies/Interfaces/IPriceTeller.sol";
import "./Dependencies/IterableMapping.sol";
import "./Dependencies/Timestamp.sol";
import "./Dependencies/BaseUnits.sol";

contract Bank is ERC1363Payables, Ownable, ReentrancyGuard, Address, Timestamp, BaseUnits {
    using SafeERC20 for IERC20;
    using Liquidate_Math for uint;
    using Address for address;
    using itmap for IterableMapping;

    string BaseToken;

    uint256 private _WETHp;
    uint256 private _TKNp; // assume 1USD
    uint256 private _avgFactor;
    uint8 private minalRate;
    // uint256 private constant ;

    struct Market {
        // string symbol;
    }

    mapping(string => uint256) tokenPrices; // symbol : price

    struct IndexValue { uint keyIndex; uint value; } // 0: wETH 1: Token
    struct KeyFlag { uint key; bool deleted; } 

    struct itmap {
        mapping(uint => IndexValue) data;
        KeyFlag[] keys;
        uint size;
    }

    itmap public Tokens;

    IPriceTeller private priceTeller;

    address internal Selector;

    struct Account {
        // uint256 deposit;
        deposit[] deposits;
        uint256 debt;
        // uint256 factor;
        uint8 rate;
        Status status;
    }

    enum Status {
        Inactive,
        Active,
        Default 
    }

    struct deposit {
        string Symbol;
        uint256 deposit;
    }

    mapping(address => Account) Accounts;


    constructor(
        IERC1363[] acceptedToken_
    ) ERC1363Payables(acceptedToken_) {
        address(token_).isContract();
        address(acceptedToken_).isContract();
        _WETHp = priceTeller.tellPrice();
        // assume TKN is stable coin hard pegged to usd
        _TKNp = DECIMAL_PRECISION;
        mininalRate = 150;
    }

    function setAddress(
        IPriceTeller priceTeller_
    ) external onlyOwner {
        priceTeller_.isContract();
        priceTeller = IPriceTeller(priceTeller_);
        Selector = _msgSender();
        renouceOwner();
    }

    
    function AccepteToken(
        IERC1363 token
    ) external override returns (bool) {
        try require(_msgSender() == Selector) {
            address tokenAddress = address(token);
            _acceptedTokens[tokenAddress] = token;
            tokenAddresses.push(tokenAddress);
            return true;
        } catch {
            return false;
        }
    }

    function setAggregator(
        AggregatorV3Interface aggregator, 
        bytes32 symbol
    ) external returns (bool){
        // TODO
        try require(_msgSender() == Selector) {
            priceTeller.addTeller(aggregator, symbol);
            return true;
        } catch {
            return false;
        }
    }

    function _transferReceived(
        address operator,
        address sender,
        uint256 amount,
        bytes memory data,
        address token
    ) internal override {
        if (IERC1363(token).)
        _deposit(operator, sender, amount, data, token);
        _redeemTokens(operator, sender, amount, data, token);
    }

    function _deposit(
        address operator,
        address sender,
        uint256 amount,
        bytes memory data,
        address token
    ) internal override nonReentrant{
        Account memory account = Accounts[sender];
        account.deposits.amount = amount;
        account.deposits.symbols = _strEncoder(IERC1363(address).symbol);
        // calurate rate and 
        // account.rate = ;
    }


    function _redeemTokens(
        address operator,
        address sender,
        uint256 amount,
        bytes memory data, // 0 - 150
        address token
    ) internal {
        // Account memory account = _checkHealth(sender);
        Account memory account = Accounts[sender];
        require( account.status == Status.Activate);
        require( account.deposit > 0);
        _checkHealth(account);
        require( account.rate );
        uint memory rate = uint256(data);
        if (rate > 0) { 
            // uint memory tokenAmount = rate.amountInRate(factor, );
            _;
        } else if (rate < 0) {
            // TODO
            _;
        }
    }

    function Borrow(uint amount) external exitAcc {
        address borrower = _msgSender();
        _borrow(borrower, amount);
    }

    // borrow TKN only
    function _brorow(address borrower, uint amount) internal {
        _updateWETHPrice();
        Account memory account_ = Accounts[borrower];
        account_ = _updateAccount(account_);
        if (account_.status == Status.Active) {
            uint tknAmount = account_.rate.amountInRate(factor, amount);
        }
    }

    function _checkHealth(
        Account memory account
    ) internal view {
        uint collPrice = (account.deposit).mul(WETHp).div(DECIMAL_PRECISION);
        uint debtPrice = (account.debt).mul(TKNp).div(DECIMAL_PRECISION);
        account.rate = collPrice.div(debtPrice); // coll in usd / debt in usd
    } 
    function _calcRate(uint coll, uint collP, uint debt, uint debtP) internal returns (uint rate) {
        rate = coll.CalRate(collP, debt, debyP);
    }

    // WETH / TKN
    function _updateAccount(
        Account memory account_
    ) internal returns (Account memory) {
        _updateWETHPrice();
        account_.rate = _calcRate(account_.deposit, _WETHp, account_.debt, _TKNp);
        if ( account_.status == Status.Active && minimalRate >= account_.rate ) {
            account_.status = Status.Default;
        } else if (account_.status == Status.Default && minimalRate < account_.rate) {
            account_.status = Status.Active;
        }
        return account_;
    }

    
    function _updateWETHPrice(uint ETHp_, uint TKNp_) internal _updateModi {
        ETHp_ = priceTeller.tellPriceETH();
        // update rate.
    }

    function _calcFactor(bytes32 symbol) internal {
        // TODO
    }

    function _strEncoder(string memory str) internal returns (bytes32) {
        return keccak256(abi.encodePacked(str));
    }

    modifier existAcc() {
        require(Accounts[_msgSender()] != Status.Inactive);
        _;
    }

    modifier checkActive(address account) {
        require(Accounts[account].status == Status.active);
        _;
    }

}