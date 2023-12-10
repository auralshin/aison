// scripts/deploy.js

import { ethers } from "hardhat";
async function main() {
  const [deployer] = await ethers.getSigners();

    console.log(
      "Deploying contracts with the account:",
      deployer.address
    );

    const DynamicInvoice = await ethers.deployContract("TradeFinance",["0x6C2A780F93Ec560775133f3Ed2ae669744Fe0f49"], deployer);

    await DynamicInvoice.waitForDeployment();

    console.log("DynamicInvoice contract deployed to:", DynamicInvoice);
}
//0xf0c75309c752d85759975c26e74bdd9c6bf7c962 base
// 0x857f7ab1f3ff0c6552ae207095ac2bd1eedc01c0 arbritrum

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });