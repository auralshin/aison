// 0x16925a3dBBd777880708cA868Fe36481d0457Ce4

const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();

    // Replace with your deployed contract address
    // const contractAddress = "0x16925a3dBBd777880708cA868Fe36481d0457Ce4";
    const contractAddress = "0x4e499be57daab760275a8931ddf5473c867d8ab0";
    const DynamicInvoice = await ethers.getContractFactory("DynamicInvoice");
    const dynamicInvoice = await DynamicInvoice.attach(contractAddress);

    const mintParams = {
        _tokenId: 2, // Example tokenId
        _user: deployer.address, // Deployer's address
        details: {
            _merkleRoot: "0x0000000000000000000000000000000000000000000000000000000000000000",
            _invoiceAmount: "4000",
            _invoiceDate: "2023-01-01",
            _invoiceStatus: "Partial",
            _invoiceCurrency: "USDT"
        }
    };

    const tx = await dynamicInvoice.createInvoice(mintParams);
    await tx.wait();

    console.log(`Invoice with token ID ${mintParams._tokenId} minted successfully`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
