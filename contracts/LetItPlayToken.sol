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
        address public eosShareDrop;

        bool releasedForTransfer;

        uint256 private shift;

        //initial coin distribution
        function LetItPlayToken(
            address _forSale,
            address _ecoSystemFund,
            address _founders,
            address _team,
            address _advisers,
            address _bounty,
            address _preSale,
            address _eosShareDrop
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
          eosShareDrop = _eosShareDrop;
          preSale = _preSale;

          balances[forSale] = totalSupply * 59 / 100;
          balances[ecoSystemFund] = totalSupply * 15 / 100;
          balances[founders] = totalSupply * 15 / 100;
          balances[team] = totalSupply * 5 / 100;
          balances[advisers] = totalSupply * 3 / 100;
          balances[bounty] = totalSupply * 1 / 100;
          balances[preSale] = totalSupply * 1 / 100;
          balances[eosShareDrop] = totalSupply * 1 / 100;
        }

        function transferByOwner(address from, address to, uint256 value) public onlyOwner {
          require(balances[from] >= value);
          balances[from] = balances[from].sub(value);
          balances[to] = balances[to].add(value);
          emit Transfer(from, to, value);
        }

        //can be called by crowdsale before token release, control over forSale portion of token supply
        function transferByCrowdsale(address to, uint256 value) public onlyCrowdsale {
          require(balances[forSale] >= value);
          balances[forSale] = balances[forSale].sub(value);
          balances[to] = balances[to].add(value);
          emit Transfer(forSale, to, value);
        }

        //can be called by crowdsale before token release, allowences is respected here
        function transferFromByCrowdsale(address _from, address _to, uint256 _value) public onlyCrowdsale returns (bool) {
            return super.transferFrom(_from, _to, _value);
        }

        //after the call token is available for exchange
        function releaseForTransfer() public onlyCrowdsaleOrOwner {
          require(!releasedForTransfer);
          releasedForTransfer = true;
        }

        //forbid transfer before release
        function transfer(address _to, uint256 _value) public returns (bool) {
          require(releasedForTransfer);
          return super.transfer(_to, _value);
        }

        //forbid transfer before release
        function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
           require(releasedForTransfer);
           return super.transferFrom(_from, _to, _value);
        }

        function burn(uint256 value) public  onlyOwner {
            require(value <= balances[msg.sender]);
            balances[msg.sender] = balances[msg.sender].sub(value);
            balances[address(0)] = balances[address(0)].add(value);
            emit Transfer(msg.sender, address(0), value);
        }
}
