contract ICOSale is Ownable {
  using SafeMath for uint;

  event TokenSold(address _recipient, uint _value, uint _tokens, uint _rate);
  event IncreaseHaedCap(uint amount); /// #amb IncreaseHardCap 

  ZMINE public token;

  /// #amb -> do it public
  WhiteList whitelistICO;
  WhiteList whitelistPRE;

  uint public hardCap = 400000000 ether; /// 400M
  uint public remain = 400000000 ether;  /// 400M

  uint public startDate = 1515376800; /// 2018-01-08T02:00:00+00:00 in ISO 860
  uint public stopDate = 1517364000;  /// 2018-01-31T02:00:00+00:00 in ISO 8601

  uint public minTx = 1 ether;
  uint public maxTx = 100000 ether;

  RateContract rateContract;

  function ICOSale (ZMINE _token, RateContract _rateContract, WhiteList _whitelistPRE, WhiteList _whitelistICO) public {
    token = ZMINE(_token);
    rateContract = RateContract(_rateContract);
    whitelistPRE = WhiteList(_whitelistPRE);
    whitelistICO = WhiteList(_whitelistICO);
  }

  /**
   * increase hard cap if previous dont sold out
   */
  function increaseHardCap(uint amount) public onlyOwner {
    /// #amb -> use safemath
    ///         is possible to increase the cap higher that the amount of available tokens
    ///         allowed / minted
    hardCap = hardCap + amount;
    remain = remain + amount;
    IncreaseHaedCap(amount);
  }

  function sale(address _recipient, uint _value) private {
    require(now > startDate && now < stopDate);
    /// #amb why do not user function this.isWhiteListed ?
    require(whitelistPRE.isWhiteListed(_recipient) || (whitelistICO.isWhiteListed(_recipient)));
    require(_value >= minTx && _value <= maxTx && _value <= remain);
    uint rate = this.rate();
    uint tokens = rate.mul(_value).div(1 ether);

    remain = remain.sub(tokens);
    token.transferFrom(owner, _recipient, tokens);
    /// #amb -> user wallet motherfucker, use transfer
    require(owner.send(_value));

    TokenSold(_recipient, _value, tokens, rate);
  }
  
  function rate() constant public returns (uint) {
    return rateContract.getRate();
  }

  function avalible () constant public returns (bool) {
    return (now > startDate && now < stopDate);
  }

  function isWhiteListed (address _address) constant public returns(bool) {
    return (whitelistPRE.isWhiteListed(_address) || (whitelistICO.isWhiteListed(_address)));
  }

  function() external payable {
    sale(msg.sender, msg.value);
  }
}