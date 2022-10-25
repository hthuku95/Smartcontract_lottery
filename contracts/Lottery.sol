// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "../interfaces/AggregatorV3Interface.sol";
import "../interfaces/VRFConsumerBase.sol";
import "./Ownable.sol";

contract Lottery is VRFConsumerBase, Ownable {
    address payable[] public players;
    uint256 public usdEntryFee;
    uint256 public randomness;
    address payable public recentWinner;
    AggregatorV3Interface internal ethUsdPriceFeed;

    /**
    Using an Enum to create a new user defined type. They work like Structs
    Enums are represented by numbers 0 = Open, 1 = Closed, 2 = Calculating_winner, in the below enum type
     */

    enum LOTTERY_STATE  {
        OPEN, 
        CLOSED,
        CALCULATING_WINNER
    }

    LOTTERY_STATE public lottery_state;
    uint256 public fee;
    bytes32 public keyhash;

    constructor (
        address _priceFeedAddress,
        address _vrfCoodinator,
        address _link,
        uint256 _fee,
        bytes32 _keyhash
        ) public VRFConsumerBase(_vrfCoodinator,_link) {
            usdEntryFee = 50 * (10**18);
            ethUsdPriceFeed = AggregatorV3Interface(_priceFeedAddress);
            lottery_state = LOTTERY_STATE.CLOSED;
            fee = _fee;
            keyhash = _keyhash;
        }

    function enter() public payable{
        require(lottery_state == LOTTERY_STATE.OPEN,"Lottery state is not yet open");
        require(msg.value >= getEntranceFee(),"Not enough ETH!");
        players.push(msg.sender);
    }

    function getEntranceFee() public view returns(uint256) {
        (,int price,,,) = ethUsdPriceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price) * 10**10;

        uint256 costToEnter = (usdEntryFee *10**18) / adjustedPrice;
        return costToEnter;

    }

    function startLottery() public onlyOwner {
        require(lottery_state == LOTTERY_STATE.CLOSED,"Cant Start a new Lottery yet");
        lottery_state = LOTTERY_STATE.OPEN;
    }
    
    function endLottery() public onlyOwner {
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        requestRandomness(keyhash,fee);
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness) internal override {
        require(lottery_state == LOTTERY_STATE.CALCULATING_WINNER,"You are not there yet");
        require(_randomness > 0,"Random not found");
        uint256 indexOfWinner = _randomness % players.length;
        recentWinner = players[indexOfWinner];

        // Giving the recent winner their price
        recentWinner.transfer(address(this).balance);
        // Reset
        players = new address payable[](0);
        lottery_state = LOTTERY_STATE.CLOSED;
        randomness = _randomness;
    }
}