pragma solidity ^0.4.19;
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
contract Whitelist is Ownable {
  mapping(address => bool) public whitelist;
  address public manager;
  function AddToWhiteList(address _addr) public {
      require(msg.sender == manager || msg.sender == owner);
      whitelist[_addr] = true;
  }

  function AssignManager(address _addr) public onlyOwner {
      manager = _addr;
  }

  modifier whitelistedOnly {
    require(whitelist[msg.sender]);
    _;
  }
}
