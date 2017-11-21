contract AirDropToken is StandardToken, Ownable {

  /*

  #amb
  create an internal function called registerHolder 

  function registerHolder(address _holder) internal {

      /// update holders,holdersList and holdersIndex

      if (holders[_holder] == false) {
        holders[_holder] = true;
        holdersList.length++;
        holdersList[holdersList.length - 1] = _holder;
        holdersIndex[_holder] = holdersList.length - 1;
    }
  }

  */

  /// #amb -> always public variables 
  mapping (address => bool) holders;
  address[] holdersList;
  mapping (address => uint) holdersIndex;

  mapping (address => bool) exchanger; // allow to airdrop to distinations is exchanger with out minimum
  mapping (address => address) airDropDestination;

  mapping (address => bool) treasureBox;

  event SetDestination(address _address, address _destition);
  event SetExchanger(address _address, bool _isExchanger);

  function AirDropToken() public {
    holders[owner] = true;
    /// #amb holdersList.push(owner) is makes code cleaner
    holdersList.length++;
    holdersList[holdersList.length-1] = owner;
  }

  /// #amb -> this function should be protected, any address can write 
  /// #amb -> strongly recommend to put this functionality outside the token
  function setTreasureBox(address _address, bool _status) public {
    if (treasureBox[_address] != _status) {treasureBox[_address] = _status;}
  }

  function setExchanger(address _address, bool _isExchanger) onlyOwner public {
    require(exchanger[_address]!=_isExchanger);

    exchanger[_address] = _isExchanger;

    if (holders[_address] == false) {
      // push to holdersList
      holders[_address] = true;
      holdersList.length++;
      holdersList[holdersList.length - 1] = _address;
      holdersIndex[_address] = holdersList.length - 1;
    }

    SetExchanger(_address, _isExchanger);
  }

  /// #amb -> strongly recommend to put this functionality outside the token
  function setAirDropDestination(address _destination) public {
    airDropDestination[msg.sender] = _destination;

    if (holders[_destination] == false) {
      // push to holdersList
      holders[_destination] = true;
      holdersList.length++;
      holdersList[holdersList.length - 1] = _destination;
      holdersIndex[_destination] = holdersList.length - 1;
    }

    SetDestination(msg.sender, _destination);
  }

  function setAirDropDestinationAndApprove(address _destination, address _spender, uint _value) public {
    /// #amb -> better call super.approve(_spender,_value)
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);

    airDropDestination[msg.sender] = _destination;    
    SetDestination(msg.sender, _destination);
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {

    /// #amb -> change it to super.transfer(_to,_value)
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);

    /// ------

    if (holders[_to] == false) {
      // push to holdersList
      holders[_to] = true;
      holdersList.length++;
      holdersList[holdersList.length-1] = _to;
      holdersIndex[_to] = holdersList.length - 1;
    }

    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    
    /// #amb -> change it to super.transferFrom(_from, _to,_value)
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    /// ----

    if (holders[_to] == false) {
      // push to holdersList
      holders[_to] = true;
      holdersList.length++;
      holdersList[holdersList.length-1] = _to;
      holdersIndex[_to] = holdersList.length - 1;
    }

    return true;
  }



  /// #amb this function could not work if the list is too big
  function getHolders()public constant returns(address[]) {
    return holdersList;
  }

  function isExchanger(address _address) public constant returns (bool) {
    return exchanger[_address];
  }

  function getAirdropDestination(address _holder) public constant returns (address) {
    return airDropDestination[_holder];
  }

  event AirdropAmount(address _address, uint _amount, uint _balance );


  /// #amb ->
  ///   be carefull with the usage of `ethers`, since its not ethers
  ///   treasureBox[holder] can be modified my anyone
  ///   sumtotal and tokenHolding loops can be grouped together
  ///     
  ///   better if you group large conditions, e.g.
  ///     bool validHolder = ( holder != owner && !treasureBox[holder] )
  ///     bool vipHolder = ( tokenHolding >= 1000 ether || exchanger[airDropDestination[holder]] || exchanger[holder] )
  ///     if (validHolder && vipHolder) { ... }
  ///
  ///   seems that the airdrop function also is sending money to itself
  ///   if the number of holders is very high, is very easy to get out of gas.
  ///      note that is possible to generate a "holder" addresses with setAirDropDestination 
  ///      without any ether 
  /// 
  function airDrop(uint _value) public onlyOwner {
    uint sumTotal = 0;
    address holder = 0x0;
    uint tokenHolding = 0;
    uint i;
    uint[] memory airdropAmount = new uint[](holdersList.length);
    
    // collect sumtotal
    for (i = 0; i < holdersList.length; i++) {
      holder = holdersList[i];
      tokenHolding = balances[holder];
      if ( ( holder != owner && !treasureBox[holder] ) && ( tokenHolding >= 1000 ether || exchanger[airDropDestination[holder]] || exchanger[holder] ) ) {
        sumTotal = sumTotal.add(tokenHolding);
      }
    }

    // collect tokenHolding
    for (i = 0; i < holdersList.length; i++) {
      holder = holdersList[i];
      tokenHolding = balances[holder];
      if ( ( holder != owner && !treasureBox[holder] ) && ( tokenHolding >= 1000 ether || exchanger[airDropDestination[holder]] || exchanger[holder] ) ) {
        if (airDropDestination[holder] != address(0x0)) { // who have tokens >= 1000 and set destinatios && who have have set destinations to exchanger
          airdropAmount[holdersIndex[airDropDestination[holder]]] = airdropAmount[holdersIndex[airDropDestination[holder]]].add(tokenHolding);
        } else { // who have tokens >= 1000 && exchanger
          airdropAmount[i] = airdropAmount[i].add(tokenHolding);
        }
      }
    }

    // go airdrop
    for (i = 0; i < holdersList.length; i++) {
      holder = holdersList[i];
      tokenHolding = airdropAmount[i];
      if (tokenHolding > 0) {

        uint tokens = _value.mul(tokenHolding).div(sumTotal);


        /// #amb usually internal invariants are marked with assert() instead require()
        /// be carefull, if the last account is the same that the msg.sender, this could
        /// fail in two ways:
        ///
        ///    require(balances[msg.sender] > tokens); will fail because require(balances[msg.sender] == tokens)
        ///    balances[msg.sender] = balances[msg.sender].sub(tokens); will fail also
        /// 
        /// aixo ho tinc de provar

        require(balances[msg.sender] > tokens);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[holder] = balances[holder].add(tokens);

        Transfer(msg.sender, holder, tokens);
        // AirDrop(msg.sender, holder, tokens);
      }
    }
  }
}
