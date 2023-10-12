//
//  BoxObjects.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-27.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import EventCenter
import SwiftEventBus

// STRUCT INSTANCE OBJECTS

struct CoreObject: CoreObjectProtocol{
    var ReportedVertPos: Int
    var MainTimerCycleSeconds: Int
    var MovesreportedVertPos: Int
    var TimesreportedVertPos: Int
    var CondensedStatus: Int
    var CondensedEnable: Int
    var AppLEDIntensity: Int
    var AppReadingLightIntensity: Int
    var AppAwayAdjust: Int
    var AppSigmaSittingThreshold: Int
    var AppSigmaStandingThreshold: Int

    var AppSafetySensitivity: Int
    var LoopTimeElapsed: Int
    var LastCommandStatus: Bool
    

    var RunSwitch: Bool
    var SafetyStatus: Bool
    var AwayStatus: Bool
    var Movingdownstatus: Bool
    var Movingupstatus: Bool
    var HeightSensorStatus: Bool
    var AlternateCalibrationMode: Bool
    var AlternateAITBMode: Bool
    
    var EnableTwoStageCalibration: Bool
    var EnableHeatSenseFlipSitting: Bool
    var EnableHeatSenseFlipStanding: Bool
    var EnableMotionDetection: Bool
    var EnableTiMotionBus: Bool
    var EnableSafety: Bool
    var UserAuthenticated: Bool
    var UseInteractiveMode: Bool
    

    init() {
        self.ReportedVertPos = 0
        self.MainTimerCycleSeconds = 0
        self.MovesreportedVertPos = 0
        self.TimesreportedVertPos = 0
        self.CondensedStatus = 0
        self.CondensedEnable = 0
        self.AppLEDIntensity = 0
        self.AppReadingLightIntensity = 0
        self.AppAwayAdjust = 0
        self.AppSigmaSittingThreshold = 0
        self.AppSigmaStandingThreshold = 0

        self.AppSafetySensitivity = 0
        self.LoopTimeElapsed = 0
        self.LastCommandStatus = false
        

        self.RunSwitch = false
        self.SafetyStatus = false
        self.AwayStatus = false
        self.Movingdownstatus = false
        self.Movingupstatus = false
        self.HeightSensorStatus = false
        self.AlternateCalibrationMode = false
        self.AlternateAITBMode = false
        
        self.EnableTwoStageCalibration = false
        self.EnableHeatSenseFlipSitting = false
        self.EnableHeatSenseFlipStanding = false
        self.EnableMotionDetection = false
        self.EnableTiMotionBus = false
        self.EnableSafety = false
        self.UserAuthenticated = false
        self.UseInteractiveMode = false
    }

    
    init(raw: String, strings: [String.SubSequence],  ec: EventCenter? = nil) {
        // need to get rid of the string substring sequence casting to string
        let  _converted = strings.map { String($0) }
        let _crcString = String(_converted.item(at: _converted.count - 1) ?? "0")
        let _rawCommand = Utilities.instance.filterRawData(raw: raw, char: ["~"])
        let command = _rawCommand.split(separator: "|").dropLast().joined(separator: "|")
        let _crc16Validation =  Utilities.instance.convertCrc16(data: command.utf8Array)
 
        self.ReportedVertPos = Int(_converted.item(at: 0) ?? "0") ?? 0
        self.MainTimerCycleSeconds = Int(_converted.item(at: 1) ?? "0") ?? 0
        self.MovesreportedVertPos = Int(_converted.item(at: 2) ?? "0") ?? 0
        self.TimesreportedVertPos = Int(_converted.item(at: 3) ?? "0") ?? 0
        self.CondensedStatus = Int(_converted.item(at: 4) ?? "0") ?? 0
        self.CondensedEnable = Int(_converted.item(at: 5) ?? "0") ?? 0
        self.AppLEDIntensity = Int(_converted.item(at: 6) ?? "0") ?? 0
        self.AppReadingLightIntensity = Int(_converted.item(at: 7) ?? "0") ?? 0
        self.AppAwayAdjust = Int(_converted.item(at: 8) ?? "0") ?? 0
        self.AppSigmaSittingThreshold = Int(_converted.item(at: 9) ?? "0") ?? 0
        self.AppSigmaStandingThreshold = Int(_converted.item(at: 10) ?? "0") ?? 0
        self.AppSafetySensitivity = Int(_converted.item(at: 11) ?? "0") ?? 0
        self.LoopTimeElapsed = Int(_converted.item(at: 12) ?? "0") ?? 0
        
        self.RunSwitch = Utilities.instance.convertBitField(value: self.CondensedStatus, index: 0)
        self.SafetyStatus =  Utilities.instance.convertBitField(value: self.CondensedStatus, index: 1)
        self.AwayStatus =  Utilities.instance.convertBitField(value: self.CondensedStatus, index: 2)
        self.Movingdownstatus =  Utilities.instance.convertBitField(value: self.CondensedStatus, index: 3)
        self.Movingupstatus =  Utilities.instance.convertBitField(value: self.CondensedStatus, index: 4)
        self.HeightSensorStatus =  Utilities.instance.convertBitField(value: self.CondensedStatus, index: 5)
        self.AlternateCalibrationMode =  Utilities.instance.convertBitField(value: self.CondensedStatus, index: 6)
        self.AlternateAITBMode =  Utilities.instance.convertBitField(value: self.CondensedStatus, index: 7)
        
        self.EnableTwoStageCalibration = Utilities.instance.convertBitField(value: self.CondensedEnable, index: 0)
        self.EnableHeatSenseFlipSitting = Utilities.instance.convertBitField(value: self.CondensedEnable, index: 1)
        self.EnableHeatSenseFlipStanding = Utilities.instance.convertBitField(value: self.CondensedEnable, index: 2)
        self.EnableMotionDetection = Utilities.instance.convertBitField(value: self.CondensedEnable, index: 3)
        self.EnableTiMotionBus = Utilities.instance.convertBitField(value: self.CondensedEnable, index: 4)
        self.EnableSafety = Utilities.instance.convertBitField(value: self.CondensedEnable, index: 5)
        self.UserAuthenticated = Utilities.instance.convertBitField(value: self.CondensedEnable, index: 6)
        self.UseInteractiveMode = Utilities.instance.convertBitField(value: self.CondensedEnable, index: 7)
        
        if self.RunSwitch == false {
            Utilities.instance.saveDefaultValueForKey(value: "Manual", key: "desk_mode")
        }
        
       
        //print("CoreObject valid object:", Int(_crc16Validation) == Int(_crcString))
        
        self.LastCommandStatus = Int(_crc16Validation) == Int(_crcString)
        
        guard self.LastCommandStatus else {
            return
        }
        
        ec?.post(event: Event.Name("coreObject"), object: self)
        SwiftEventBus.post("coreDataObjectEvent", sender: self)
        SwiftEventBus.post("ReportedVertPos", sender: self)
        SwiftEventBus.post("coreObject", sender: self)
        NotificationCenter.default.post(name: NSNotification.Name("CORE_OBJECT"), object: self, userInfo: ["data":self])

    }
    
}

struct SensorObject: SensorObjectProtocol {

    let defautEventCode: String = "99"
    var YAxisAccRead: Int
    var TemperatureOutput: Int
    var PhotocellReading: Int
    var DbReading: Int
    var Sigma: Int
    var SigmaSittingThreshold: Int
    var SigmaStandingThreshold: Int
    var RowSelectorSitting: Int
    var ColumnSelectorSitting: Int
    var RowSelectorStanding: Int
    var ColumnSelectorStanding: Int
    var TiMotionErrorCodeToPrint: Int
    var ErrorID: Int
    var LastCommandStatus: Bool
    
    func getReadablesTemp() -> Int {
        return TemperatureOutput / 1000
    }

    init(raw: String, strings:[String.SubSequence], ec: EventCenter? = nil) {
        // need to get rid of the string substring sequence casting to string
        let  _converted = strings.map { String($0) }
        let _crcString = String(_converted.item(at: _converted.count - 1) ?? "0")
        let _crc16Validation =  Utilities.instance.getRawCommandCrc16(raw: raw, strings: _converted)
        
        self.YAxisAccRead = Int(_converted.item(at: 0) ?? "0") ?? 0
        self.TemperatureOutput = Int(_converted.item(at: 1) ?? "0") ?? 0
        self.PhotocellReading = Int(_converted.item(at: 2) ?? "0") ?? 0
        self.DbReading = Int(_converted.item(at: 3) ?? "0") ?? 0
        self.Sigma = Int(_converted.item(at: 4) ?? "0") ?? 0
        self.SigmaSittingThreshold = Int(_converted.item(at: 5) ?? "0") ?? 0
        self.SigmaStandingThreshold = Int(_converted.item(at: 6) ?? "0") ?? 0
        self.RowSelectorSitting = Int(_converted.item(at: 6) ?? "0") ?? 0
        self.ColumnSelectorSitting = Int(_converted.item(at: 8) ?? "0") ?? 0
        self.RowSelectorStanding = Int(_converted.item(at: 9) ?? "0") ?? 0
        self.ColumnSelectorStanding = Int(_converted.item(at: 10) ?? "0") ?? 0
        self.TiMotionErrorCodeToPrint = Int(_converted.item(at: 11) ?? "0") ?? 0
        self.ErrorID = Int(_converted.item(at: 12) ?? "0") ?? 0
        
        self.LastCommandStatus = (Int(_crc16Validation) == Int(_crcString))
        
        guard self.LastCommandStatus else {
            return
        }
        
        ec?.post(event: Event.Name("sensorObject"), object: self)
        SwiftEventBus.post("sensorIndicatorObject", sender: self)
        NotificationCenter.default.post(name: NSNotification.Name("SENSOR_OBJECT"), object: self, userInfo: ["data":self])
        
    }
}

struct HeightObject: HeightObjectProtocol {

    var ReportedMinHeight: Int
    var ReportedMaxHeight: Int
    var ReportedSittingPos: Int
    var ReportingStandingPos: Int
    var DeskOvershootValue: Int
    var DeskHeightOffset: Int
    var CommissioningFlag: Bool
    var WeAreSitting: Bool
    var PendingMovementCode: Int
    var HeartBeatOut: Bool
    var LastCommandStatus: Bool
    
    init(raw: String, strings:[String.SubSequence], ec: EventCenter? = nil) {
        // need to get rid of the string substring sequence casting to string
        let  _converted = strings.map { String($0) }
        let _crcString = String(_converted.item(at: _converted.count - 1) ?? "0")
        let _crc16Validation =  Utilities.instance.getRawCommandCrc16(raw: raw, strings: _converted)
        
        self.ReportedMinHeight = Int(_converted.item(at: 0) ?? "0") ?? 0
        self.ReportedMaxHeight  = Int(_converted.item(at: 1) ?? "0") ?? 0
        self.ReportedSittingPos  = Int(_converted.item(at: 2) ?? "0") ?? 0
        self.ReportingStandingPos  = Int(_converted.item(at: 3) ?? "0") ?? 0
        self.DeskOvershootValue = Int(_converted.item(at: 4) ?? "0") ?? 0
        self.DeskHeightOffset  = Int(_converted.item(at: 5) ?? "0") ?? 0
        self.CommissioningFlag  = Int(_converted.item(at: 6) ?? "0")?.boolValue ?? false
        self.WeAreSitting  = _converted.item(at: 7)?.boolValue ?? false
        self.PendingMovementCode  = Int(_converted.item(at: 8) ?? "0") ?? 0
        self.HeartBeatOut = _converted.item(at: 9)?.boolValue ?? false
      
        self.LastCommandStatus = (Int(_crc16Validation) == Int(_crcString))
        
        guard self.LastCommandStatus else {
            return
        }
        
        ec?.post(event: Event.Name("heightObject"), object: self)
        SwiftEventBus.post("heightSettings", sender: self)
    }
    
}

struct IdentifierObject: IdentifierObjectProtocol {
    var SerialNumber: String
    var Version: String
    var LastCommandStatus: Bool
    
    init(raw: String, strings:[String.SubSequence], ec: EventCenter? = nil) {
        // need to get rid of the string substring sequence casting to string
        let  _converted = strings.map { String($0) }
        
        let _crcString = String(_converted.item(at: _converted.count - 1) ?? "0")
        let _crc16Validation =  Utilities.instance.getRawCommandCrc16(raw: raw, strings: _converted)
        
        self.SerialNumber = _converted.item(at: 0) ?? ""
        self.Version = _converted.item(at: 1) ?? ""
        
        self.LastCommandStatus = (Int(_crc16Validation) == Int(_crcString))
        
        guard self.LastCommandStatus else {
            return
        }
        
        ec?.post(event: Event.Name("identifierObject"), object: self)
        SwiftEventBus.post("deviceBleConnected", sender: self)
        
    }
}

struct DataStringObject: DataStringObjectProtocol {
    var StatusTimerHours: Int
    var StatusTimerMinutes: Int
    var StatusTimerSeconds: Int
    var ReportingTime: Int
    var TimeReportingIndex: Int
    var SitTime: Int
    var StandTime: Int
    var AwayTime: Int
    var AutomaticTime: Int
    var SemiAutomaticTime: Int
    var ManualTime: Int
    var SafetyIncrement: Int
    var UpDownIncrement: Int
    var DetectionThresholdTally: Int
    var CondensedWifi: Int
    var LastConnStat: Int
    var LastCommandStatus: Bool
    
    init(raw: String, strings:[String.SubSequence], ec: EventCenter? = nil) {
        // need to get rid of the string substring sequence casting to string
        let _converted = strings.map { String($0) }
        
        let _crcString = String(_converted.item(at: _converted.count - 1) ?? "0")
        let _crc16Validation =  Utilities.instance.getRawCommandCrc16(raw: raw, strings: _converted)
        
        self.StatusTimerHours = Int(_converted.item(at: 0) ?? "0") ?? 0
        self.StatusTimerMinutes = Int(_converted.item(at: 1) ?? "0") ?? 0
        self.StatusTimerSeconds = Int(_converted.item(at: 2) ?? "0") ?? 0
        self.ReportingTime = Int(_converted.item(at: 3) ?? "0") ?? 0
        self.TimeReportingIndex = Int(_converted.item(at: 4) ?? "0") ?? 0
        self.SitTime = Int(_converted.item(at: 5) ?? "0") ?? 0
        self.StandTime = Int(_converted.item(at: 6) ?? "0") ?? 0
        self.AwayTime = Int(_converted.item(at: 7) ?? "0") ?? 0
        self.AutomaticTime = Int(_converted.item(at: 8) ?? "0") ?? 0
        self.SemiAutomaticTime = Int(_converted.item(at: 9) ?? "0") ?? 0
        self.ManualTime = Int(_converted.item(at: 10) ?? "0") ?? 0
        self.SafetyIncrement = Int(_converted.item(at: 11) ?? "0") ?? 0
        self.UpDownIncrement = Int(_converted.item(at: 12) ?? "0") ?? 0
        self.DetectionThresholdTally = Int(_converted.item(at: 13) ?? "0") ?? 0
        self.CondensedWifi = Int(_converted.item(at: 14) ?? "0") ?? 0
        self.LastConnStat = Int(_converted.item(at: 1) ?? "0") ?? 0
        
        self.LastCommandStatus = (Int(_crc16Validation) == Int(_crcString))
        
        guard self.LastCommandStatus else {
            return
        }
        
        ec?.post(event: Event.Name("dataStringObject"), object: self)
        
    }
}

struct VerticalMoveObject: VerticalMoveObjectProtocol {
    var ProfileCommited: Bool
    var movements: [[String : Any]] = [[String : Any]]()
    var movement0: String
    var movement1: String
    var movement2: String
    var movement3: String
    var movementRawString: String
    var LastCommandStatus: Bool
    
    init(rawString: String, strings:[String.SubSequence], ec: EventCenter? = nil, raw: String? = nil, notify: Bool) {
        // need to get rid of the string substring sequence casting to string
        let _converted = strings.map { String($0) }
        let _crcString = String(_converted.item(at: _converted.count - 1) ?? "0")
        let _crc16Validation =  Utilities.instance.getRawCommandCrc16(raw: rawString, strings: _converted)
        
        self.ProfileCommited = _converted.item(at: 0)?.boolValue ?? false
        
        //print("VM rawString: ", rawString)
        
        let _movement0 = _converted.item(at: 1) ?? ""
        let _movement1 = _converted.item(at:2) ?? ""
        let _movement2 = _converted.item(at:3) ?? ""
        let _movement3 = _converted.item(at:4) ?? ""
        
        self.movement0 = _movement0
        self.movement1 = _movement1
        self.movement2 = _movement2
        self.movement3 = _movement3
        self.movementRawString = raw ?? ""
        
        self.LastCommandStatus = (Int(_crc16Validation) == Int(_crcString))
               
       guard self.LastCommandStatus else {
           return
       }
        
        var movement  = createMovement(string: _movement0)
        let _firstMovement = movement["value"] as? Int ?? 3
        
        if _firstMovement == 3 {
            if !_movement0.isEmpty {
                var movement  = createMovement(string: _movement0)
                
                if !_movement1.isEmpty {
                    let nextMove = createMovement(string: _movement1)
                    movement["start"] = 0
                    movement["end"] = nextMove["value"]
                }
                
                self.movements.append(movement)
            }
            
            if !_movement1.isEmpty {
                var movement = createMovement(string: _movement1)
                if !_movement2.isEmpty {
                    let nextMove  = createMovement(string: _movement2)
                    movement["start"] = movement["value"]
                    movement["end"] = nextMove["value"]
                } else {
                    movement["start"] = movement["value"]
                    movement["end"] = 0
                }
                
                self.movements.append(movement)
            }
            
            if !_movement2.isEmpty {
                var movement = createMovement(string: _movement2)
                
                if !_movement3.isEmpty {
                    let nextMove  = createMovement(string: _movement3)
                    movement["start"] = movement["value"]
                    movement["end"] = nextMove["value"]
                }
                
                self.movements.append(movement)
            }
            
            if !_movement3.isEmpty {
                var movement = createMovement(string: _movement3)
                movement["start"] = movement["value"]
                movement["end"] = 0
                self.movements.append(movement)
            }
        } else {
            if !_movement0.isEmpty {
                var movement  = createMovement(string: _movement0)
                
                if !_movement1.isEmpty {
                    movement["start"] = 0
                    movement["end"] = movement["value"]
                }
                
                self.movements.append(movement)
            }
            
            if !_movement1.isEmpty {
                var movement = createMovement(string: _movement1)
                if !_movement2.isEmpty {
                    let previousMovement  = createMovement(string: _movement0)
                    movement["start"] = previousMovement["value"]
                    movement["end"] = movement["value"]
                } else {
                    movement["start"] = movement["value"]
                    movement["end"] = 0
                }
                
                self.movements.append(movement)
            }
            
            if !_movement2.isEmpty {
                var movement = createMovement(string: _movement2)
                
                if !_movement3.isEmpty {
                    let previousMovement  = createMovement(string: _movement1)
                    let nextMovement  = createMovement(string: _movement3)
                    
                    let _previous = previousMovement["value"] as? Int ?? 0
                    let _current = movement["value"] as? Int ?? 0
                    
                    if _previous == _current {
                        movement["start"] = previousMovement["value"]
                        movement["end"] = nextMovement["value"]
                    } else {
                        movement["start"] = previousMovement["value"]
                        movement["end"] = movement["value"]
                    }
                    
                }
                
                self.movements.append(movement)
            }
            
            if !_movement3.isEmpty {
                var movement = createMovement(string: _movement3)
                movement["start"] = movement["value"]
                movement["end"] = 0
                self.movements.append(movement)
            }
        }
        
        if (checkValidMovement(str: self.movement0) == false) &&
            (checkValidMovement(str: self.movement1) == false) &&
            (checkValidMovement(str: self.movement2) == false) &&
            (checkValidMovement(str: self.movement3) == false) {
            
            //if self.ProfileCommited {
                if notify {
                    ec?.post(event: Event.Name("verticalMoveObject"), object: self)
                    NotificationCenter.default.post(name: NSNotification.Name("VERTICAL_MOVEMENT"), object: self, userInfo: ["data":self])
                    SwiftEventBus.post("userVerticalMovement", sender: self)
                }
            //}
        }
    }
    
    func createMovement(string: String) -> [String: Any] {
        let _str = string.split(separator: ",")
        
        let key = Int(String(_str.item(at: 1) ?? "100")) ?? 100
        
        return (["key": String(format:"%d",key),
                 "value":Int(String(_str.item(at: 0) ?? "0")) ?? 0])
    }
    
    func checkValidMovement(str: String) -> Bool {
        
       let charset = CharacterSet(charactersIn: "S")
        if str.rangeOfCharacter(from: charset) != nil {
            return true
        }
        
        return false
    }
}

struct CountsObject: CountsObjectProtocol {
 
    
    var EEPROMReadCycleCounts_1: Int
    var EEPROMReadCycleCounts_4: Int
    var WatchdogTriggerCount: Int
    var CardResetCount: Int
    var LastCommandStatus: Bool
    
    init(raw: String, strings:[String.SubSequence], ec: EventCenter? = nil) {
        // need to get rid of the string substring sequence casting to string
        let _converted = strings.map { String($0) }
        let _crcString = String(_converted.item(at: _converted.count - 1) ?? "0")
        let _crc16Validation =  Utilities.instance.getRawCommandCrc16(raw: raw, strings: _converted)
        
        self.EEPROMReadCycleCounts_1 = Int(_converted.item(at: 0) ?? "0") ?? 0
        self.EEPROMReadCycleCounts_4 = Int(_converted.item(at: 1) ?? "0") ?? 0
        self.WatchdogTriggerCount = Int(_converted.item(at: 2) ?? "0") ?? 0
        self.CardResetCount = Int(_converted.item(at: 3) ?? "0") ?? 0
        
        
        self.LastCommandStatus = (Int(_crc16Validation) == Int(_crcString))
               
        guard self.LastCommandStatus else {
           return
        }
        
        ec?.post(event: Event.Name("countsObject"), object: self)
        
    }
    
}
