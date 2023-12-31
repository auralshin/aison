// scripts/deploy.js

import { ethers } from "hardhat";
async function main() {
  const [deployer] = await ethers.getSigners();

    console.log(
      "Deploying contracts with the account:",
      deployer.address
    );

    const DynamicInvoice = await ethers.deployContract("DynamicInvoice",["Dynamic Invoice", "DI", "0x6C2A780F93Ec560775133f3Ed2ae669744Fe0f49", 500], deployer);

    await DynamicInvoice.waitForDeployment();

    console.log("DynamicInvoice contract deployed to:", DynamicInvoice);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });