// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const _su = await hre.ethers.getContractFactory("StringUtils");
  const su = await _su.deploy();
  await su.waitForDeployment();
  const _psa = await hre.ethers.getContractFactory("PhotoSharing", {
    libraries: {
      StringUtils: String(su.address),
    },
  });
  const psa = await _psa.deploy();
  await psa.waitForDeployment();

  console.log(
    `Decentrazlied Photo Sharing Application is deployed on network with transcation id ${psa.getAddress()}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
