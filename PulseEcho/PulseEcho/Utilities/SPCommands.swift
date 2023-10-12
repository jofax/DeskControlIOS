//
//  SpCommands.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-09.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation

protocol CommanBuilder {
     func GetSetHeightOffset(value: Double) -> String
     func GetEnableMotionCommand() -> String
     func GetDisableMotionCommand() -> String
     func GetStopCommand() -> String
     func GetMoveUpCommand() -> String
     func GetMoveDownCommand() -> String
     func GetMoveSittingCommand() -> String
     func GetMoveStandingCommand() -> String
     func GetSetDownCommand(value: Double) -> String
     func GetPresenceInverted() -> String
     func GetPresenceNoInverted() -> String
     func GetPresenceStandInverted() -> String
     func GetPresenceStandNoInverted() -> String
     func GetEnableSemiAutomaticMode() -> String
     func GetDisableSemiAutomaticMode() -> String
     func GetResetCommissionedOn() -> String
     func GetResetCommissionedOff() -> String
     func GetSerialNumber(value: String) -> String
     func GetAESKey(value: Double) -> String
     func GetCommitAESKey() -> String
     func GetRevertAESKey() -> String
     func GetAcknowkedgePendingMovement() -> String
     func GetAknowledgeSafetyCommand() -> String
     func GetSetCrushThreshold(value: Int) -> String
     func GetDeskTurnOn() -> String
     func GetDeskTurnOff() -> String
     func GetEnableSafetyCommand() -> String
     func GetDisableSafetyCommand() -> String
     func GetSetIndicatorLight(value: Int) -> String
     func GetSetTopCommand(value: Double) -> String
     func GetUserAuthenticatedOnCommand() -> String
     func GetUserAuthenticatedOffCommand() -> String
     func GetSetPNDThreshold(value: Int) -> String
     func GetSetPNDStandThreshold(value: Int) -> String
     func GetSetAwayAdjust(value: Int) -> String
     func GetCommitProfile() -> String
     func GetGridEyeOn() -> String
     func GetGridEyeOff() -> String
     func GetRowSelector(value: Double) -> String
     func GetColumnSelector(value: Double) -> String
     func GetResumeOutputCommand() -> String
     func GetStopOutputCommand() -> String
     func GetClearWatchdogAlarm() -> String
     func BuildProfileCommand(newMovement: [[String: Any]]) -> String
}

struct SPCommands: CommanBuilder {
    func GetSetHeightOffset(value: Double) -> String {
        let _value = String(format:"%.0f", value)
        return String(format:"a%@~",_value)
    }
    
    func GetEnableMotionCommand() -> String {
        return "B1~"
    }
    
    func GetDisableMotionCommand() -> String {
        return "B0~"
    }
    
    func GetStopCommand() -> String {
        return "C1~"
    }
    
    func GetMoveUpCommand() -> String {
        return "C6~"
    }
    
    func GetMoveDownCommand() -> String {
        return "C5~"
    }
    
    func GetMoveSittingCommand() -> String {
        return "Cd~"
    }
    
    func GetMoveStandingCommand() -> String {
        return "Cu~"
    }
    
    func GetSetDownCommand(value: Double) -> String {
        let _value = String(format:"%.0f", value)
        return String(format:"D%@~",_value)
    }
    
    func GetPresenceInverted() -> String {
        return "E1~"
    }
    
    func GetPresenceNoInverted() -> String {
        return "E0~"
    }
    
    func GetPresenceStandInverted() -> String {
        return "F1~"
    }
    
    func GetPresenceStandNoInverted() -> String {
        return "F0~"
    }
    func GetEnableSemiAutomaticMode() -> String {
        return "G1~"
    }
    
    func GetDisableSemiAutomaticMode() -> String {
        return "G0~"
    }
    
    func GetResetCommissionedOn() -> String {
        return "H1~"
    }
    
    func GetResetCommissionedOff() -> String {
        return "H0~"
    }
    
    func GetSerialNumber(value: String) -> String {
        return String(format: "I%@~",value)
    }
    
    func GetAESKey(value: Double) -> String {
        let _value = String(format:"%.0f", value)
         return String(format:"k%@~",_value)
    }
    
    func GetCommitAESKey() -> String {
        return "K1~"
    }
    
    func GetRevertAESKey() -> String {
        return "K0~"
    }
    
    func GetAcknowkedgePendingMovement() -> String {
        return "l~"
    }
    
    func GetAknowledgeSafetyCommand() -> String {
        return "L~"
    }
    
    func GetSetCrushThreshold(value: Int) -> String {
        //let _value = String(format:"%.0f", value)
         return String(format:"m%d~",value)
    }
    
    func GetDeskTurnOn() -> String {
        return "o1~"
    }
    
    func GetDeskTurnOff() -> String {
        return "o0~"
    }
    
    func GetEnableSafetyCommand() -> String {
        return "S1~"
    }
    
    func GetDisableSafetyCommand() -> String {
        return "S0~"
    }
    
    func GetSetIndicatorLight(value: Int) -> String {
        return String(format:"t%d~", value)
    }
    
    func GetSetTopCommand(value: Double) -> String {
        let _value = String(format:"%.0f", value)
        return String(format:"U%@~",_value)
    }
    
    func GetUserAuthenticatedOnCommand() -> String {
        return "W1~"
    }
    
    func GetUserAuthenticatedOffCommand() -> String {
        return "W0~"
    }
    
    func GetSetPNDThreshold(value: Int) -> String {
        //let _value = String(format:"%.0f", value)
        return String(format:"x%d~",value)
    }
    
    func GetSetPNDStandThreshold(value: Int) -> String {
        //let _value = String(format:"%.0f", value)
        return String(format:"v%d~",value)
    }
    
    func GetSetAwayAdjust(value: Int) -> String {
        //let _value = String(format:"%.0f", value)
        return String(format:"T%d~",value)
    }
    
    func GetCommitProfile() -> String {
        return "X~"
    }
    
    func GetGridEyeOn() -> String {
        return "V1~"
    }
    
    func GetGridEyeOff() -> String {
        return "V0~"
    }
    
    func GetRowSelector(value: Double) -> String {
        let _value = String(format:"%.0f", value)
        return String(format:"h%@~",_value)
    }
    
    func GetColumnSelector(value: Double) -> String {
        let _value = String(format:"%.0f", value)
        return String(format:"i%@~",_value)
    }
    
    func GetResumeOutputCommand() -> String {
        return "Z0~"
    }
    
    func GetStopOutputCommand() -> String {
        return "Z1~"
    }
    
    func GetClearWatchdogAlarm() -> String {
        return "y~"
    }
    
    func BLEHeartBeat() -> String {
        return "b0~"
    }
    
    func EnableHeartBeat() -> String {
        return "z0~"
    }
    
    func DisableHeartBeat() -> String {
        return "z1~"
    }
    
    
    func BuildProfileCommand(newMovement: [[String: Any]]) -> String {
        var _command = "P"
        let count = newMovement.count
        
        for (index, movement) in newMovement.enumerated() {
            let _value = movement["value"] as? Int ?? 0
            let _movement_type = movement["key"] as? String ?? "100"
            
            if _value == 0 {
                _command.append(String(format:"3,%@", _movement_type))
            } else {
                if _command.count == 1 {
                    _command.append(String(format:"%d,%@",_value, _movement_type))
                } else {
                    _command.append(String(format:"|%d,%@",_value, _movement_type))
                }
                
            }
            
            if (index == count - 1) {
               _command.append("~")
            }
            
        }
        
        print("_command: ", _command)
        
        return _command
    }
    
    func CreatProfileCommand(profile: ProfileSettings) -> String {
        var _command = "P"
        let _profileType: ProfileSettingsType = ProfileSettingsType(rawValue: profile.ProfileSettingType) ?? ProfileSettingsType.Active

        
        switch _profileType {
            case .Active:
                _command.append("3,7")
                let timeDiff = 60 - profile.StandingTime1
                _command.append(String(format:"|%d,4", timeDiff * 60))
            case .ModeratyleActive:
                _command.append("3,7")
                let timeDiff = 60 - profile.StandingTime1
                _command.append(String(format:"|%d,4", timeDiff * 60))
            case .VeryActive:
                _command.append("3,7")
                
                let timeDiff1 = 30 - profile.StandingTime1
                _command.append(String(format:"|%d,4", timeDiff1 * 60))
                
                _command.append(String(format:"|%d,7", 1800))
    
                let timeDiff2 = 60 - profile.StandingTime2
                _command.append(String(format:"|%d,4", timeDiff2 * 60))
            
            case .Custom:
                
                if profile.StandingTime2 != 0 {
                    
                    _command.append("3,7")
                    
                    let timeDiff1 = 30 - profile.StandingTime1
                    
                    _command.append(String(format:"|%d,4", timeDiff1 * 60))
                    
                    _command.append(String(format:"|%d,7", 1800))
                    
                    let timeDiff2 = 60 - profile.StandingTime2
                    _command.append(String(format:"|%d,4", timeDiff2 * 60))
                    
                } else {
                    _command.append("3,7")
                    let _timeDiff = 60 - profile.StandingTime1
                    _command.append(String(format:"|%d,4", _timeDiff * 60))
            }
            
        }
        _command.append("~")
        print("CraetProfileCommand command: ", _command)
        return _command
    }
    
    /**
     Wrap command to CRC16 checksum.

    - Parameters: [UInt8] data
    - Returns: UInt16
    */
    
    func wrapCommandWithCrc16(command: String)-> String {
        var _command = Utilities.instance.filterRawData(raw: command, char: ["~"])
        let bytearray =  _command.utf8Array
        let crc16 = Utilities.instance.convertCrc16(data: bytearray)
        _command.append(String(format:"|%d~", crc16))
        print("crc16 wrap command: ", _command)
        return _command
    }
}
