import expectThrow from "zeppelin-solidity/test/helpers/expectThrow.js";
const MINIMAL_GOAL = 1000
const HARD_CAP = 2000
const TOKEN_PRICE = 2

let LetItPlayToken = artifacts.require("./LetItPlayToken.sol");
let Crowdsale = artifacts.require("./Crowdsale.sol");

const timeTravel = function (time) {
  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [time], // 86400 is num seconds in day
      id: new Date().getTime()
    }, (err, result) => {
      if(err){ return reject(err) }
      return resolve(result)
    });
  })
}

contract("Crowdsale", async function(accounts) {
  let crowdsale, token;
  let user = accounts[2];
  let manager = accounts[0];
  let fundingAddress = accounts[3];
  let now;

  beforeEach('setup contract for each test', async function () {
      now = Math.floor(Date.now() / 1000);
      token = await LetItPlayToken.new(accounts[4], accounts[5], accounts[6], accounts[7], accounts[8], accounts[9]);
      crowdsale = await Crowdsale.new(MINIMAL_GOAL, HARD_CAP, TOKEN_PRICE, token.address);
      user = accounts[2];
    });

  it("init bonus", async function() {
    let period = await crowdsale.bonusPeriods(0);
    console.log(period);
    console.log(now + 3);
    let bonusPeriod = await crowdsale.BonusPeriodFor(now + 3);
    let bonusPeriodsCount = await crowdsale.BonusPeriodsCount();
    assert.equal(true, bonusPeriod[0]);
    assert.equal(2, bonusPeriodsCount);

    //await timeTravel(240);

    bonusPeriod = await crowdsale.BonusPeriodFor(now + 241);
    assert.equal(false, bonusPeriod[0]);
  });

  /*it("add bonus period", async function() {
    let now = Math.floor(Date.now() / 1000);
    let from = now + 1234, to = now+ 3456, num = 1, den = 10;
    await expectThrow(crowdsale.addBonusPeriod(from, to, num, den, {from: user}));
    await expectThrow(crowdsale.addBonusPeriod(now + 1, now, 1, 10));
    await expectThrow(crowdsale.addBonusPeriod(from, to, 1, 0));
    for(let i = 1; i <= 253;i++){
      await crowdsale.addBonusPeriod(from, to, 1, 10);
    }
    await expectThrow(crowdsale.addBonusPeriod(from, to, 1, 10));
    let bonus = await crowdsale.bonusPeriods(254);
    console.log(bonus);
    assert.equal(from, bonus[0]);
    assert.equal(to, bonus[1]);
    assert.equal(1, bonus[2]);
    assert.equal(10, bonus[3]);
  });*/

  /*it("remove bonus period", async function() {
    let from1 = now + 1234, to1 = now + 3456, num1 = 1, den1 = 10;
    let from2 = now + 4789, to2 = now + 5555, num2 = 3, den2 = 10;
    await crowdsale.addBonusPeriod(from1, to1, num1, den1);
    await crowdsale.addBonusPeriod(from2, to2, num2, den2);
    await expectThrow(crowdsale.removeBonusPeriod(2, {from:user}));
    await crowdsale.removeBonusPeriod(2);
    let count = await crowdsale.BonusPeriodsCount();
    assert.equal(3, count);
    //await timeTravel(1300);
    let bonus = await crowdsale.BonusPeriodFor(now + 1300);
    assert.equal(false, bonus[0]);
    //await timeTravel(5000 - 1300);
    bonus = await crowdsale.BonusPeriodFor(now + 5000);
    //console.log(await crowdsale.bonusPeriods(2));
    assert.equal(true, bonus[0]);
    assert.equal(now + 4789, bonus[1].toNumber());
    assert.equal(now + 5555, bonus[2].toNumber());
    assert.equal(3, bonus[3].toNumber());
    assert.equal(10, bonus[4].toNumber());
  });*/

});
