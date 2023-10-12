//
//  SPCommandsList.swift
//  PulseEcho
//
//  Created by Joseph on 2020-07-17.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation

enum CommandType {
    case ASCIIType
    case INTType
    case SHORTType
    case BYTEType
    case BYTEHEXType
}

struct SPRequestParameters {
    //static let BLEHearbeatWithName: [UInt8] = [0x10, 0x11, 0x62, 0x06, 0x62, 0x6F, 0x6E, 0x64, 0x65, 0x64, 0x9D, 0x59] //bonded //[0x07, 0x11, 0x62, 0x06, 0x42, 0x53, 0x50, 0x23, 0x6C] // [16, 17, 98, 6, 98, 111, 110, 100, 101, 100, 157, 89]
    //[7, 17, 98, 6, 66, 83 , 80, 35, 108]
    static let BLEHearbeatWithName: [UInt8] = [0x13 , 0x11, 0x62, 0x06, 0x73, 0x6D, 0x61, 0x72, 0x74, 0x70, 0x6F, 0x64, 0x73, 0x32, 0x78]
    //static let BLEHeartbeat:[UInt8] = [0x06, 0x11, 0x62, 0x00, 0x7A, 0xA7]
    static let BLEHeartbeatForeground:[UInt8] = [0x07, 0x11, 0x62, 0x00, 0x01, 0xFE, 0x4F]
    static let BLEHeartbeatBackground:[UInt8] = [0x07, 0x11, 0x62, 0x00, 0x00, 0x44, 0xE2]
    static let Report:[UInt8] = [0x06, 0x11, 0x62, 0x02, 0xB5, 0x50]
    static let Profile:[UInt8] = [0x06, 0x11, 0x62, 0x03, 0x0F, 0xFD]
    static let Information:[UInt8] = [0x06, 0x11, 0x62, 0x04, 0x5F, 0xE4]
    static let All:[UInt8] = [0x06, 0x11, 0x62, 0x05, 0xE5, 0x49]
    
    //Automatic detection
    static let LegacyDetection: [UInt8] =  [0x06, 0x11, 0x6E, 0x00, 0xAE, 0x4A]  //Revert to legacy presence detection
    static let AutomaticDetection: [UInt8] =  [0x06, 0x11, 0x6E, 0x01, 0x14, 0xE7]  //Enable automated presence detection
    static let CaptureAutomaticDetection: [UInt8] = [0x06, 0x11, 0x6E, 0x02, 0x61, 0xBD]  //Submit capture request in automated presence detection

    //AES KEY & IV
    static let GetAESKey: [UInt8] = [0x06, 0x11, 0x62, 0x06, 0x90, 0x13]
    
    //TEST REgistration ID
    static let testRegistrationID:[UInt8] = [0x08, 0x59, 0x0, 0x0, 0x0, 0x02, 0x7F, 0xAE]
    
    func SPRequestDataObject(parameters: [UInt8]) -> Data {
        let data = Data.init(parameters)
        return data
    }
}


protocol CommandBuilder {
     func GetSetHeightOffset(value: Double) -> [UInt8]
     func GetEnableMotionCommand() -> [UInt8]
     func GetDisableMotionCommand() -> [UInt8]
     func GetStopCommand() -> [UInt8]
     func GetMoveUpCommand() -> [UInt8]
     func GetMoveDownCommand() -> [UInt8]
     func GetMoveSittingCommand() -> [UInt8]
     func GetMoveStandingCommand() -> [UInt8]
     func GetSetDownCommand(value: Double) -> [UInt8]
     func GetPresenceInverted() -> [UInt8]
     func GetPresenceNoInverted() -> [UInt8]
     func GetPresenceStandInverted() -> [UInt8]
     func GetPresenceStandNoInverted() -> [UInt8]
     func GetEnableSemiAutomaticMode() -> [UInt8]
     func GetDisableSemiAutomaticMode() -> [UInt8]
     func GetResetCommissionedOn() -> [UInt8]
     func GetResetCommissionedOff() -> [UInt8]
     func GetSerialNumber(value: String) -> [UInt8]
     func GetAESKey(value: Double) -> [UInt8]
     func GetCommitAESKey() -> [UInt8]
     func GetRevertAESKey() -> [UInt8]
     func GetAcknowkedgePendingMovement() -> [UInt8]
     func GetAknowledgeSafetyCommand() -> [UInt8]
     func GetSetCrushThreshold(value: Int) -> [UInt8]
     func GetDeskTurnOn() -> [UInt8]
     func GetDeskTurnOff() -> [UInt8]
     func GetEnableSafetyCommand() -> [UInt8]
     func GetDisableSafetyCommand() -> [UInt8]
     func GetSetIndicatorLight(value: Int) -> [UInt8]
     func GetSetTopCommand(value: Double) -> [UInt8]
     func GetUserAuthenticatedOnCommand() -> [UInt8]
     func GetUserAuthenticatedOffCommand() -> [UInt8]
     func GetSetPNDThreshold(value: Int) -> [UInt8]
     func GetSetPNDStandThreshold(value: Int) -> [UInt8]
     func GetSetAwayAdjust(value: Int) -> [UInt8]
     func GetCommitProfile() -> [UInt8]
     func GetGridEyeOn() -> [UInt8]
     func GetGridEyeOff() -> [UInt8]
     func GetRowSelector(value: Double) -> [UInt8]
     func GetColumnSelector(value: Double) -> [UInt8]
     func GetResumeOutputCommand() -> [UInt8]
     func GetStopOutputCommand() -> [UInt8]
     func GetClearWatchdogAlarm() -> [UInt8]
     func BLEHeartBeat() -> [UInt8]
     func EnableHeartBeat() -> [UInt8]
     func DisableHeartBeat() -> [UInt8]
     func GenerateVerticalProfile(movements: [[String: Any]]) -> [UInt8]
     func CreateVerticalProfile(settings: ProfileSettings) -> [UInt8]
     func BLEHeartBeatIn(value: String) -> [UInt8]
}

public struct PulseCommands: CommandBuilder {
    
    let pulseCommand = GetPulseCommand()
    
    func GetSetHeightOffset(value: Double) -> [UInt8] {
        let _value = String(format:"%.0f", value)
        let _command =  String(format:"a%@",_value)
        
        let builder = pulseCommand.buildPulseCommand(command: _command, type: .SHORTType)
        return builder
    }
    
    func GetEnableMotionCommand() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "B1", type: .BYTEType)
        return builder
    }
    
    func testIntType() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "20", type: .INTType)
        return builder
    }
    
    func GetDisableMotionCommand() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "B0", type: .BYTEType)
        return builder
    }
    
    func GetStopCommand() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "C1", type: .ASCIIType)
        return builder
    }
    
    func GetMoveUpCommand() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "C6", type: .ASCIIType)
        return builder
    }
    
    func GetMoveDownCommand() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "C5", type: .ASCIIType)
        return builder
    }
    
    func GetMoveSittingCommand() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "Cd", type: .ASCIIType)
        return builder

    }
    
    func GetMoveStandingCommand() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "Cu", type: .ASCIIType)
        return builder

    }
    
    func GetSetDownCommand(value: Double) -> [UInt8] {
        let _value = String(format:"%.0f", value)
        let _command =  String(format:"D%@",_value)
        let builder = pulseCommand.buildPulseCommand(command: _command, type: .SHORTType)
        return builder

    }
    
    func GetPresenceInverted() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "E1", type: .BYTEType)
        return builder

    }
    
    func GetPresenceNoInverted() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "E0", type: .BYTEType)
        return builder

    }
    
    func GetPresenceStandInverted() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "F1", type: .BYTEType)
        return builder

    }
    
    func GetPresenceStandNoInverted() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "F0", type: .BYTEType)
        return builder

    }
    func GetEnableSemiAutomaticMode() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "G1", type: .BYTEType)
        return builder

    }
    
    func GetDisableSemiAutomaticMode() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "G0", type: .BYTEType)
        return builder

    }
    
    func GetResetCommissionedOn() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "H1", type: .BYTEType)
        return builder

    }
    
    func GetResetCommissionedOff() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "H0", type: .BYTEType)
        return builder

    }
    
    func GetSerialNumber(value: String) -> [UInt8] {
        let _command =  String(format: "I%@",value)
        let builder = pulseCommand.buildPulseCommand(command: _command, type: .INTType)
        return builder

    }
    
    func GetAESKey(value: Double) -> [UInt8] {
        let _value = String(format:"%.0f", value)
        let _command = String(format:"k%@",_value)
        let builder = pulseCommand.buildPulseCommand(command: _command, type: .BYTEType)
        return builder

    }
    
    func GetCommitAESKey() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "K1", type: .BYTEType)
        return builder
    }
    
    func GetRevertAESKey() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "K0", type: .BYTEType)
        return builder

    }
    
    func GetAcknowkedgePendingMovement() -> [UInt8] {
        //return "l~"
        let builder = pulseCommand.buildPulseCommand(command: "l", type: .BYTEType)
        return builder

    }
    
    func GetAknowledgeSafetyCommand() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "L", type: .BYTEType)
        return builder

    }
    
    func GetSetCrushThreshold(value: Int) -> [UInt8] {
        let _command =  String(format:"m%d",value)
        let builder = pulseCommand.buildPulseCommand(command: _command, type: .BYTEType)
        return builder
    }
    
    func GetDeskTurnOn() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "o1", type: .BYTEType)
        return builder
    }
    
    func GetDeskTurnOff() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "o0", type: .BYTEType)
        return builder
    }
    
    func GetEnableSafetyCommand() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "S1", type: .BYTEType)
        return builder
    }
    
    func GetDisableSafetyCommand() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "S0", type: .BYTEType)
        return builder
    }
    
    func GetSetIndicatorLight(value: Int) -> [UInt8] {
        let _commnad =  String(format:"t%d", value)
        let builder = pulseCommand.buildPulseCommand(command: _commnad, type: .BYTEType)
        return builder
    }
    
    func GetSetTopCommand(value: Double) -> [UInt8] {
        let _value = String(format:"%.0f", value)
        let _command =  String(format:"U%@",_value)
        let builder = pulseCommand.buildPulseCommand(command: _command, type: .SHORTType)
        return builder
    }
    
    func GetUserAuthenticatedOnCommand() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "W1", type: .BYTEType)
        return builder
    }
    
    func GetUserAuthenticatedOffCommand() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "W0", type: .BYTEType)
        return builder
    }
    
    func GetSetPNDThreshold(value: Int) -> [UInt8] {
        let _command =  String(format:"x%d",value)
        let builder = pulseCommand.buildPulseCommand(command: _command, type: .BYTEType)
        return builder
    }
    
    func GetSetPNDStandThreshold(value: Int) -> [UInt8] {
        let _command = String(format:"v%d",value)
        let builder = pulseCommand.buildPulseCommand(command: _command, type: .BYTEType)
        return builder
    }
    
    func GetSetAwayAdjust(value: Int) -> [UInt8] {
        let _command =  String(format:"T%d",value)
        let builder = pulseCommand.buildPulseCommand(command: _command, type: .BYTEType)
        return builder
    }
    
    func GetCommitProfile() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "X", type: .BYTEType)
        return builder
    }
    
    func GetGridEyeOn() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "V1", type: .BYTEType)
        return builder
    }
    
    func GetGridEyeOff() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "V0", type: .BYTEType)
        return builder
    }
    
    func GetRowSelector(value: Double) -> [UInt8] {
        let _value = String(format:"%.0f", value)
        let _command =  String(format:"h%@",_value)
        let builder = pulseCommand.buildPulseCommand(command: _command, type: .BYTEType)
        return builder
    }
    
    func GetColumnSelector(value: Double) -> [UInt8] {
        let _value = String(format:"%.0f", value)
        let _command =  String(format:"i%@",_value)
        let builder = pulseCommand.buildPulseCommand(command: _command, type: .BYTEType)
        return builder
    }
    
    func GetResumeOutputCommand() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "Z0", type: .BYTEType)
        return builder
    }
    
    func GetStopOutputCommand() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "Z1", type: .BYTEType)
        return builder
    }
    
    func GetClearWatchdogAlarm() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "y", type: .BYTEType)
        return builder
    }
    
    func BLEHeartBeat() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "b0", type: .BYTEType)
        return builder
    }
    
    func BLEHeartBeatIn(value: String) -> [UInt8] {
        let _command =  String(format:"b6%@",value)
        let builder = pulseCommand.buildPulseCommand(command: _command, type: .BYTEHEXType)
        return builder
    }
    
    func EnableHeartBeat() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "z0", type: .BYTEType)
        return builder
    }
    
    func DisableHeartBeat() -> [UInt8] {
        let builder = pulseCommand.buildPulseCommand(command: "z1", type: .BYTEType)
        return builder
    }
    
    func GenerateVerticalProfile(movements: [[String: Any]]) -> [UInt8] {
        let builder = pulseCommand.buildPulseVerticalProfile(newMovements: movements)
        return builder
    }
    
    func CreateVerticalProfile(settings: ProfileSettings) -> [UInt8] {
        let builder = pulseCommand.buildPulseUserProfile(profile: settings)
        return builder
    }
}

protocol CommandAdapterProtocol {
    func buildPulseCommand(command: String, type: CommandType) -> [UInt8]
    func buildPulseVerticalProfile(newMovements: [[String: Any]])  -> [UInt8]
}

struct GetPulseCommand: CommandAdapterProtocol {
    func buildPulseCommand(command: String, type: CommandType) -> [UInt8] {
        
        let packetNumber = 1
        let packetTotal = 1
        
        let header: UInt8 = (String(Array(command)[0]).utf8Array)[0]
        var payload = [UInt8]()
        
        print("command strip: ", String(Array(command)[0]))
        print("header: ", header)
        
        if command.count > 1 {
            let _command = String(command.subString(from: 1, to: command.count - 1))
            print("_command : \(_command)")
                switch(type) {
                    case .ASCIIType:
                        payload = _command.utf8Array
                    case .INTType:
                        payload = _command.utf8Array
                    case .SHORTType:
                        var value = UInt16(bigEndian: UInt16.init(_command) ?? 0)
                        let array = withUnsafeBytes(of: &value) { Array($0) }
                        payload = array
                    case .BYTEType:
                        payload.append(UInt8(_command) ?? 0)
                        //payload = _command.utf8Array
                    case .BYTEHEXType:
                        payload.append(UInt8(_command) ?? 0)
                    
                }
        }

        print("payload is: ", payload)
        
        let fourBits = getCombined4Bits(value1: packetNumber, value2: packetTotal)
        var packet: [UInt8] = [UInt8(fourBits), header]
        
        if command.count > 1 {
            packet.append(contentsOf: payload)
        }
       
        let packetLength = 3 + packet.count
        packet.insert(UInt8(packetLength), at: 0)
        
        print("CRC VALUE: \(Utilities.instance.convertCrc16(data: packet))")
        
        let crc16 = Utilities.instance.convertCrc16(data: packet).bigEndian.data.array
        packet.append(contentsOf: crc16)
        
        print("PACKET VALUE: ", packet)
        
        return packet
    }
    
    func buildPulseVerticalProfile(newMovements: [[String: Any]])  -> [UInt8] {
        
        let packetNumber = 1
        let packetTotal = 1
        
        //print("newMovements: ", newMovements)
        
        let header: UInt8 = ("P".utf8Array)[0]
        var payload = [UInt8]()
        
        for (index, movement) in newMovements.enumerated() {
            let _value = movement["value"]
            let _movement_type = movement["key"] as! String
            
            //movement type
            payload.append(UInt8(_movement_type) ?? 100)
            
            if let moveData = _value {
                let value = moveData as? Int ?? 0
                
                if value == 3 || value == 0 {
                    payload.append(0)
                    payload.append(UInt8(3))
                } else {
                    var data = UInt16(bigEndian: UInt16.init(value) )
                    let array = withUnsafeBytes(of: &data) { Array($0) }
                    payload.append(contentsOf: array)
                }
            } else {
                print("value not expected")
            }
        }
        
        //print("profile payload is: ", payload)
        
        let fourBits = getCombined4Bits(value1: packetNumber, value2: packetTotal)
        var packet: [UInt8] = [UInt8(fourBits), header]
       
        packet.append(contentsOf: payload)
        
        let packetLength = 3 + packet.count
        packet.insert(UInt8(packetLength), at: 0)
        
        let crc16 = Utilities.instance.convertCrc16(data: packet).bigEndian.data.array
        packet.append(contentsOf: crc16)
        
        print("buildPulseVerticalProfile packet: ", packet)
        
        return packet
    }
    
    func buildPulseUserProfile(profile: ProfileSettings) ->  [UInt8] {

        let packetNumber = 1
        let packetTotal = 1
        
        let header: UInt8 = ("P".utf8Array)[0]
        var payload = [UInt8]()
        
        let _profileType: ProfileSettingsType = ProfileSettingsType(rawValue: profile.ProfileSettingType) ?? ProfileSettingsType.Active

        switch _profileType {
        case .Active, .ModeratelyActive:
                payload.append(UInt8(7))
                payload.append(0)
                payload.append(UInt8(3))
                
            let timeDiff = 60 - profile.StandingTime1
                var data = UInt16(bigEndian: UInt16.init(timeDiff * 60) )
                let array = withUnsafeBytes(of: &data) { Array($0) }
                payload.append(UInt8(4))
                payload.append(contentsOf: array)
                
            case .VeryActive:
                payload.append(UInt8(7))
                payload.append(0)
                payload.append(UInt8(3))
                
                let stand1 = 30 - profile.StandingTime1
                var data1 = UInt16(bigEndian: UInt16.init(stand1 * 60) )
                let array1 = withUnsafeBytes(of: &data1) { Array($0) }
                payload.append(UInt8(4))
                payload.append(contentsOf: array1)
                
                var data2 = UInt16(bigEndian: UInt16.init(1800) )
                print("data2: ", data2)
                let array2 = withUnsafeBytes(of: &data2) { Array($0) }
                print("array2: ", array2)
                payload.append(UInt8(7))
                payload.append(contentsOf: array2)
                
                let stand2 = 60 - profile.StandingTime2
                var data3 = UInt16(bigEndian: UInt16.init(stand2 * 60) )
                let array3 = withUnsafeBytes(of: &data3) { Array($0) }
                payload.append(UInt8(4))
                payload.append(contentsOf: array3)
            
            case .Custom:
                
                if profile.StandingTime2 != 0 {
                    payload.append(UInt8(7))
                    payload.append(0)
                    payload.append(UInt8(3))
                    
                    let stand1 = 30 - profile.StandingTime1
                    var data1 = UInt16(bigEndian: UInt16.init(stand1 * 60) )
                    let array1 = withUnsafeBytes(of: &data1) { Array($0) }
                    payload.append(UInt8(4))
                    payload.append(contentsOf: array1)
                    
                    var data2 = UInt16(bigEndian: UInt16.init(1800) )
                    let array2 = withUnsafeBytes(of: &data2) { Array($0) }
                    payload.append(UInt8(7))
                    payload.append(contentsOf: array2)
                    
                    let stand2 = 60 - profile.StandingTime2
                    var data3 = UInt16(bigEndian: UInt16.init(stand2 * 60) )
                    let array3 = withUnsafeBytes(of: &data3) { Array($0) }
                    payload.append(UInt8(4))
                    payload.append(contentsOf: array3)

                } else {
                    payload.append(UInt8(7))
                    payload.append(0)
                    payload.append(UInt8(3))
                    
                    let timeDiff = 60 - profile.StandingTime1
                    var data = UInt16(bigEndian: UInt16.init(timeDiff * 60) )
                    let array = withUnsafeBytes(of: &data) { Array($0) }
                    payload.append(UInt8(4))
                    payload.append(contentsOf: array)
                    
                }
            
        }
        
        
        let fourBits = getCombined4Bits(value1: packetNumber, value2: packetTotal)
        var packet: [UInt8] = [UInt8(fourBits), header]
       
        packet.append(contentsOf: payload)
        
        let packetLength = 3 + packet.count
        packet.insert(UInt8(packetLength), at: 0)
        
        let crc16 = Utilities.instance.convertCrc16(data: packet).bigEndian.data.array
        packet.append(contentsOf: crc16)
        
        print("buildPulseUserProfile profile: ", packet)
        
        return packet
    }
    
    func getCombined4Bits(value1: Int, value2: Int) -> UInt8 {
        let padValue1 = get4BitString(val: value1)
        let padValue2 = get4BitString(val: value2)
        let padValue = padValue1 + padValue2
        return UInt8(UInt(padValue.binToDec()))
        //return hexaByte(padValue.binToDec())
    }
    
    func get4BitString(val: Int) -> String {
        let _stc = String(format: "%d", val)
        return _stc.pad(minLength: 4)
    }
    
    func hexaByte(_ num: Int) -> UInt8 {
        let _num = String(format: "%d", num)
        return UInt8(_num, radix: 16) ?? 0
    }
    
    func arrayHexBytes(_ hexString: String) -> [UInt8] {
        var arrBytes = [UInt8]()
        
        for char in hexString {
            let char: Character = Character(extendedGraphemeClusterLiteral: char)
            if let intValue = char.wholeNumberValue {
                arrBytes.append(UInt8(intValue))
            } else {
                let hexString = "\(char)".data(using: .ascii)!.hexString
                arrBytes.append(UInt8(hexString) ?? 0)
            }
        }
        
        return arrBytes
    }
    
    func arrayDec(arr: [UInt8]) -> [UInt8] {
        var arrBytes = [UInt8]()
        arrBytes = arr.map { UInt8(hexaByte(Int($0)))}
        
        return arrBytes
    }
    
}
