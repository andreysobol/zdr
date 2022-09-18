const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  const Hello = await ethers.getContractFactory("ZeroDataRollup");
  const hello = await Hello.deploy();

  console.log("ZeroDataRollup address:", hello.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });