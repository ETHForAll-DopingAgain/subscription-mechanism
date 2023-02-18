import { ethers } from "hardhat";

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
  const unlockTime = currentTimestampInSeconds + ONE_YEAR_IN_SECS;

  const File = await ethers.getContractFactory("SubscriptionFunction");
  const file = await File.deploy("0x4E583d9390082B65Bef884b629DFA426114CED6d");

  await file.deployed();

  console.log(`File with 1 ETH and unlock timestamp ${unlockTime} deployed to ${file.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});