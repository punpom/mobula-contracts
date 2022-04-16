const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
require("@nomiclabs/hardhat-etherscan");

async function main() {
  const PrivateSale = await ethers.getContractFactory("MobulaPrivateSale");
  const deployedPrivateSale = await PrivateSale.deploy("0xd141ebe92a05d2e17577082c7cc5cd2ed9d8398e03423b035588b5b4a0bfdd94", "0x6c2cf779f19610816cd53f9185666c72dc01863b", "0x326c977e6efc84e512bb9c30f76e30c160ed06fb");
  await deployedPrivateSale.deployed();
  console.log("Verify Contract Address:", deployedPrivateSale.address);
  console.log("Sleeping.....");
  await sleep(50000);
  await hre.run("verify:verify", {
    address: deployedPrivateSale.address,
    constructorArguments: ["0xd141ebe92a05d2e17577082c7cc5cd2ed9d8398e03423b035588b5b4a0bfdd94", "0x6c2cf779f19610816cd53f9185666c72dc01863b", "0x326c977e6efc84e512bb9c30f76e30c160ed06fb"],
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