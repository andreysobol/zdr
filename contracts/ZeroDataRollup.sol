// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract ZeroDataRollup {

    event DepositInitiated(address indexed from, address indexed to, uint256 indexed coinId);

    uint256 public mintedCoinsCounter; // default 0
    uint256 public unprocessedDepositAmount; // default 0

    struct DepositDetails {
        uint256 coinId;
        uint256 amount;
        uint256 l1BlockNumber; 
    }
    mapping(address => DepositDetails) public mintedCoins; // default 0

    function deposit(
        address _l2Receiver)
    external payable {  
        require(msg.value > 0);  

        uint256 coinId = mintedCoinsCounter;
        mintedCoinsCounter = mintedCoinsCounter + 1;

        emit DepositInitiated(msg.sender, _l2Receiver, coinId);

        DepositDetails memory depositDetails= DepositDetails (
            coinId,
            msg.value,
            block.number
        );

        mintedCoins[msg.sender] = depositDetails;

        unprocessedDepositAmount = unprocessedDepositAmount + 1;
    }
}
