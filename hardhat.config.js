require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config;
/** @type import('hardhat/config').HardhatUserConfig */
const {RPC_URL, PRIVATE_KEY} = process.env;
module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  networks: {
    sepolia: {
      url: "https://sepolia.infura.io/v3/8629fc97678e4d22ab2047f0e4ec2840",
      accounts: ["0xff362c9fb56047fc6961163bc951cfbbb72b1f060f04e0e435b438999ff1de28"]
    }
  }
};