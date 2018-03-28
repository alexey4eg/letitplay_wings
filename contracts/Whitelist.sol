pragma solidity ^0.4.19;
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
contract Whitelist is Ownable {
  mapping(address => bool) whitelist;
  function AddToWhiteList(address _addr) onlyOwner {
      whitelist[_addr] = true;
  }

  modifier whitelistedOnly {
    require(whitelist[msg.sender]);
    _;
  }
}
