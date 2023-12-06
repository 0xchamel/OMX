import { HardhatUserConfig } from "hardhat/config"
import "@nomicfoundation/hardhat-toolbox"
import * as dotenv from "dotenv"

dotenv.config()

// Go to https://infura.io, sign up, create a new API key
// in its dashboard, and replace "KEY" with it
//const INFURA_API_KEY: string | undefined = process.env.INFURA_API_KEY;

// Replace this private key with your Sepolia account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Beware: NEVER put real Ether into testing accounts
const { ETHERSCAN_API_KEY } = process.env

const config: HardhatUserConfig = {
    solidity: "0.8.17",
    networks: {},
    etherscan: {
        apiKey: ETHERSCAN_API_KEY,
    },
}

export default config
