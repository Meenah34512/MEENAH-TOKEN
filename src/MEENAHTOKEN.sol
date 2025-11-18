// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MEENAHTOKEN is ERC20, Ownable {
    uint256 public constant MINT_AMOUNT = 100 * 10**18;
    
    mapping(address => bool) public hasClaimedAirdrop;
    bool public airdropActive;
    
    event AirdropClaimed(address indexed recipient, uint256 amount);
    event AirdropStatusChanged(bool active);
    event BatchAirdropCompleted(uint256 recipientCount, uint256 totalAmount);

    constructor() ERC20("MEENAHTOKEN", "MNH") Ownable(msg.sender) {
        airdropActive = true;
    }

  
    function claimAirdrop() external {
        require(airdropActive, "Airdrop is not active");
        require(!hasClaimedAirdrop[msg.sender], "Airdrop already claimed");
        
        hasClaimedAirdrop[msg.sender] = true;
        _mint(msg.sender, MINT_AMOUNT);
        
        emit AirdropClaimed(msg.sender, MINT_AMOUNT);
    }

 
    function batchAirdrop(address[] calldata recipients) external onlyOwner {
        require(recipients.length > 0, "No recipients provided");
        
        uint256 totalMinted = 0;
        
        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            require(recipient != address(0), "Invalid recipient address");
            
            if (!hasClaimedAirdrop[recipient]) {
                hasClaimedAirdrop[recipient] = true;
                _mint(recipient, MINT_AMOUNT);
                totalMinted += MINT_AMOUNT;
                
                emit AirdropClaimed(recipient, MINT_AMOUNT);
            }
        }
        
        emit BatchAirdropCompleted(recipients.length, totalMinted);
    }

  
    function setAirdropActive(bool active) external onlyOwner {
        airdropActive = active;
        emit AirdropStatusChanged(active);
    }

 
    function hasClaimedAirdropView(address account) external view returns (bool) {
        return hasClaimedAirdrop[account];
    }


    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

 
    function decimals() public pure override returns (uint8) {
        return 18;
    }
}
