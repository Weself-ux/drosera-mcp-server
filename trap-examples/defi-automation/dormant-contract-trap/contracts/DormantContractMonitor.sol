// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ITrap} from "contracts/interfaces/ITrap.sol";

/**
 * @title DormantContractTrap
 * @notice Monitors dormant contract for any reactivation activity
 * @dev Simple dead man's switch - alerts on any signs of life from dormant contract
 */
contract DormantContractTrap is ITrap {

    struct ContractSnapshot {
        address contractAddress;
        uint256 balance;
        uint256 blockNumber;
        uint256 timestamp;
        bytes32 codeHash;
    }

    struct DormancyAlert {
        address contractAddress;
        uint256 currentBalance;
        uint256 lastActiveBlock;
        uint256 dormantBlocks;
        uint256 blockNumber;
        string alertType;
    }

    address[] public monitoredContracts;

    constructor() {
        monitoredContracts.push(0x1e39Bf6C913e9dE1a303a26fdf8557923aA8D1bd);
    }

    function collect() external view override returns (bytes memory) {
        ContractSnapshot[] memory snapshots = new ContractSnapshot[](monitoredContracts.length);

        for (uint256 i = 0; i < monitoredContracts.length; i++) {
            address contractAddr = monitoredContracts[i];

            snapshots[i] = ContractSnapshot({
                contractAddress: contractAddr,
                balance: contractAddr.balance,
                blockNumber: block.number,
                timestamp: block.timestamp,
                codeHash: contractAddr.codehash
            });
        }

        return abi.encode(snapshots);
    }

    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool shouldTrigger, bytes memory responseData)
    {
        if (data.length == 0) {
            return (false, "");
        }

        ContractSnapshot[] memory currentSnapshots = abi.decode(data[0], (ContractSnapshot[]));
        
        DormancyAlert[] memory alerts = new DormancyAlert[](currentSnapshots.length);
        uint256 alertCount = 0;

        for (uint256 i = 0; i < currentSnapshots.length; i++) {
            ContractSnapshot memory current = currentSnapshots[i];

            // Check if dormant contract shows any signs of activity
            if (current.balance > 0) {
                alerts[alertCount++] = DormancyAlert({
                    contractAddress: current.contractAddress,
                    currentBalance: current.balance,
                    lastActiveBlock: current.blockNumber,
                    dormantBlocks: 0,
                    blockNumber: current.blockNumber,
                    alertType: "REACTIVATED"
                });
            }
        }

        if (alertCount > 0) {
            DormancyAlert[] memory result = new DormancyAlert[](alertCount);
            for (uint256 i = 0; i < alertCount; i++) {
                result[i] = alerts[i];
            }
            return (true, abi.encode(result));
        }

        return (false, "");
    }
}
