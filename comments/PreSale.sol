contract PreSale is Ownable {
  using SafeMath for uint;

  event TokenSold(address _recipient, uint _value, uint _tokens, uint _rate);
  event TokenSold(address _recipient, uint _tokens);

  ZMINE public token;
  
  /// #amb -> do it public
  WhiteList whitelist;

  uint public hardCap = 300000000 ether; // 300M
  uint public remain = 300000000 ether; // 300M

  uint public startDate = 1512007200; /// 2017-11-30T02:00:00+00:00 in ISO 8601
  uint public stopDate = 1514599200;  /// 2017-12-30T02:00:00+00:00 in ISO 8601

  uint public minTx = 100 ether;
  uint public maxTx = 100000 ether;

  /// #amb -> do it public
  RateContract rateContract;

  function PreSale (ZMINE _token, RateContract _rateContract, WhiteList _whitelist) public {
    token = ZMINE(_token);
    rateContract = RateContract(_rateContract);
    whitelist = WhiteList(_whitelist);
  }

  /**
   * tranfer token to presale investor who pay by fieast ///#amb fiat?
   */
  /// #amb anybody call this function to get tokens
  ///      try to be consistent with naming here is _amount, in sale is _value
  function tranferFor(address _recipient, uint _amount) public { /// #amb type: transferFor
    require(now > startDate && now < stopDate);
    require(_amount >= minTx && _amount <= maxTx && _amount <= remain);

    remain = remain.sub(_amount);
    token.transferFrom(owner, _recipient, _amount);

    TokenSold(_recipient, _amount);
  }

  function sale(address _recipient, uint _value) private {
    require(now > startDate && now < stopDate);
    require(whitelist.isWhiteListed(_recipient));
    require(_value >= minTx && _value <= maxTx && _value <= remain);
    uint rate = this.rate();
    uint tokens = rate.mul(_value).div(1 ether);

    remain = remain.sub(tokens);
    token.transferFrom(owner, _recipient, tokens);

    /// #amb -> better use transfer when sending ethers
    ///         we recommend not to create an account only to store
    ///         the recieved ethers (usually is a multisig)
    require(owner.send(_value));

    TokenSold(_recipient, _value, tokens, rate);
  }
  
  function rate() constant public returns (uint) {
    return rateContract.getRate();
  }

  function avalible () constant public returns (bool) { /// #amb typo : avalible?
    return (now > startDate && now < stopDate);
  }

  function isWhiteListed (address _address) constant public returns(bool) {
    return whitelist.isWhiteListed(_address);
  }

  function() external payable {
    sale(msg.sender, msg.value);
  }
}
