// scripts/deploy.js

import { ethers } from "hardhat";
async function main() {
  const [deployer] = await ethers.getSigners();

    console.log(
      "Deploying contracts with the account:",
      deployer.address
    );

    const mockToken = await ethers.deployContract("MockToken",[100000000000000000000000000n], deployer);
    const token = await mockToken.waitForDeployment();
    const tokenAddress = await token.getAddress();
    console.log("DynamicInvoice contract deployed to:", tokenAddress);
    // IERC20Metadata stakingToken_, IERC20 rewardsToken_, address _nftContractAddress
    const FactoringPool = await ethers.deployContract("InvestmentPool",[tokenAddress, tokenAddress, "0x16925a3dBBd777880708cA868Fe36481d0457Ce4"], deployer);
    const pool = await FactoringPool.waitForDeployment();
    const poolAddress = pool.getAddress();
    console.log("pool Address:", poolAddress);
    // IERC20 farmableToken_,
    //     IERC20Plugins investmentPoolAddress_
    const AddPlugin = await ethers.deployContract("MultiFactoringPlugin",[tokenAddress, poolAddress], deployer);
    const plugin = await AddPlugin.waitForDeployment();

    console.log("Plugin:", await AddPlugin.getAddress());
}
// token : 0x14cc086c1A3462Bd311D5A762Bf7aca31Bc96ee2 // base
// pool : 0xbf84b64aa81a2b75aac3460c47da545e12a89003 // base
// plugin: 0xEa2F4177C1fd84244BCea45dC61A4964e6a98614 // base

// token : 0x16925a3dBBd777880708cA868Fe36481d0457Ce4 // arbritrum
// pool : 0x01b2578b9aa7a69afb723d847193da98f4743034 // arbritrum
// plugin: 0xF5E9e34807A83E040e233d6554A036f7E79B6631 // arbritrum

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });