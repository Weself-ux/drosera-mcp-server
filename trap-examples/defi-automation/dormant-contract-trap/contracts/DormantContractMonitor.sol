// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ITrap} from "contracts/interfaces/ITrap.sol";

/**
 * @title DormantContractTrap
 * @notice Monitors dormant contract for reactivation
 * @dev Detects when a stable contract becomes active again
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
        uint256 olderN = 20;
        uint256 newerM = 5;

        if (data.length < olderN + newerM) {
            return (false, "");
        }

        ContractSnapshot[] memory newest = abi.decode(data[0], (ContractSnapshot[]));
        uint256 n = newest.length;
        if (n == 0) return (false, "");

        DormancyAlert[] memory alerts = new DormancyAlert[](n);
        uint256 alertCount = 0;

        for (uint256 i = 0; i < n; i++) {
            address addr = newest[i].contractAddress;

            ContractSnapshot memory baseline = abi.decode(data[newerM], (ContractSnapshot[]))[i];

            bool olderStable = true;
            for (uint256 j = newerM; j < olderN + newerM; j++) {
                ContractSnapshot memory snap = abi.decode(data[j], (ContractSnapshot[]))[i];
                if (snap.balance != baseline.balance || snap.codeHash != baseline.codeHash) {
                    olderStable = false;
                    break;
                }
            }

            if (!olderStable) {
                continue;
            }

            bool changedNow = false;
            for (uint256 j = 0; j < newerM; j++) {
                ContractSnapshot memory snap = abi.decode(data[j], (ContractSnapshot[]))[i];
                if (snap.balance != baseline.balance || snap.codeHash != baseline.codeHash) {
                    changedNow = true;
                    break;
                }
            }

            if (!changedNow) {
                continue;
            }

            ContractSnapshot memory cur = newest[i];
            uint256 dormantBlocks = cur.blockNumber - abi.decode(data[newerM], (ContractSnapshot[]))[i].blockNumber;

            alerts[alertCount++] = DormancyAlert({
                contractAddress: addr,
                currentBalance: cur.balance,
                lastActiveBlock: cur.blockNumber,
                dormantBlocks: dormantBlocks,
                blockNumber: cur.blockNumber,
                alertType: "REACTIVATED"
            });
        }

        if (alertCount == 0) return (false, "");

        DormancyAlert[] memory result = new DormancyAlert[](alertCount);
        for (uint256 k = 0; k < alertCount; k++) result[k] = alerts[k];
        return (true, abi.encode(result));
    }
}
