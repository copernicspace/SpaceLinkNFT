const { types } = require("hardhat/config")
const { networks } = require("../../networks")

task("deploy-rocket-consumer", "Deploys the RocketConsumer contract")
  .addParam("subid", "Billing subscription ID used to pay for the request")
  .addOptionalParam(
    "callbackgaslimit",
    "Maximum amount of gas that can be used to call fulfillRequest in the consumer contract",
    100_000,
    types.int
  )
  .addOptionalParam("verify", "Set to true to verify contract", false, types.boolean)
  .addOptionalParam(
    "configpath",
    "Path to Functions request config file",
    `${__dirname}/../../Functions-request-config.js`,
    types.string
  )
  .setAction(async (taskArgs) => {
    console.log(`Deploying FunctionsConsumer contract to ${network.name}`)

    const subscriptionId = parseInt(taskArgs.subid)
    const callbackGasLimit = parseInt(taskArgs.callbackgaslimit)

    const functionsRouter = networks[network.name]["functionsRouter"]
    const donIdBytes32 = hre.ethers.utils.formatBytes32String(networks[network.name]["donId"])

    console.log("\n__Compiling Contracts__")
    await run("compile")

    const overrides = {}
    // If specified, use the gas price from the network config instead of Ethers estimated price
    if (networks[network.name].gasPrice) {
      overrides.gasPrice = networks[network.name].gasPrice
    }
    // If specified, use the nonce from the network config instead of automatically calculating it
    if (networks[network.name].nonce) {
      overrides.nonce = networks[network.name].nonce
    }

    // Constructor parameters for RocketConsumer
    const name = "RocketNFT"; 
    const symbol = "RKT"; 
    const deployArgs = [functionsRouter, donIdBytes32, subscriptionId, callbackGasLimit, name, symbol];

    const consumerContractFactory = await ethers.getContractFactory("RocketConsumer")
    const consumerContract = await consumerContractFactory.deploy(...deployArgs, overrides)

    console.log(
      `\nWaiting ${networks[network.name].confirmations} blocks for transaction ${
        consumerContract.deployTransaction.hash
      } to be confirmed...`
    )
    await consumerContract.deployTransaction.wait(networks[network.name].confirmations)

    console.log("\nDeployed RocketConsumer contract to:", consumerContract.address)

    if (network.name === "localFunctionsTestnet") {
      return
    }

    const verifyContract = taskArgs.verify
    if (
      network.name !== "localFunctionsTestnet" &&
      verifyContract &&
      !!networks[network.name].verifyApiKey &&
      networks[network.name].verifyApiKey !== "UNSET"
    ) {
      try {
        console.log("\nVerifying contract...")
        await run("verify:verify", {
          address: consumerContract.address,
          constructorArguments: deployArgs,
        })
        console.log("Contract verified")
      } catch (error) {
        if (!error.message.includes("Already Verified")) {
          console.log(
            "Error verifying contract.  Ensure you are waiting for enough confirmation blocks, delete the build folder and try again."
          )
          console.log(error)
        } else {
          console.log("Contract already verified")
        }
      }
    } else if (verifyContract && network.name !== "localFunctionsTestnet") {
        console.log("\nScanner API key is missing. Skipping contract verification...")
      }
  
      console.log(`\nRocketConsumer contract deployed to ${consumerContract.address} on ${network.name}`)
    })