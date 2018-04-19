pragma solidity ^0.4.19;
import "./Crowdsaled.sol";
import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
contract LetItPlayToken is Crowdsaled, StandardToken {
        uint256 public totalSupply;
        string public name;
        string public symbol;
        uint8 public decimals;

        address public forSale;
        address public preSale;
        address public ecoSystemFund;
        address public founders;
        address public team;
        address public advisers;
        address public bounty;

        bool releasedForTransfer;

        uint256 private shift;

        function LetItPlayToken(
            address _forSale,
            address _ecoSystemFund,
            address _founders,
            address _team,
            address _advisers,
            address _bounty,
            address _preSale,
            uint256 _preSaleTokens
          ) public {
          name = "LetItPlayToken";
          symbol = "PLAY";
          decimals = 8;
          shift = uint256(10)**decimals;
          totalSupply = 1000000000 * shift;
          forSale = _forSale;
          ecoSystemFund = _ecoSystemFund;
          founders = _founders;
          team = _team;
          advisers = _advisers;
          bounty = _bounty;
          preSale = _preSale;

          uint256 forSaleTokens = totalSupply * 60 / 100;
          _preSaleTokens = _preSaleTokens * shift;

          balances[forSale] = forSaleTokens - _preSaleTokens;
          balances[preSale] = _preSaleTokens;
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
          emit Transfer(from, to, value);
        }

        function transferByCrowdsale(address to, uint256 value) public onlyCrowdsale {
          require(balances[forSale] >= value);
          balances[forSale] = balances[forSale].sub(value);
          balances[to] = balances[to].add(value);
          emit Transfer(forSale, to, value);
        }

        function transferFromByCrowdsale(address _from, address _to, uint256 _value) public onlyCrowdsale returns (bool) {
            return super.transferFrom(_from, _to, _value);
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
