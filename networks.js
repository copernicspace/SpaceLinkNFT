// All supported networks and related contract addresses are defined here.
//
// LINK token addresses: https://docs.chain.link/resources/link-token-contracts/
// Price feeds addresses: https://docs.chain.link/data-feeds/price-feeds/addresses
// Chain IDs: https://chainlist.org/?testnets=true

// Loads environment variables from .env.enc file (if it exists)
require("@chainlink/env-enc").config()

const DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS = 2

const npmCommand = process.env.npm_lifecycle_event
const isTestEnvironment = npmCommand == "test" || npmCommand == "test:unit"

const isSimulation = process.argv.length === 3 && process.argv[2] === "functions-simulate-script" ? true : false

// Set EVM private keys (required)
const PRIVATE_KEY = process.env.PRIVATE_KEY

// TODO @dev - set this to run the accept.js task.
const SECOND_PRIVATE_KEY = process.env.SECOND_PRIVATE_KEY

if (!isTestEnvironment && !isSimulation && !PRIVATE_KEY) {
  throw Error("Set the PRIVATE_KEY environment variable with your EVM wallet private key")
}

const accounts = []
if (PRIVATE_KEY) {
  accounts.push(PRIVATE_KEY)
}
if (SECOND_PRIVATE_KEY) {
  accounts.push(SECOND_PRIVATE_KEY)
}

const networks = {
  polygon: {
    url: process.env.POLYGON_RPC_URL || "UNSET",
    gasPrice: undefined,
    nonce: undefined,
    accounts,
    verifyApiKey: process.env.POLYGONSCAN_API_KEY || "UNSET",
    chainId: 137,
    confirmations: DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS,
    nativeCurrencySymbol: "ETH",
    linkToken: "0xb0897686c545045aFc77CF20eC7A532E3120E0F1",
    linkPriceFeed: "0x5787BefDc0ECd210Dfa948264631CD53E68F7802", // LINK/MATIC
    functionsRouter: "0xdc2AAF042Aeff2E68B3e8E33F19e4B9fA7C73F10",
    donId: "fun-polygon-mainnet-1",
    gatewayUrls: ["https://01.functions-gateway.chain.link/", "https://02.functions-gateway.chain.link/"],
  },
  polygonAmoy: {
    url: process.env.AMOY_RPC_URL || "UNSET", // h
    gasPrice: undefined,
    nonce: undefined,
    accounts,
    verifyApiKey: process.env.POLYGONSCAN_API_KEY || "UNSET",
    chainId: 80002,
    confirmations: DEFAULT_VERIFICATION_BLOCK_CONFIRMATIONS,
    nativeCurrencySymbol: "MATIC",
    linkToken: "0x0Fd9e8d3aF1aaee056EB9e802c3A762a667b1904",
    linkPriceFeed: "0x408D97c89c141e60872C0835e18Dd1E670CD8781", // LINK/MATIC

    functionsRouter: "0xC22a79eBA640940ABB6dF0f7982cc119578E11De",
    donId: "fun-polygon-amoy-1",
    gatewayUrls: [
      "https://01.functions-gateway.testnet.chain.link/",
      "https://02.functions-gateway.testnet.chain.link/",
    ],
  },
  // localFunctionsTestnet is updated dynamically by scripts/startLocalFunctionsTestnet.js so it should not be modified here
  localFunctionsTestnet: {
    url: "http://localhost:8545/",
    accounts,
    confirmations: 1,
    nativeCurrencySymbol: "ETH",
    linkToken: "0x94d3C68A91C972388d7863D25EDD2Be7e2F21F21",
    functionsRouter: "0xCbfD616baE0F13EFE0528c446184C9C0EAa8040e",
    donId: "local-functions-testnet",
  },
}

module.exports = {
  networks,
}
