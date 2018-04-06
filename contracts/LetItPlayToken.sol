pragma solidity ^0.4.19;
import "./Crowdsaled.sol";
import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
contract LetItPlayToken is Crowdsaled, StandardToken {
        uint256 public totalSupply;
        string public name;
        string public symbol;
        uint8 public decimals;

        address public forSale;
        address public ecoSystemFund;
        address public founders;
        address public team;
        address public advisers;
        address public bounty;

        bool releasedForTransfer;

        function LetItPlayToken(
            address _forSale,
            address _ecoSystemFund,
            address _founders,
            address _team,
            address _advisers,
            address _bounty
          ) public {
          name = "LetItPlayToken";
          symbol = "LTP";
          decimals = 18;
          totalSupply = 1000000000;
          forSale = _forSale;
          ecoSystemFund = _ecoSystemFund;
          founders = _founders;
          team = _team;
          advisers = _advisers;
          bounty = _bounty;

          balances[forSale] = totalSupply * 60 / 100;
          balances[ecoSystemFund] = totalSupply * 15 / 100;
          balances[founders] = totalSupply * 15 / 100;
          balances[team] = totalSupply * 5 / 100;
          balances[advisers] = totalSupply * 3 / 100;
          balances[bounty] = totalSupply * 2 / 100;
        }

        function transferByOwner(address from, address to, uint256 value) public onlyOwner {
          require(balances[from] >= value);
          balances[from] = balances[from].sub(value);
          balances[to] = balances[to].add(value);
          Transfer(from, to, value);
        }

        function transferByCrowdsale(address to, uint256 value) public onlyCrowdsale {
          require(balances[forSale] >= value);
          balances[forSale] = balances[forSale].sub(value);
          balances[to] = balances[to].add(value);
          Transfer(forSale, to, value);
        }

        function releaseForTransfer() public onlyCrowdsaleOrOwner {
          require(!releasedForTransfer);
          releasedForTransfer = true;
        }

        function transfer(address _to, uint256 _value) public returns (bool) {
          require(releasedForTransfer);
          return super.transfer(_to, _value);
        }

        function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
           require(releasedForTransfer);
           return super.transferFrom(_from, _to, _value);
        }
}
