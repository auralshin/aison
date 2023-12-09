pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC20, ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { SafeERC20 } from "@1inch/solidity-utils/contracts/libraries/SafeERC20.sol";

contract InvestmentPool is ERC20 {
    struct Pool {
        address nftOwner;
        uint256 targetAmount;
        uint256 currentAmount;
        uint256 nftId;
        bool isFunded;
    }

    mapping(uint256 => Pool) public pools;
    IERC721 public nftContract;
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;

    constructor(IERC20Metadata stakingToken_, IERC20 rewardsToken_, address _nftContractAddress)
        ERC20(
            string(abi.encodePacked("Farming of ", stakingToken_.name())),
            string(abi.encodePacked("farm", stakingToken_.symbol()))
        )
    {
        nftContract = IERC721(_nftContractAddress);
        stakingToken = stakingToken_;
        rewardsToken = rewardsToken_;
    }

    function decimals() public view virtual override returns (uint8) {
        return IERC20Metadata(address(stakingToken)).decimals();
    }

    function lockNFTAndCreatePool(uint256 _nftId, uint256 _targetAmount) external {
        require(nftContract.ownerOf(_nftId) == msg.sender, "Not NFT owner");
        nftContract.transferFrom(msg.sender, address(this), _nftId);
        pools[_nftId] = Pool(msg.sender, _targetAmount, 0, _nftId, false);
    }

    function invest(uint256 _nftId) external payable {
        Pool storage pool = pools[_nftId];
        require(pool.nftOwner != address(0), "Pool does not exist");
        require(!pool.isFunded, "Pool already funded");
        require(pool.currentAmount + msg.value <= pool.targetAmount, "Investment exceeds target");
        
        pool.currentAmount += msg.value;
        if (pool.currentAmount == pool.targetAmount) {
            pool.isFunded = true;
            payable(pool.nftOwner).transfer(pool.currentAmount);
            nftContract.transferFrom(address(this), pool.nftOwner, _nftId);
        }
    }
}
