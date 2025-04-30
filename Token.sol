pragma solidity ^0.8.22;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20, AccessControl {
    bytes32 public constant Minter_Role = keccak256("Minter_Role");
    constructor() ERC20("MyToken", "MTK") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(Minter_Role,msg.sender);
    }
    function mint(address to, uint256 amount) public onlyRole(Minter_Role){
        _mint(to,amount);
    }
    function decimals() public pure override returns (uint8){
        return 2;
    }
}