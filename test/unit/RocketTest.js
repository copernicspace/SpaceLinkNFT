const { expect } = require('chai');


describe('RocketNFT', () => {
  const chainlinkFunctionsClient = getChainlinkFunctionsClient();

  beforeEach(async () => {
    await deployments.fixture('rocket-nft');
  });

  it('creates a new NFT and sets its initial token URI', async () => {
    const nftId = 1;
    const tokenURI = 'ipfs://some/image';

    await rocketNFT.createNFT(tokenURI);

    const tokenURIs = await rocketNFT.tokenURIs();
    expect(tokenURIs[nftId]).to.equal(tokenURI);
  });

  it('requests data for an NFT and fulfills the request', async () => {
    const nftId = 1;
    const requestId = await rocketNFT.requestData(nftId);

    // Simulate the Chainlink Function responding with some data
    const response = 'On Earth';
    chainlinkFunctionsClient.fulfillRequest(requestId, response);

    const rocketData = await rocketNFT.getRocketData(nftId);
    expect(rocketData.state).to.equal('On Earth');
  });

  it('handles errors when fulfilling a request', async () => {
    const nftId = 1;
    const requestId = await rocketNFT.requestData(nftId);

    // Simulate the Chainlink Function responding with an error
    chainlinkFunctionsClient.fulfillRequest(requestId, 'Error: some message');

    expect(() => rocketNFT.getRocketData(nftId)).to.throw('Error: some message');
  });

  it('emits a RequestFulfilled event when fulfilling a request', async () => {
    const nftId = 1;
    const requestId = await rocketNFT.requestData(nftId);

    // Simulate the Chainlink Function responding with some data
    const response = 'On Earth';
    chainlinkFunctionsClient.fulfillRequest(requestId, response);

    const event = await rocketNFT.events.RequestFulfilled();
    expect(event.requestId).to.equal(requestId);
  });
});
