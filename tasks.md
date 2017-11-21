# Tasks

[ ] general review
[ ] use tools to detect errors
[ ] vars, etc... ?
[ ] modifiers
[ ] globals search
[ ] functions search
[ ] function parameters search 
[ ] follow the money
[ ] detailed exam of non-owner functions
[ ] review tests


address owner -> owner of all contract
address founder1, founder2 -> founders addresses
address presaleFiatPayer -> payed with fiat the presale
address presaleEtherPayer -> pays with ether the presale
address icoEtherPayer -> pays with ether the ICO

zmine = new ZIMINE( {from : owner }) // gives 1000 M to onwer

/// -- founders
founderThreader = new FounderThreader(zmine,[founder1,founder2])
zmine.allow(founderThreader,300M)
founderThreader.tranferFor(founder1, 150M)
founderThreader.tranferFor(founder2, 150M)

/// --- presale
rateContract = new RateContract()
whitelistPre = new WhiteList()
presale = new PreSale(zmine, rateContract, whitelistPre, {from : owner}) // 300 M
zmine.allow(presale,300M, {from : owner})

presale.tranferFor(presaleFiatPayer,1000, {from : owner })

whitelistPre.setwhiteListed(presaleEtherPayer,true)
presale.transfer(2000, { from : presaleEtherPayer })

/// --- ICOSale
whitelistIco = new WhiteList()
icosale = new ICOSale( zmine, rateContract, whitelistPre, whitelistIco, {from : owner}) // 400 M
zmine.allow(icosale,400M, {from : owner})
whitelistPre.setwhiteListed(icoEtherPayer,true)
icosale.transfer(2000, { from : icoEtherPayer })

/// --- Finish the ICO
zmine.burn(zmine.balanceOf(owner))

