// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./Ownable.sol";
import "./AlphaFeedToken.sol";

/**

 $$$$$$\  $$\           $$\                       $$$$$$$$\                        $$\
$$  __$$\ $$ |          $$ |                      $$  _____|                       $$ |
$$ /  $$ |$$ | $$$$$$\  $$$$$$$\   $$$$$$\        $$ |    $$$$$$\   $$$$$$\   $$$$$$$ |
$$$$$$$$ |$$ |$$  __$$\ $$  __$$\  \____$$\       $$$$$\ $$  __$$\ $$  __$$\ $$  __$$ |
$$  __$$ |$$ |$$ /  $$ |$$ |  $$ | $$$$$$$ |      $$  __|$$$$$$$$ |$$$$$$$$ |$$ /  $$ |
$$ |  $$ |$$ |$$ |  $$ |$$ |  $$ |$$  __$$ |      $$ |   $$   ____|$$   ____|$$ |  $$ |
$$ |  $$ |$$ |$$$$$$$  |$$ |  $$ |\$$$$$$$ |      $$ |   \$$$$$$$\ \$$$$$$$\ \$$$$$$$ |
\__|  \__|\__|$$  ____/ \__|  \__| \_______|      \__|    \_______| \_______| \_______|
              $$ |
              $$ |
              \__|


https://alphafeed.app/

Dive into a platform where creators share valuable content. As an enthusiast, you have the unique opportunity to purchase and support these creators directly. With every transaction we are ensuring that creators are fair rewarded.

But that's not all! Both content creators and buyers earn AF tokens(0xe5C3b528BB0567576059344937784F97744c863C). These tokens open doors to exciting application features or offer liquidity, and engage in trades.

**/

contract AlphaFeed is Ownable {
    event NewPost(address owner, uint256 contentId);
    event NewBuyPost(address buyer, address owner, uint256 contentId, uint256 priceAmount, uint256 platformAmount, uint256 tokenAmountSentToBuyer, uint256 tokenAmountSentToContentCreator);

    // Address => (ContentId => Amount)
    mapping (address => mapping(uint256 => uint32)) public postOwners;
    mapping (uint256 => address) public contentOwner;
    mapping (uint256 => uint256) public contentPrice;
    mapping (uint256 => uint32) public contentSupply;
    mapping (address => uint256) public addressToTokenRewards;

    address public projectFeeAddress;
    uint8 public feePercent = 10; // 10%

    AlphaFeedToken public alphaFeedToken = new AlphaFeedToken();
    uint16 public alphaFeedTokensAirdropPerEthToBuyer = 1000;
    uint16 public alphaFeedTokensAirdropPerEthToContentCreator = 500;
    uint32 public buysOrSellsCount = 0;

    constructor() {
        projectFeeAddress = msg.sender;
    }

    function postContent(uint256 contentId, uint256 price) public {
        require(contentOwner[contentId] == address(0), "Content already created");

        address sender = msg.sender; // TODO optimize
        contentOwner[contentId] = sender;
        contentPrice[contentId] = price;
        emit NewPost(sender, contentId);
        buysOrSellsCount += 1;
    }

    function buyContent(uint256 contentId) public payable {
        require(contentOwner[contentId] != address(0), "No content");
        require(msg.value >= contentPrice[contentId], "Msg value should be bigger content price");

        uint256 platformFeeEthAmount= msg.value / (100 / feePercent);
        uint256 contentOwnerEthAmount = msg.value - platformFeeEthAmount;

        // Send ETH
        (bool success, ) = payable(contentOwner[contentId]).call{ value: contentOwnerEthAmount }("");
        require(success);

        (bool success1, ) = payable(projectFeeAddress).call{ value: platformFeeEthAmount }("");
        require(success1);

        // Send TOKEN
        uint256 alphaFeedTokensAirdropPerEthToBuyerRes = msg.value * alphaFeedTokensAirdropPerEthToBuyer;
        uint256 alphaFeedTokensAirdropPerEthToContentCreatorRes = msg.value * alphaFeedTokensAirdropPerEthToContentCreator;

        addressToTokenRewards[msg.sender] += alphaFeedTokensAirdropPerEthToBuyerRes;
        addressToTokenRewards[contentOwner[contentId]] += alphaFeedTokensAirdropPerEthToContentCreatorRes;

        // Update content info
        postOwners[msg.sender][contentId] += 1;
        contentSupply[contentId] += 1;
        buysOrSellsCount += 1;
        emit NewBuyPost(msg.sender, contentOwner[contentId], contentId, contentOwnerEthAmount, platformFeeEthAmount, alphaFeedTokensAirdropPerEthToBuyer, alphaFeedTokensAirdropPerEthToContentCreator);
    }

    function setProjectFeeAddress(address newFeeAddress) public onlyOwner {
        projectFeeAddress = newFeeAddress;
    }

    function setFeePercent(uint8 newValue) public onlyOwner {
        feePercent = newValue;
    }

    function setAlphaContentTokensAirdropPerEthToContentCreator(uint16 newValue) public onlyOwner {
        alphaFeedTokensAirdropPerEthToContentCreator = newValue;
    }

    function setAlphaContentTokensAirdropPerEthToBuyer(uint16 newValue) public onlyOwner {
        alphaFeedTokensAirdropPerEthToBuyer = newValue;
    }


    function hasPermissionToViewContent(uint256 contentId, address who) public view returns(bool) {
        return contentOwner[contentId] == who || postOwners[who][contentId] > 0;
    }

    function isContentOwner(uint256 contentId, address who) public view returns(bool) {
        return contentOwner[contentId] == who;
    }

    function ownsAmount(uint256 contentId, address who) public view returns(uint256) {
        return postOwners[who][contentId];
    }

    function withdawRewards() public {
        uint256 rewardsAmount = addressToTokenRewards[msg.sender];
        require(rewardsAmount > 0, "No rewards");
        addressToTokenRewards[msg.sender] = 0;
        alphaFeedToken.transfer(msg.sender, rewardsAmount);
    }

    // Admin stuff
    function withdrawAll() external payable onlyOwner {
        (bool success, ) = payable(owner()).call{ value: address(this).balance }("");
        require(success);
    }

    function withdrawToken(address _tokenContract, uint256 _amount) public onlyOwner {
        ERC20 tokenContract = ERC20(_tokenContract);

        // transfer the token from address of this contract
        // to address of the user (executing the withdrawToken() function)
        tokenContract.transfer(owner(), _amount);
    }

    function execute(address target, bytes memory data, uint256 _value) public onlyOwner {
        (bool success,) = target.call{value: _value}(data);
        require(success, "call failed");
    }
}