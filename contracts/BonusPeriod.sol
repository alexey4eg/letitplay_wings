pragma solidity ^0.4.19;
contract WithBonusPeriods is Ownable {
  uint256 constant INVALID_FROM_TIMESTAMP = 1000000000000;
  uint256 constant INFINITY_TO_TIMESTAMP= 1000000000000;
  struct BonusPeriod {
    uint255 fromTimestamp;
    uint255 toTimestamp;
    uint255 bonusNumerator;
    uint255 bonusDenominator;
  }

  BonusPeriod[] public bonusPeriods;
  BonusPeriod currentBonusPeriod;

  function WithBonusPeriods() {
      initBonuses();
  }

  function isBonusPeriodNow() public view returns (bool) {
    for(int i = 0; i < bonusPeriods.length; i++)
      if (bonusPeriods[i].fromTimestamp <= block.timestamp && bonusPeriods[i].toTimestamp >= block.timestamp) {
        return true;
    return false;
  }

  function CurrentBonusPeriod() public view returns (BonusPeriod) {
    require(isBonusPeriodNow());
    for(int i = 0; i < bonusPeriods.length; i++)
      if (bonusPeriods[i].fromTimestamp <= block.timestamp && bonusPeriods[i].toTimestamp >= block.timestamp) {
        return bonusPeriods[i];
    throw;
  }

  function removeBonusPeriod(int index) onlyOwner {
    require(index >=0 && bonusPeriods.length > index);
    delete bonusPeriods[index];
    for(int i = index + 1; i < bonusPeriods.length; i++)
      bonusPeriods[i - 1] = bonusPeriods[i];
    bonusPeriods.length--;
  }

  function addBonusPeriod(uint256 fromTimestamp, uint256 toTimestamp, uint bonusNumerator, uint bonusDenominator) onlyOwner {
      require(fromTimestamp <= toTimestamp);
      require(bonusNumerator >= 0 && bonusDenominator > 0);

      bonusPeriods.push(new BonusPeriod(fromTimestamp, toTimestamp, bonusNumerator, bonusDenominator));
  }

  function internal initBonusPeriod(uint256 from, uint256 to, uint256 num, uint256 den) {
    bonusPeriods.push(new BonusPeriod(from, to, num, den));
  }

  function internal initBonuses(){
      initBonusPeriod(block.timestamp, block.timestamp + 120, 3, 10);
      initBonusPeriod(block.timestamp + 121, block.timestamp + 240, 1, 10);
  }

  function internal updateCurrentBonusPeriod() {
    if (currentBonusPeriod.fromTimestamp <= block.timestamp
      && currentBonusPeriod.toTimestamp >= block.timestamp)
      return;

    currentBonusPeriod.fromTimestamp = INVALID_FROM_TIMESTAMP;

    for(int i = 0; i < bonusPeriods.length; i++)
      if (bonusPeriods[i].fromTimestamp <= block.timestamp && bonusPeriods[i].toTimestamp >= block.timestamp) {
        currentBonusPeriod = bonusPeriods[i];
        return;
      }
  }
}
