pragma solidity ^0.4.19;
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract WithBonusPeriods is Ownable {
  event DEBUG(uint256 code);
  uint256 constant INVALID_FROM_TIMESTAMP = 1000000000000;
  uint256 constant INFINITY_TO_TIMESTAMP= 1000000000000;
  struct BonusPeriod {
    uint256 fromTimestamp;
    uint256 toTimestamp;
    uint256 bonusNumerator;
    uint256 bonusDenominator;
  }

  BonusPeriod[] public bonusPeriods;
  BonusPeriod currentBonusPeriod;

  function WithBonusPeriods() public {
      initBonuses();
  }

  function BonusPeriodsCount() public view returns (uint8) {
    return uint8(bonusPeriods.length);
  }

  function BonusPeriodFor(uint256 timestamp) public view returns (bool ongoing, uint256 from, uint256 to, uint256 num, uint256 den) {
    for(uint i = 0; i < bonusPeriods.length; i++)
      if (bonusPeriods[i].fromTimestamp <= timestamp && bonusPeriods[i].toTimestamp >= timestamp)
        return (true, bonusPeriods[i].fromTimestamp, bonusPeriods[i].toTimestamp, bonusPeriods[i].bonusNumerator,
          bonusPeriods[i].bonusDenominator);
    return (false, 0, 0, 0, 0);
  }

  /*function removeBonusPeriod(uint index) public onlyOwner {
    require(index >=0 && bonusPeriods.length > index);
    for(uint i = index + 1; i < bonusPeriods.length; i++)
      bonusPeriods[i - 1] = bonusPeriods[i];
    bonusPeriods.length--;
  }

  function addBonusPeriod(uint256 fromTimestamp, uint256 toTimestamp, uint bonusNumerator, uint bonusDenominator) public onlyOwner {
      require(fromTimestamp <= toTimestamp);
      require(bonusNumerator >= 0 && bonusDenominator > 0);
      require(bonusPeriods.length < 255);

      bonusPeriods.push(BonusPeriod(fromTimestamp, toTimestamp, bonusNumerator, bonusDenominator));
  }*/

  function initBonusPeriod(uint256 from, uint256 to, uint256 num, uint256 den) internal  {
    bonusPeriods.push(BonusPeriod(from, to, num, den));
  }

  //will be replaced with real bonus periods
  function initBonuses() internal {
      initBonusPeriod(block.timestamp, block.timestamp + 3600 * 24, 3, 10);
      initBonusPeriod(block.timestamp + 3600 * 24 + 1, block.timestamp + 3600 * 48, 1, 10);
  }

  function updateCurrentBonusPeriod() internal  {
    if (currentBonusPeriod.fromTimestamp <= block.timestamp
      && currentBonusPeriod.toTimestamp >= block.timestamp)
      return;

    currentBonusPeriod.fromTimestamp = INVALID_FROM_TIMESTAMP;

    for(uint i = 0; i < bonusPeriods.length; i++)
      if (bonusPeriods[i].fromTimestamp <= block.timestamp && bonusPeriods[i].toTimestamp >= block.timestamp) {
        currentBonusPeriod = bonusPeriods[i];
        return;
      }
  }
}
