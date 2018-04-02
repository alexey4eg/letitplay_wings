import expectThrow from "zeppelin-solidity/test/helpers/expectThrow.js";
const MINIMAL_GOAL = 1000
const HARD_CAP = 2000
const TOKEN_PRICE = 2

let LetItPlayToken = artifacts.require("./LetItPlayToken.sol");
let Crowdsale = artifacts.require("./Crowdsale.sol");

contract("Crowdsale", async function(accounts) {
  let crowdsale, token;
  let user = accounts[2];
  let manager = accounts[0];
  let fundingAddress = accounts[3];

  beforeEach('setup contract for each test', async function () {
      token = await LetItPlayToken.new();
      crowdsale = await Crowdsale.new(MINIMAL_GOAL, HARD_CAP, TOKEN_PRICE, token.address);
      //token.setCrowdsale(crowdsale.address);
      user = accounts[2];
    });

  it("init bonus", async function() {
    let bonusPeriod = await crowdsale.CurrentBonusPeriod();
    console.log(bonusPeriod);
  });

});
