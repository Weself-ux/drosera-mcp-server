// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ITrap} from "contracts/interfaces/ITrap.sol";

/**
 * @title DormantContractTrap
 * @notice Monitors contract for dormancy - detects when contract becomes inactive
 * @dev Trap that detects when monitored addresses have no activity for 25+ blocks
 */
contract DormantContractTrap is ITrap {

    struct ContractSnapshot {
        address contractAddress;
        uint256 balance;
        uint256 nonce;
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

    uint256 constant DORMANCY_THRESHOLD_BLOCKS = 25;
    
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
                nonce: _getNonce(contractAddr),
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
        if (data.length < 2) {
            return (false, "");
        }

        ContractSnapshot[] memory currentSnapshots = abi.decode(data[0], (ContractSnapshot[]));
        ContractSnapshot[] memory olderSnapshots = abi.decode(data[data.length - 1], (ContractSnapshot[]));

        DormancyAlert[] memory alerts = new DormancyAlert[](currentSnapshots.length);
        uint256 alertCount = 0;

        for (uint256 i = 0; i < currentSnapshots.length; i++) {
            ContractSnapshot memory current = currentSnapshots[i];
            ContractSnapshot memory older = olderSnapshots[i];

            uint256 blocksSinceLastActivity = current.blockNumber - older.blockNumber;
            bool hasActivity = _hasActivityBetweenSnapshots(current, older);

            if (!hasActivity && blocksSinceLastActivity >= DORMANCY_THRESHOLD_BLOCKS) {
                alerts[alertCount++] = DormancyAlert({
                    contractAddress: current.contractAddress,
                    currentBalance: current.balance,
                    lastActiveBlock: older.blockNumber,
                    dormantBlocks: blocksSinceLastActivity,
                    blockNumber: current.blockNumber,
                    alertType: "BECAME_DORMANT"
                });
            } else if (hasActivity) {
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

    function _hasActivityBetweenSnapshots(
        ContractSnapshot memory current,
        ContractSnapshot memory older
    ) internal pure returns (bool) {
        return (
            current.balance != older.balance ||
            current.nonce != older.nonce ||
            current.codeHash != older.codeHash
        );
    }

    function _getNonce(address addr) internal view returns (uint256) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }

        if (size > 0) {
            return 1;
        } else {
            return _getEOANonce(addr);
        }
    }

    function _getEOANonce(address addr) internal view returns (uint256 nonce) {
        assembly {
            nonce := extcodehash(addr)
        }
        return nonce;
    }

    function getMonitoredContracts() external view returns (address[] memory) {
        return monitoredContracts;
    }

    function addMonitoredContract(address contractAddr) external {
        monitoredContracts.push(contractAddr);
    }
}
