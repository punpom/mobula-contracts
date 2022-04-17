const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
require("@nomiclabs/hardhat-etherscan");

async function main() {
  const PrivateSale = await ethers.getContractFactory("MobulaPrivateSale");
  const deployedPrivateSale = await PrivateSale.deploy("0x936c326d9867ed80baef9ebe087acd73f0927974b8df0177f87df084141863a3", "0x326c977e6efc84e512bb9c30f76e30c160ed06fb", "0x326c977e6efc84e512bb9c30f76e30c160ed06fb");
  await deployedPrivateSale.deployed();
  console.log("Verify Contract Address:", deployedPrivateSale.address);
  console.log("Sleeping.....");
  await sleep(50000);
  await hre.run("verify:verify", {
    address: deployedPrivateSale.address,
    constructorArguments: ["0x936c326d9867ed80baef9ebe087acd73f0927974b8df0177f87df084141863a3", "0x326c977e6efc84e512bb9c30f76e30c160ed06fb", "0x326c977e6efc84e512bb9c30f76e30c160ed06fb"],
  });
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });