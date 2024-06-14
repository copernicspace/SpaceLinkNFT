// Grant wants to use Filecoin as the IPFS provider so we need to change this

require("dotenv").config()
const pinataSDK = require("@pinata/sdk")
const fs = require("fs")
const path = require("path")

const pinataApiKey = process.env.PINATA_API_KEY
const pinataSecretKey = process.env.PINATA_SECRET_KEY

const pinata = pinataSDK(pinataApiKey, pinataSecretKey)

async function uploadMetadata() {
  const readableStreamForFile = fs.createReadStream(path.join(__dirname, "metadata", "metadata.json"))
  const options = {
    pinataMetadata: {
      name: "RocketDataNFTMetadata",
    },
    pinataOptions: {
      cidVersion: 0,
    },
  }

  try {
    const result = await pinata.pinFileToIPFS(readableStreamForFile, options)
    console.log(result)
    console.log(`IPFS URL: ipfs://${result.IpfsHash}`)
  } catch (error) {
    console.error(error)
  }
}

uploadMetadata()
