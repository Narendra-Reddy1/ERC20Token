require("@nomicfoundation/hardhat-toolbox");
require('dotenv').configDotenv();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const SEPOLIA_RPC_URL = process.env.TEST_NET_RPC_URL;
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  defaultNetwork: "sepolia",
  networks: {
    "sepolia": {
      accounts: [PRIVATE_KEY],
      chainId: 11155111,
      url: SEPOLIA_RPC_URL
    },
    "localhost": {

    }
  }
};
