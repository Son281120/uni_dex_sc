const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Uniswap Contract", function () {
  let Uniswap, uniswap, Cardano, cardano, Tether, tether;
  let owner, addr1, addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy Cardano
    const CardanoFactory = await ethers.getContractFactory("Cardano");
    cardano = await CardanoFactory.deploy();
    await cardano.deployed();

    // Deploy Tether
    const TetherFactory = await ethers.getContractFactory("Tether");
    tether = await TetherFactory.deploy();
    await tether.deployed();

    // Deploy Uniswap
    const UniswapFactory = await ethers.getContractFactory("Uniswap");
    uniswap = await UniswapFactory.deploy();
    await uniswap.deployed();

    // Distribute tokens to addr1
    await cardano.mint(addr1.address, ethers.utils.parseUnits("1000", 18));
    await tether.mint(addr1.address, ethers.utils.parseUnits("1000", 18));
  });

  describe("getBalanceOfToken", function () {
    it("Should return the correct balance of token", async function () {
      expect(await uniswap.connect(addr1).getBalanceOfToken(cardano.address)).to.equal(ethers.utils.parseUnits("1000", 18));
      expect(await uniswap.connect(addr1).getBalanceOfToken(tether.address)).to.equal(ethers.utils.parseUnits("1000", 18));
    });
  });

  describe("getAmountInMax", function () {
    it("Should return the correct amount in max after fee", async function () {
      expect(await uniswap.connect(addr1).getAmountInMax(cardano.address)).to.equal(ethers.utils.parseUnits("980", 18));
      expect(await uniswap.connect(addr1).getAmountInMax(tether.address)).to.equal(ethers.utils.parseUnits("980", 18));
    });
  });

  describe("swapToken", function () {
    it("Should swap tokens correctly", async function () {
      // Allow Uniswap contract to spend addr1's Cardano
      await cardano.connect(addr1).approve(uniswap.address, ethers.utils.parseUnits("100", 18));

      // Transfer some Tether to Uniswap contract to simulate liquidity
      await tether.transfer(uniswap.address, ethers.utils.parseUnits("1000", 18));

      // Swap 100 Cardano for Tether
      await uniswap.connect(addr1).swapToken(cardano.address, tether.address, 1, 1, ethers.utils.parseUnits("100", 18));

      expect(await cardano.balanceOf(uniswap.address)).to.equal(ethers.utils.parseUnits("98", 18)); // After fee
      expect(await tether.balanceOf(addr1.address)).to.equal(ethers.utils.parseUnits("1080", 18)); // Received 80 Tether after swap
    });
  });

  describe("transferToAddress", function () {
    it("Should transfer tokens correctly", async function () {
      await cardano.connect(addr1).approve(uniswap.address, ethers.utils.parseUnits("100", 18));
      await uniswap.connect(addr1).transferToAddress(cardano.address, addr2.address, ethers.utils.parseUnits("100", 18));
      expect(await cardano.balanceOf(addr2.address)).to.equal(ethers.utils.parseUnits("100", 18));
    });
  });
});
