const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("Uniswap", (m) => {

  const uniswap = m.contract("Uniswap");

  return { uniswap };
});
