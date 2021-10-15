const main = async () => {
    const nftContractFactory = await hre.ethers.getContractFactory('MyEpicNFT');
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    console.log("Contract deployed to:", nftContract.address);

    let maxCount = await nftContract.MAX_SUPPLY();
    console.log(`Max Count: ${maxCount}`);

    let nftTxn = await nftContract.makeAnEpicNFT();
    await nftTxn.wait();

    let nftTxn2 = await nftContract.makeAnEpicNFT();
    await nftTxn2.wait();


    let count = await nftContract.getTotalNFTsMinted();
    console.log(`NFT Count: ${count}`);


  };
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();