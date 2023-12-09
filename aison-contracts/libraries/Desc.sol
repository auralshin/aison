// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.20;

import "./SVG.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

library InvoiceDesc {
    struct SVGParams {
        string userAddress;
        uint256 tokenId;
        string invoiceAmount;
        string invoiceCurrency;
        string invoiceStatus;
        bytes32 merkleRoot;
        string invoiceDate;
    }

    function makeSVGParams(
        SVGParams memory params,
        bool isSettled
    ) internal pure returns (string memory svg) {
        return
            NFTSVG.generateSVG(
                NFTSVG.SVGParams({
                    merkleProof: truncateHexadecimal(Strings.toHexString(
                        uint256(params.merkleRoot),
                        32
                    )),
                    userAddress: params.userAddress,
                    tokenId: params.tokenId,
                    invoiceAmount: isSettled
                        ? params.invoiceAmount
                        : truncateHexadecimal(params.invoiceAmount),
                    invoiceCurrency: isSettled
                        ? params.invoiceCurrency
                        : truncateHexadecimal(params.invoiceCurrency),
                    invoiceStatus: isSettled
                        ? params.invoiceStatus
                        : truncateHexadecimal(params.invoiceStatus),
                    merkleRoot: params.merkleRoot,
                    invoiceDate: truncateHexadecimal(params.invoiceDate)
                })
            );
    }

    function getTokenURI(
        uint256 tokenId,
        bytes32 _merkleRoot,
        string memory image
    ) internal pure returns (string memory) {
        string memory tokenString = Strings.toString(tokenId);

        string memory merkleRootStr = Strings.toHexString(
            uint256(_merkleRoot),
            32
        );
        string memory description = string(
            abi.encodePacked(
                "Invoice is property of the seller, this is the Merkle Proof: ",
                merkleRootStr,
                ". To know more about Auralshin, please visit https://github.com/auralshin/aison"
            )
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":" Token ID #',
                                tokenString,
                                '", "description":"',
                                description,
                                '", "image": "data:image/svg+xml;base64,',
                                image,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function truncateHexadecimal(
        string memory hexString
    ) public pure returns (string memory) {
        bytes memory bytesString = bytes(hexString);

        if (
            bytesString.length >= 2 &&
            bytesString[0] == 0x30 &&
            (bytesString[1] == 0x78 || bytesString[1] == 0x58)
        ) {
            bytes memory firstPart = new bytes(2);
            firstPart[0] = bytesString[0];
            firstPart[1] = bytesString[1];

            bytes memory lastPart = new bytes(3);
            lastPart[0] = bytesString[bytesString.length - 3];
            lastPart[1] = bytesString[bytesString.length - 2];
            lastPart[2] = bytesString[bytesString.length - 1];

            string memory truncatedHex = string(
                abi.encodePacked(firstPart, "...", lastPart)
            );
            return truncatedHex;
        }
        return hexString;
    }

    function verifyTransaction(
        uint256 tokenId,
        bytes32 _merkleRoot,
        string calldata _transactionID,
        bytes32[] calldata _merkleProof
    ) internal pure returns (bool _doesExist) {
        require(tokenId > 0, "Token ID must be greater than zero.");

        bytes32 leaf = keccak256(abi.encodePacked(_transactionID));
        return _doesExist = MerkleProof.verify(_merkleProof, _merkleRoot, leaf);
    }
}