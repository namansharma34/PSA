const { expect } = require("chai");
const hre = require("hardhat");

describe("PSA", () => {
  let psa;
  let signers;
  it("Deploying", async () => {
    //Deploying the Contract
    const _su = await hre.ethers.getContractFactory("StringUtils");
    const su = await _su.deploy();
    await su.deployed();
    const _psa = await hre.ethers.getContractFactory("PhotoSharing", {
      libraries: {
        StringUtils: String(su.address),
      },
    });
    psa = await _psa.deploy();
    await psa.deployed();
    signers = await hre.ethers.getSigners();
  });
  it("should revert the uploadPhoto method", async () => {
    await expect(
      psa.uploadPhoto(
        "394a01c2e7c462a8c4f0004bc84304e347280fcd",
        "Iron Man Photos"
      )
    ).to.be.revertedWith("Register Your Username");
  });
  it("should revert the getAllPhotos method", async () => {
    await expect(psa.getAllPhotos()).to.be.revertedWith(
      "Register Your Username"
    );
  });
  it("username should be register", async () => {
    await psa.connect(signers[1]).setUsername("naman");
    expect(await psa.connect(signers[1]).checkUsername("naman")).to.be.equal(
      true
    );
    expect(await psa.connect(signers[1]).checkAddress()).to.be.equal(true);
  });
  it("should revert twice username registration and same username registration", async () => {
    await expect(
      psa.connect(signers[1]).setUsername("karke")
    ).to.be.revertedWith("Cannot Register Twice");
    await expect(
      psa.connect(signers[2]).setUsername("naman")
    ).to.be.revertedWith("Choose Another Name");
  });
  it("can upload the photo's ipfs hash and description", async () => {
    await psa
      .connect(signers[1])
      .uploadPhoto(
        "394a01c2e7c462a8c4f0004bc84304e347280fcd",
        "Iron Man Photo"
      );
    const daf = await psa.connect(signers[1]).getAllPhotos();
    expect(
      `${daf[0].ipfsHash} ${daf[0].description} ${Number(daf[0].id)} ${Number(
        daf[0].likes
      )} ${daf[0].author} ${daf[0].comments}`
    ).to.equal(
      `394a01c2e7c462a8c4f0004bc84304e347280fcd Iron Man Photo 1 0 naman `
    );
  });
  it("checking likePhoto method", async () => {
    await expect(psa.connect(signers[2]).likePhoto(1)).to.be.revertedWith(
      "Register Your Username"
    );
    await psa.connect(signers[2]).setUsername("channel");
    await psa.connect(signers[1]).likePhoto(1);
    await psa.connect(signers[2]).likePhoto(1);
    expect(
      Number((await psa.connect(signers[2]).getAllPhotos())[0].likes.length)
    ).to.equal(2);
  });
  it("addComment method", async () => {
    await expect(
      psa.connect(signers[3]).addComment(1, "Good")
    ).to.be.revertedWith("Register Your Username");
    await expect(
      psa.connect(signers[1]).addComment(2, "Good")
    ).to.be.rejectedWith("Photo does not exist");
    await psa.connect(signers[3]).setUsername("karke");
    await psa.connect(signers[1]).addComment(1, "Good");
    await psa.connect(signers[3]).addComment(1, "Nice");
    const daf = await psa.connect(signers[1]).getAllPhotos();
    expect(
      `${daf[0].comments[0].text} ${daf[0].comments[1].text} ${daf[0].comments[0].username} ${daf[0].comments[1].username}`
    ).to.equal("Good Nice naman karke");
  });
});
