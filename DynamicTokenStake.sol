// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
interface TokenInterface {
    function allowance(address owner,address spender)external view returns(uint256);
    function balanceof(address account)external view returns(uint256);
    function decimals()external view returns(uint8);
    function mint(address account,uint256 amount)external;
    function transfer(address to,uint256 value)external returns(bool);
    function transferfrom(address from,address to,uint amount)external returns(bool);
}
contract DynamicStake{
       TokenInterface public myToken;
       AggregatorV3Interface public PriceFeed;
       mapping(address=>uint256) public staked;
       mapping(address=>uint256) public LastClaim;
       uint256 constant PriceFeed_Decimals = 8;
       uint256 constant Rate_Divisor = 10000;
       uint8 public Token_Decimals;
       event Stacked(address indexed user,uint256 amount);
       event UnStacked(address indexed user,uint256 amount);
       event RewardClaimed(address indexed user,uint256 Reward);
       constructor (address Token){
           myToken = TokenInterface(Token);
           Token_Decimals = myToken.decimals();
           address PriceFeedAddress = 0xDF47C9EFAB2b319A5Ee2Cc745F35240E5Ec25F84;
           PriceFeed = AggregatorV3Interface(PriceFeedAddress);
       }
       function Stake(uint256 amount)external{
            require(amount>0,"Enter Amount");
            require(myToken.allowance(msg.sender,address(this))>=amount,"Allowance is not Enough");
            require(myToken.balanceof(msg.sender)>=amount,"Amount>TokenBalance");
            myToken.transferfrom(msg.sender,address(this),amount);
            claimReward();
            staked[msg.sender]+=amount;
            LastClaim[msg.sender] = block.timestamp;
            emit Stacked(msg.sender,amount);
       }
       function claimReward() public{
            uint256 reward = calculateReward(msg.sender);
            if(reward>0){
                myToken.mint(msg.sender,reward);
                LastClaim[msg.sender] = block.timestamp;
                emit RewardClaimed(msg.sender,reward);
             }
       }
       function getCLDataFeedLatest()public view returns(int){
              (,int256 price, , , ) =  PriceFeed.latestRoundData();
              return price;
       }
       function CalculateMinuteStacked(address user)public view returns(uint256){
               if(LastClaim[user]>0){
                   return (block.timestamp-LastClaim[user])/60;
               }else {
                  return 0;
               }
       }
       function calculateReward(address user)public view returns(uint256){
             int price = getCLDataFeedLatest();
             if(price<=0)return 0;
             uint256 RewardRate = uint256(price)/Rate_Divisor;
             uint256 minuteStaked = CalculateMinuteStacked(user);
             uint256 decimalsAdjustment = 10**(PriceFeed_Decimals-uint256(Token_Decimals));
             uint256 rewardAmount = (staked[user]*RewardRate*minuteStaked)/decimalsAdjustment;
             return rewardAmount;

       }
       function unStake() external  {
           require(staked[msg.sender]>0,"Unstaked Amount");
           claimReward();
           uint256 amount = staked[msg.sender];
           staked[msg.sender] = 0;
           myToken.transfer(msg.sender,amount);
           emit UnStacked(msg.sender,amount);



       }



}