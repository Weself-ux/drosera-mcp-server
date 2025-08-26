// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title DormantResponseContract
 * @notice Receives dormancy alerts from Drosera Protocol and emits events
 * @dev Called by Drosera when DormantContractTrap triggers
 */
contract DormantResponseContract {

    struct DormancyAlert {
        address contractAddress;
        uint256 currentBalance;
        uint256 lastActiveBlock;
        uint256 dormantBlocks;
        uint256 blockNumber;
        string alertType;
        uint256 timestamp;
        uint256 alertId;
    }

    event DormancyStatusChanged(
        address indexed contractAddress,
        string indexed alertType,
        uint256 currentBalance,
        uint256 lastActiveBlock,
        uint256 dormantBlocks,
        uint256 blockNumber,
        uint256 timestamp,
        uint256 alertId,
        string telegramMessage
    );

    DormancyAlert[] public allAlerts;
    mapping(address => uint256[]) public contractToAlertIds;
    mapping(address => uint256) public lastAlertTime;

    uint256 public totalAlerts;

    function notifyDormancyChange(bytes calldata alertData) external {
        try this.decodeAndProcess(alertData) {
        } catch {
            _emitFailedAlert();
        }
    }

    function decodeAndProcess(bytes calldata alertData) external {
        require(msg.sender == address(this), "Internal only");
        
        DormancyAlert[] memory alerts = abi.decode(alertData, (DormancyAlert[]));

        for (uint256 i = 0; i < alerts.length; i++) {
            DormancyAlert memory alert = alerts[i];

            DormancyAlert memory fullAlert = DormancyAlert({
                contractAddress: alert.contractAddress,
                currentBalance: alert.currentBalance,
                lastActiveBlock: alert.lastActiveBlock,
                dormantBlocks: alert.dormantBlocks,
                blockNumber: alert.blockNumber,
                alertType: alert.alertType,
                timestamp: block.timestamp,
                alertId: totalAlerts
            });

            allAlerts.push(fullAlert);
            contractToAlertIds[alert.contractAddress].push(totalAlerts);
            lastAlertTime[alert.contractAddress] = block.timestamp;

            emit DormancyStatusChanged(
                alert.contractAddress,
                alert.alertType,
                alert.currentBalance,
                alert.lastActiveBlock,
                alert.dormantBlocks,
                alert.blockNumber,
                block.timestamp,
                totalAlerts,
                _buildTelegramMessage(fullAlert)
            );

            totalAlerts++;
        }
    }

    function _emitFailedAlert() internal {
        emit DormancyStatusChanged(
            address(0x1e39Bf6C913e9dE1a303a26fdf8557923aA8D1bd),
            "DECODE_FAILED",
            0,
            0,
            0,
            block.number,
            block.timestamp,
            totalAlerts,
            "Failed to decode trap data"
        );
        totalAlerts++;
    }

    function _buildTelegramMessage(DormancyAlert memory alert) internal pure returns (string memory) {
        if (keccak256(bytes(alert.alertType)) == keccak256(bytes("BECAME_DORMANT"))) {
            return string(abi.encodePacked(
                " CONTRACT BECAME DORMANT\\n\\n",
                " Address: ", _addressToString(alert.contractAddress), "\\n",
                " Balance: ", _uint256ToString(alert.currentBalance), " wei\\n",
                " Dormant for: ", _uint256ToString(alert.dormantBlocks), " blocks (~",
                _uint256ToString(alert.dormantBlocks * 12 / 60), " minutes)\\n",
                " Last Active Block: ", _uint256ToString(alert.lastActiveBlock), "\\n",
                " Current Block: ", _uint256ToString(alert.blockNumber)
            ));
        } else {
            return string(abi.encodePacked(
                " CONTRACT REACTIVATED\\n\\n",
                " Address: ", _addressToString(alert.contractAddress), "\\n",
                " Current Balance: ", _uint256ToString(alert.currentBalance), " wei\\n",
                " Activity detected at block: ", _uint256ToString(alert.blockNumber), "\\n",
                " Status: ACTIVE AGAIN!"
            ));
        }
    }

    function _addressToString(address addr) internal pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(addr)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }

    function _uint256ToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function getAllAlerts() external view returns (DormancyAlert[] memory) {
        return allAlerts;
    }

    function getAlertsForContract(address contractAddress) external view returns (DormancyAlert[] memory) {
        uint256[] memory alertIds = contractToAlertIds[contractAddress];
        DormancyAlert[] memory contractAlerts = new DormancyAlert[](alertIds.length);

        for (uint256 i = 0; i < alertIds.length; i++) {
            contractAlerts[i] = allAlerts[alertIds[i]];
        }

        return contractAlerts;
    }

    function getLatestAlert() external view returns (DormancyAlert memory) {
        require(totalAlerts > 0, "No alerts yet");
        return allAlerts[totalAlerts - 1];
    }
}
