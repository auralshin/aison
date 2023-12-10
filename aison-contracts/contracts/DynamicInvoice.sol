// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "../libraries/Desc.sol";

contract DynamicInvoice is
    ERC721,
    Ownable,
    ERC721Enumerable,
    ERC721Pausable,
    AutomationCompatibleInterface
{
    using Strings for uint256;

    struct InvoiceDetails {
        bytes32 _merkleRoot;
        string _invoiceAmount;
        string _invoiceDate;
        string _invoiceStatus;
        string _invoiceCurrency;
    }

    struct MintParams {
        uint256 _tokenId;
        address _user;
        InvoiceDetails details;
    }

    uint256 public immutable interval;
    uint256 public lastTimeStamp;

    mapping(address => bool) private _eligibleHolders;

    mapping(uint256 => InvoiceDetails) private _tokenURIs;

    mapping(address => uint256[]) public _addressTokenId;

    mapping(uint256 => bool) public _isInvoiceSettled;

    error InvalidCaller(address caller);
    error ZeroAddress();

    event InvoiceMinted(uint256 tokenId, address user);
    event InvoiceSettled(uint256 tokenId, string status);
    event InvoiceUpdated(uint256 tokenId, string status);
    event InvoiceBurned(uint256 tokenId);

    constructor(
        string memory name_,
        string memory symbol_,
        address initialOwner,
        uint256 updateInterval
    ) Ownable(initialOwner) ERC721(name_, symbol_) {
        interval = updateInterval;
        lastTimeStamp = block.timestamp;
    }

    modifier isNotMinted(uint256 tokenId) {
        require(_ownerOf(tokenId) == address(0), "Token already minted.");
        _;
    }

    modifier isMinted(uint256 tokenId) {
        require(_ownerOf(tokenId) != address(0), "Token not minted.");
        _;
    }

    modifier isNotSettled(uint256 tokenId) {
        require(!_isInvoiceSettled[tokenId], "Token is already settled.");
        _;
    }

    modifier isZeroAddress(address user) {
        if (user == address(0)) {
            revert ZeroAddress();
        }
        _;
    }

    function _setInvoiceDetails(
        uint256 tokenId,
        InvoiceDetails memory invoiceDetails
    ) internal virtual {
        _tokenURIs[tokenId] = invoiceDetails;
    }

    function getTokenDetails(
        uint256 tokenId
    ) public view returns (InvoiceDetails memory) {
        return _tokenURIs[tokenId];
    }

    function getTokensByOwner(
        address _owner
    ) public view returns (uint256[] memory) {
        return _addressTokenId[_owner];
    }

    function createInvoice(
        MintParams memory params
    )
        public
        isNotMinted(params._tokenId)
        isZeroAddress(params._user)
        whenNotPaused
    {
        require(params._tokenId > 0, "Token ID must be greater than zero.");
        require(
            bytes(params.details._invoiceAmount).length > 0,
            "Invoice amount cannot be empty."
        );
        uint256 newTokenId = params._tokenId;
        _mint(params._user, newTokenId);
        _addressTokenId[params._user].push(newTokenId);
        _isInvoiceSettled[newTokenId] = false;
        _setInvoiceDetails(newTokenId, params.details);
        emit InvoiceMinted(newTokenId, params._user);
    }

    function updateInvoiceStatus(
        uint256 _tokenId,
        string memory _invoiceStatus,
        bytes32 _merkleRoot,
        string memory _invoiceAmount,
        string memory _invoiceCurrency,
        bool _isSettled
    ) public whenNotPaused isMinted(_tokenId) isNotSettled(_tokenId) {
        InvoiceDetails storage invoice = _tokenURIs[_tokenId];
        invoice._invoiceStatus = _invoiceStatus;
        invoice._merkleRoot = _merkleRoot;
        invoice._invoiceAmount = _invoiceAmount;
        invoice._invoiceCurrency = _invoiceCurrency;
        if (_isSettled) {
            _isInvoiceSettled[_tokenId] = true;
            emit InvoiceSettled(_tokenId, _invoiceStatus);
        } else {
            emit InvoiceUpdated(_tokenId, _invoiceStatus);
        }
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }

    // Implement performUpkeep
    function performUpkeep(bytes calldata /* performData */) external override {
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            // Perform the upkeep tasks
            // Example: Iterate over invoices and update their status based on off-chain conditions
        }
    }

    function burnInvoice(uint256 tokenId) external isMinted(tokenId) {
        _burn(tokenId);
        emit InvoiceBurned(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            _ownerOf(tokenId) != address(0),
            "URI query for nonexistent token"
        );
        string memory image = Base64.encode(bytes(createSVGParams(tokenId)));
        return
            InvoiceDesc.getTokenURI(
                tokenId,
                _tokenURIs[tokenId]._merkleRoot,
                image
            );
    }

    function createSVGParams(
        uint256 tokenId
    ) internal view returns (string memory svg) {
        bool isSettled = _isInvoiceSettled[tokenId];
        return
            InvoiceDesc.makeSVGParams(
                InvoiceDesc.SVGParams({
                    userAddress: Strings.toHexString(
                        uint256(uint160(ownerOf(tokenId))),
                        20
                    ),
                    tokenId: tokenId,
                    invoiceAmount: _tokenURIs[tokenId]._invoiceAmount,
                    invoiceCurrency: _tokenURIs[tokenId]._invoiceCurrency,
                    invoiceStatus: _tokenURIs[tokenId]._invoiceStatus,
                    merkleRoot: _tokenURIs[tokenId]._merkleRoot,
                    invoiceDate: _tokenURIs[tokenId]._invoiceDate
                }),
                isSettled
            );
    }

    function verifyTransactionByNFT(
        uint256 tokenId,
        string calldata transactionID,
        bytes32[] calldata merkleProof
    ) public view isMinted(tokenId) returns (bool) {
        return
            InvoiceDesc.verifyTransaction(
                tokenId,
                _tokenURIs[tokenId]._merkleRoot,
                transactionID,
                merkleProof
            );
    }

    function pauseContract() public {
        _pause();
    }

    function unpauseContract() public {
        _unpause();
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }
}
