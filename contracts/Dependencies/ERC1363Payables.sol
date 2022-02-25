// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import "@openzeppelin/contracts/utils/Context.sol";

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ERC1363/IERC1363.sol";
import "erc-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol";
import "erc-payable-token/contracts/token/ERC1363/IERC1363Spender.sol";

/**
 * @title ERC1363Payable
 * @author Vittorio Minacori (https://github.com/vittominacori)
 * @dev Implementation proposal of a contract that wants to accept ERC1363 payments
 */
abstract contract ERC1363Payables is IERC1363Receiver, IERC1363Spender, ERC165, Context {
    using ERC165Checker for address;

    /**
     * @dev Emitted when `amount` tokens are moved from one account (`sender`) to
     * this by operator (`operator`) using {transferAndCall} or {transferFromAndCall}.
     */
    event TokensReceived(address indexed operator, address indexed sender, uint256 amount, bytes data);

    /**
     * @dev Emitted when the allowance of this for a `sender` is set by
     * a call to {approveAndCall}. `amount` is the new allowance.
     */
    event TokensApproved(address indexed sender, uint256 amount, bytes data);

    // The ERC1363 token accepted
    IERC1363 private _acceptedToken;
    mapping(address => IERC1363) _acceptedTokens;
    mapping(bytes32 => IERC1363) _name2Tokens;
    mapping(bytes32 => IERC1363) _ticker2Tokens;

    /**
     * @param acceptedTokens_ Address of the token being accepted
     */
    constructor(
        IERC1363[] memory acceptedTokens_
    ) {
        for (uint8 i = 0; i < acceptedTokens_.length; i++) {
            _acceptToken(acceptedTokens_[i]);
        }
    }
    function _acceptToken(IERC1363 token_) internal {
        address tokenAddress = address(token_);
        require(tokenAddress != address(0), "ERC1363Payable: acceptedToken is zero address");
        require(token_.supportsInterface(type(IERC1363).interfaceId));
        _acceptedTokens[tokenAddress] = token_;
        _name2Tokens[keccak256(abi.encodePacked(token_.name())] = token_;
        _ticker2Tokens[keccak256(abi.encodePacked(token_.symbol()))] = token_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {
        return
            interfaceId == type(IERC1363Receiver).interfaceId ||
            interfaceId == type(IERC1363Spender).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function AcceptToken(IERC1363 token) external virtual returns (bool);

    /*
     * @dev Note: remember that the token contract address is always the message sender.
     * @param operator The address which called `transferAndCall` or `transferFromAndCall` function
     * @param sender The address which are token transferred from
     * @param amount The amount of tokens transferred
     * @param data Additional data with no specified format
     */
    function onTransferReceived(
        address operator,
        address sender,
        uint256 amount,
        bytes memory data
    ) public override returns (bytes4) {
        // require(_msgSender() == address(_acceptedToken), "ERC1363Payable: acceptedToken is not message sender");
        address token1363 = _msgSender();
        require(address(_acceptedTokens[token1363]) != address(0));
        require(token1363 == address(_acceptedTokens[token1363]), "ERC1363Payable: acceptedToken is not message sender");

        emit TokensReceived(operator, sender, amount, data);

        _transferReceived(operator, sender, amount, data, token1363);

        return IERC1363Receiver(this).onTransferReceived.selector;
    }

    /*
     * @dev Note: remember that the token contract address is always the message sender.
     * @param sender The address which called `approveAndCall` function
     * @param amount The amount of tokens to be spent
     * @param data Additional data with no specified format
     */
    function onApprovalReceived(
        address sender,
        uint256 amount,
        bytes memory data
    ) public override returns (bytes4) {
        // require(_msgSender() == address(_acceptedToken), "ERC1363Payable: acceptedToken is not message sender");
        address token1363 = _msgSender();
        require(address(_acceptedTokens[token1363]) != address(0));
        require(token1363 == address(_acceptedTokens[token1363]), "ERC1363Payable: acceptedToken is not message sender");

        emit TokensApproved(sender, amount, data);

        _approvalReceived(sender, amount, data, token1363);

        return IERC1363Spender(this).onApprovalReceived.selector;
    }

    /**
     * @dev The ERC1363 token accepted
    function acceptedTokens() public view returns (address[] memory tokenAddresses) {
        return tokenAddresses;
    }
    */

    /**
     * @dev Called after validating a `onTransferReceived`. Override this method to
     * make your stuffs within your contract.
     * @param operator The address which called `transferAndCall` or `transferFromAndCall` function
     * @param sender The address which are token transferred from
     * @param amount The amount of tokens transferred
     * @param data Additional data with no specified format
     */
    function _transferReceived(
        address operator,
        address sender,
        uint256 amount,
        bytes memory data,
        address token
    ) internal virtual {
        // optional override
    }

    /**
     * @dev Called after validating a `onApprovalReceived`. Override this method to
     * make your stuffs within your contract.
     * @param sender The address which called `approveAndCall` function
     * @param amount The amount of tokens to be spent
     * @param data Additional data with no specified format
     */
    function _approvalReceived(
        address sender,
        uint256 amount,
        bytes memory data,
        address token
    ) internal virtual {
        // optional override
    }
}
