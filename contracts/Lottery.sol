pragma solidity ^0.6.6

contract Lottery {
    address payable[] public players;
    uint256 public usdEntryFee;
    AggregatorV3Interface internal ethUsdPriceFeed;

    constructor (address _priceFeedAddress) public {
        usdEntryFee = 50 * (10**18);
        ethUsdPriceFeed = AggregatorV3Interface();
    }

    function enter() public payable{
        players.push(msg.sender)
    }

    function getEntranceFee() public view returns(uint256) {

    }

    function startLottery() public {}

    function endLottery() public {}
}