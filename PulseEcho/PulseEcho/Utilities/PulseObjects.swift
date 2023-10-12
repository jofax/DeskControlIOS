//
//  PulseObjects.swift
//  PulseEcho
//
//  Created by Joseph on 2020-08-18.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import Foundation
import CommonCrypto

struct SPCoreObject: PulseCore {
    var Length: Int = 0
    var Command: Int = 0
    var ReportedVerPosHB: UInt8 = 0
    var ReportedVerPosLB: UInt8  = 0
    var MainTimerCycleSecondsHB: UInt8 = 0
    var MainTimerCycleSecondsLB: UInt8 = 0
    var MovesreportedVertPos: UInt8 = 0
    var CondensedStatusOne: Int = 0
    var CondensedStatusTwo: Int = 0
    var CondensedStatusThree: Int = 0
    var CondensedEnableOne: Int = 0
    var CondensedEnableTwo: Int = 0
    var WifiSyncStatus: UInt8 = 0
    var PendingMoveAndSlider: UInt8 = 0
    var SliderComboTwo: UInt8 = 0
    var SliderComboThree: UInt8 = 0
    var CRCHighByte: UInt8 = 0
    var CRCLowByte: UInt8 = 0
    
    var ReportedVertPos: Int = 0
    var MainTimerCycleSeconds: Int = 0
    var TimesreportedVertPos: Int = 0
    var NextMove: Int = 0
    var WifiStatus: Int = 0
    var AdapterError: Int = 0
    var PendingMove: Int = 0
    var LEDSlider: Int = 0
    var SitPresence: Int = 0
    var StandPresence: Int = 0
    var AwaySlider: Int = 0
    var SafetySlider: Int = 0

    
    var RunSwitch: Bool = false
    var SafetyStatus: Bool = false
    var AwayStatus: Bool = false
    var Movingdownstatus: Bool = false
    var Movingupstatus: Bool = false
    var HeightSensorStatus: Bool = false
    var AlternateCalibrationMode: Bool = false
    var AlternateAITBMode: Bool = false
    var NewInfoData: Bool = false
    var NewProfileData: Bool = false
    var EnableTwoStageCalibration: Bool = false
    var EnableHeatSenseFlipSitting: Bool = false
    var EnableHeatSenseFlipStanding: Bool = false
    var EnableMotionDetection: Bool = false
    var EnableTiMotionBus: Bool = false
    var EnableSafety: Bool = false
    var UserAuthenticated: Bool = false
    var UseInteractiveMode: Bool = false
    var AppRxFailFlag: Bool = false
    var WifiTxpushFailure: Bool = false
    var WeAreSitting: Bool = false
    var ObstructionStatus: Bool = false
    var CommissioningFlag: Bool = false
    var HeartBeatOut: Bool = false
    var LastWifiPushFailed: Bool = false
    var LastCommandFailed: Bool = false
    var WifiPushIncoming: Bool = false
    var DeskAtSittingPosition: Bool = false
    
    var ObstructionDetection: Bool = false
    var WifiSystem: Bool = false
    
    var AutoPresenceDetection:Bool = false
    var NeedPresenceCapture:Bool = false
    var StandHeightAdjusted: Bool = false
    var SitHeightAdjusted: Bool = false
    var DeskCurrentlyBooked: Bool = false
    var DeskUpcomingBooking: Bool = false
    var DeskEnabledStatus: Bool = false
    
    init(data: [UInt8]) {
        guard data.count > 0 else {
            return
        }
        
        self.Length = Int(data.item(at: 0) ?? 0)
        self.Command = Int(data.item(at: 1) ?? 0)
        self.ReportedVerPosHB = data.item(at: 2) ?? 0
        self.ReportedVerPosLB = data.item(at: 3) ?? 0
        self.MainTimerCycleSecondsHB = data.item(at: 4) ?? 0
        self.MainTimerCycleSecondsLB = data.item(at: 5) ?? 0
        self.MovesreportedVertPos = data.item(at: 6) ?? 0
        self.CondensedStatusOne = Int(data.item(at: 7) ?? 0)
        self.CondensedStatusTwo  = Int(data.item(at: 8) ?? 0)
        self.CondensedEnableOne  = Int(data.item(at: 9) ?? 0)
        self.CondensedEnableTwo  = Int(data.item(at: 10) ?? 0)
        self.WifiSyncStatus = data.item(at: 11) ?? 0
        self.PendingMoveAndSlider = data.item(at: 12) ?? 0
        self.SliderComboTwo = data.item(at: 13) ?? 0
        self.SliderComboThree = data.item(at: 14) ?? 0
        self.CondensedStatusThree = Int(data.item(at: 15) ?? 0)
        self.CRCHighByte = data.item(at: 18) ?? 0
        self.CRCLowByte = data.item(at: 19) ?? 0
        
        self.ReportedVertPos = 0
        self.MainTimerCycleSeconds = 0
        self.TimesreportedVertPos = 0
        
        let _verticalPosition = [self.ReportedVerPosHB, self.ReportedVerPosLB]
        let _verticalPositionData = Data.init(_verticalPosition)
        
        let _mainTimerCycle = [self.MainTimerCycleSecondsHB, self.MainTimerCycleSecondsLB]
        let _mainTimerCycleData = Data.init(_mainTimerCycle)
        
        
        self.ReportedVertPos = Int(UInt16(bigEndian: _verticalPositionData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        self.MainTimerCycleSeconds = Int(UInt16(bigEndian: _mainTimerCycleData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let moveCode = self.MovesreportedVertPos & 0x0F
        let moveType = (self.MovesreportedVertPos>>4)&0x0F
        
        self.TimesreportedVertPos = Utilities.instance.getTimeCodes(code: Int(moveCode))
        self.NextMove  = Int(moveType)

        //print("moveCode: ", moveCode)
        //print("moveType: ", moveType)

        self.WifiStatus  = Int((self.WifiSyncStatus<<4)&0x0F)
        self.AdapterError  = Int((self.WifiSyncStatus>>4)&0x0F)
        self.PendingMove  = Int((self.PendingMoveAndSlider>>4)&0x0F)
        self.LEDSlider  = Int((self.PendingMoveAndSlider & 0x0F))
        self.SitPresence  = Int((self.SliderComboTwo>>4)&0x0F)
        self.StandPresence  = Int(self.SliderComboTwo & 0x0F)
        self.AwaySlider  = Int((self.SliderComboThree>>4)&0x0F)
        self.SafetySlider  = Int(self.SliderComboThree & 0x0F)
        
//        print("SliderComboThree : ", SliderComboThree)
//        print("AwaySlider : ", AwaySlider)
//        print("SafetySlider : ", SafetySlider)
        
//        print("WifiStatus: ", WifiStatus)
//        print("AdapterError: ", AdapterError)
//
//        print("PendingMove: ", PendingMove)
//        print("LEDSlider: ", LEDSlider)
//
//        print("SliderComboTwo: ", SliderComboTwo)
//        print("SitPresence: ", SitPresence)
//        print("StandPresence: ", StandPresence)
//
//        print("AwaySlider: ", AwaySlider)
//        print("SafetySlider: ", SafetySlider)
        
        self.RunSwitch = Utilities.instance.convertBitField2(value: self.CondensedStatusOne, index: 0)
        self.SafetyStatus =  Utilities.instance.convertBitField2(value: self.CondensedStatusOne, index: 1)
        self.AwayStatus =  Utilities.instance.convertBitField2(value: self.CondensedStatusOne, index: 2)
        self.Movingupstatus =  Utilities.instance.convertBitField2(value: self.CondensedStatusOne, index: 3)
        self.Movingdownstatus =  Utilities.instance.convertBitField2(value: self.CondensedStatusOne, index: 4)
        self.HeightSensorStatus =  Utilities.instance.convertBitField2(value: self.CondensedStatusOne, index: 5)
        self.AlternateCalibrationMode =  Utilities.instance.convertBitField2(value: self.CondensedStatusOne, index: 6)
        self.AlternateAITBMode =  Utilities.instance.convertBitField2(value: self.CondensedStatusOne, index: 7)
        
        self.DeskEnabledStatus = Utilities.instance.convertBitField(value: self.CondensedStatusThree, index: 0)
        self.DeskCurrentlyBooked = Utilities.instance.convertBitField(value: self.CondensedStatusThree, index: 1)
        self.DeskUpcomingBooking = Utilities.instance.convertBitField(value: self.CondensedStatusThree, index: 2)
        
        self.StandHeightAdjusted = Utilities.instance.convertBitField(value: self.CondensedStatusThree, index: 3)
        self.AutoPresenceDetection = Utilities.instance.convertBitField(value: self.CondensedStatusThree, index: 4)
        self.NeedPresenceCapture = Utilities.instance.convertBitField(value: self.CondensedStatusThree, index: 5)
        self.NewInfoData = Utilities.instance.convertBitField(value: self.CondensedStatusThree, index: 6)
        self.NewProfileData = Utilities.instance.convertBitField(value: self.CondensedStatusThree, index: 7)
        
        self.EnableTwoStageCalibration = Utilities.instance.convertBitField(value: self.CondensedEnableOne, index: 0)
        self.EnableHeatSenseFlipSitting = Utilities.instance.convertBitField(value: self.CondensedEnableOne, index: 1)
        self.EnableHeatSenseFlipStanding = Utilities.instance.convertBitField(value: self.CondensedEnableOne, index: 2)
        self.EnableMotionDetection = Utilities.instance.convertBitField(value: self.CondensedEnableOne, index: 3)
        self.EnableTiMotionBus = Utilities.instance.convertBitField(value: self.CondensedEnableOne, index: 4)
        self.EnableSafety = Utilities.instance.convertBitField(value: self.CondensedEnableOne, index: 5)
        self.UserAuthenticated = Utilities.instance.convertBitField(value: self.CondensedEnableOne, index: 6)
        self.UseInteractiveMode = Utilities.instance.convertBitField(value: self.CondensedEnableOne, index: 7)
        
        self.SitHeightAdjusted = Utilities.instance.convertBitField(value: self.CondensedStatusTwo, index: 0)
        self.LastWifiPushFailed = Utilities.instance.convertBitField(value: self.CondensedStatusTwo, index: 1)
        self.LastCommandFailed = Utilities.instance.convertBitField(value: self.CondensedStatusTwo, index: 2)
        self.WifiPushIncoming = Utilities.instance.convertBitField(value: self.CondensedStatusTwo, index: 3)
        self.DeskAtSittingPosition = Utilities.instance.convertBitField(value: self.CondensedStatusTwo, index: 4)
        self.ObstructionStatus = Utilities.instance.convertBitField(value: self.CondensedStatusTwo, index: 5)
        self.CommissioningFlag = Utilities.instance.convertBitField(value: self.CondensedStatusTwo, index: 6)
        self.HeartBeatOut = Utilities.instance.convertBitField(value: self.CondensedStatusTwo, index: 7)
        
        Utilities.instance.isCalibrationOn = AlternateCalibrationMode
        
        if AlternateCalibrationMode {
            //Utilities.instance.appDelegate.dataTimer.resume()
        }
        
        //print("CondensedStatusOne: ", CondensedStatusOne)
        //print("AlternateCalibrationMode: ", AlternateCalibrationMode)
        //print("EnableSafety: ", EnableSafety)
        //print("Movingupstatus: ", Movingupstatus)
        //print("Movingdownstatus: ", Movingdownstatus)
        //print("CondensedEnableTwo: ", CondensedEnableTwo)
        //print("HeartBeatOut: ", Utilities.instance.convertBitField(value: self.CondensedStatusTwo, index: 7))
        let crc16 = Utilities.instance.calculateCrc16From2bytes(hb: self.CRCHighByte, lb: self.CRCLowByte)
    }
    
}

struct SPVerticalProfile: PulseVerticalProfileProtocol {
    var Length: Int = 0
    var Command: Int = 0
    var MoveOneCombo: UInt8 = 0
    var MoveTwoCombo: UInt8 = 0
    var MoveThreeCombo: UInt8 = 0
    var MoveFourCombo: UInt8 = 0
    var SittingPosHB: UInt8 = 0
    var SittingPosLB: UInt8 = 0
    var StandingHB: UInt8 = 0
    var StandingLB: UInt8 = 0
    var MinHeightHB: UInt8 = 0
    var MinHeightLB: UInt8 = 0
    var MaxHeightHB: UInt8 = 0
    var MaxHeightLB: UInt8 = 0
    var DeskHeightOffset: Int = 0
    var DeskOverShoot: Int = 0
    var CRCHighByte: UInt8 = 0
    var CRCLowByte: UInt8 = 0
    
    var movements: [[String : Any]] = []
    var movement0: String = ""
    var movement1: String = ""
    var movement2: String = ""
    var movement3: String = ""
    var movementRawString: String = ""
    
    var timeOne: Int = 0
    var timeTwo: Int = 0
    var timeThree: Int = 0
    var timeFour: Int = 0
    var moveOne: Int  = 0
    var moveTwo: Int = 0
    var moveThree: Int = 0
    var moveFour: Int = 0
    
    var SittingPos: Int = 0
    var StandingPos: Int = 0
    var MinHeight: Int = 0
    var MaxHeight: Int = 0
    
    init(data: [UInt8], rawString: String, notify: Bool) {
     guard data.count > 0 else {
                return
            }
        
            self.Length = Int(data.item(at: 0) ?? 0)
            self.Command = Int(data.item(at: 1) ?? 0)
            
            self.MoveOneCombo = data.item(at: 2) ?? 0
            self.MoveTwoCombo = data.item(at: 3) ?? 0
            self.MoveThreeCombo = data.item(at: 4) ?? 0
            self.MoveFourCombo = data.item(at: 5) ?? 0
        
            //let moveCode = (self.MovesreportedVertPos<<4)&0x0F
            //let moveType = (self.MovesreportedVertPos>>4)&0x0F
        
            //let moveCode = (bitVal>>4)&0x0F
            //let moveTime = bitVal & 0x0F
        
            self.moveOne = Int((self.MoveOneCombo>>4)&0x0F)
            self.timeOne = Int(self.MoveOneCombo & 0x0F)
            self.moveTwo = Int((self.MoveTwoCombo>>4)&0x0F)
            self.timeTwo = Int(self.MoveTwoCombo & 0x0F)
            self.moveThree = Int((self.MoveThreeCombo>>4)&0x0F)
            self.timeThree = Int(self.MoveThreeCombo & 0x0F)
            self.moveFour = Int((self.MoveFourCombo>>4)&0x0F)
            self.timeFour = Int(self.MoveFourCombo & 0x0F)
        
            self.SittingPosHB  = data.item(at: 6) ?? 0
            self.SittingPosLB  = data.item(at: 7) ?? 0
            self.StandingHB  = data.item(at: 8) ?? 0
            self.StandingLB  = data.item(at: 9) ?? 0
            self.MinHeightHB = data.item(at: 10) ?? 0
            self.MinHeightLB  = data.item(at: 11) ?? 0
            self.MaxHeightHB  = data.item(at: 12) ?? 0
            self.MaxHeightLB  = data.item(at: 13) ?? 0
            self.DeskHeightOffset  = Int(data.item(at: 14) ?? 0)
            self.DeskOverShoot  = Int(data.item(at: 15) ?? 0)
        
            self.CRCHighByte = data.item(at: 18) ?? 0
            self.CRCLowByte = data.item(at: 19) ?? 0
        
            let _sittingPos = [self.SittingPosHB, self.SittingPosLB]
            let sitData = Data.init(_sittingPos)
            self.SittingPos = Int(UInt16(bigEndian: sitData.withUnsafeBytes { $0.load(as: UInt16.self) }))
            
            let _standingPos = [self.StandingHB, self.StandingLB]
            let standData = Data.init(_standingPos)
            self.StandingPos = Int(UInt16(bigEndian: standData.withUnsafeBytes { $0.load(as: UInt16.self) }))
            
            let crc16 = Utilities.instance.calculateCrc16From2bytes(hb: self.CRCHighByte, lb: self.CRCLowByte)
            
            let _movement0 = (self.timeOne != 15 || self.timeOne != 14) ? String(format: "%d,%d",Utilities.instance.getTimeCodes(code: Int(timeOne)),self.moveOne) : ""
            let _movement1 = (self.timeTwo != 15 || self.timeTwo != 14) ? String(format: "%d,%d",Utilities.instance.getTimeCodes(code: Int(timeTwo)),self.moveTwo) : ""
            let _movement2 = (self.timeThree != 15 || self.timeThree != 14) ? String(format: "%d,%d",Utilities.instance.getTimeCodes(code: Int(timeThree)),self.moveThree) : ""
            let _movement3 = (self.timeFour != 15 || self.timeFour != 14) ?  String(format: "%d,%d",Utilities.instance.getTimeCodes(code: Int(timeFour)),self.moveFour) : ""
        
            self.movement0 = _movement0
            self.movement1 = _movement1
            self.movement2 = _movement2
            self.movement3 = _movement3
            self.movementRawString = rawString

            
            let movement  = createMovement(string: _movement0)
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

struct SPIdentifier: PulseIdentifierProtocol {
    var Length: Int = 0
    var Command: Int = 0
    var DeskIDMSB: UInt8 = 0
    var DeskIDByte3: UInt8 = 0
    var DeskIDByte2: UInt8 = 0
    var DeskIDLSB: UInt8 = 0
    var VersionNumberMSB: UInt8 = 0
    var VersionNumberByte: UInt8 = 0
    var VersionNumberByte2: UInt8 = 0
    var VersionNumberLSB: UInt8 = 0
    var VersionBoardType: UInt8 = 0
    var UpdateDownCount2: UInt8 = 0
    var UpdateDownCount1: UInt8 = 0
    var UpdateDownCount0: UInt8 = 0
    var RegistrationID3: UInt8 = 0
    var RegistrationID2: UInt8 = 0
    var RegistrationID1: UInt8 = 0
    var RegistrationID0: UInt8 = 0
    var CRCHighByte: UInt8 = 0
    var CRCLowByte: UInt8 = 0
    
    var SerialNumber: String = ""
    var Version: String = ""
    var UpDownCount: String = ""
    var RegistrationID: String = ""
    var DeskID: UInt32 = 0
    
    init(data: [UInt8]) {
        guard data.count > 0 else {
         return
        }
        
        print("SPIdentifier: ", data)
        
        self.Length = Int(data.item(at: 0) ?? 0)
        self.Command = Int(data.item(at: 1) ?? 0)
        self.DeskIDMSB = data.item(at: 2) ?? 0
        self.DeskIDByte3 = data.item(at: 3) ?? 0
        self.DeskIDByte2 = data.item(at: 4) ?? 0
        self.DeskIDLSB = data.item(at: 5) ?? 0
        self.VersionNumberMSB = data.item(at: 6) ?? 0
        self.VersionNumberByte = data.item(at: 7) ?? 0
        self.VersionNumberByte2 = data.item(at: 8) ?? 0
        self.VersionNumberLSB = data.item(at: 9) ?? 0
        self.VersionBoardType = data.item(at: 10) ?? 0
        self.UpdateDownCount2 = data.item(at: 11) ?? 0
        self.UpdateDownCount1 = data.item(at: 12) ?? 0
        self.UpdateDownCount0 = data.item(at: 13) ?? 0
        self.RegistrationID3 = data.item(at: 14) ?? 0
        self.RegistrationID2 = data.item(at: 15) ?? 0
        self.RegistrationID1 = data.item(at: 16) ?? 0
        self.RegistrationID0 = data.item(at: 17) ?? 0
        
        self.CRCHighByte = data.item(at: 18) ?? 0
        self.CRCLowByte = data.item(at: 19) ?? 0
        
        let _deskId = [self.DeskIDMSB, self.DeskIDByte3, self.DeskIDByte2, DeskIDLSB]
        let deskData = Data.init(_deskId)
        DeskID = UInt32(bigEndian: deskData.withUnsafeBytes { $0.load(as: UInt32.self) })
        let _serialNumber = Int(UInt32(bigEndian: deskData.withUnsafeBytes { $0.load(as: UInt32.self) }))
        
        let _versionNo = [self.VersionNumberMSB, self.VersionNumberByte, self.VersionNumberByte2, self.VersionNumberLSB, self.VersionBoardType]
        let versionData = Data.init(_versionNo)
        let versionNumber = Int(UInt32(bigEndian: versionData.withUnsafeBytes { $0.load(as: UInt32.self) }))
        
        let _upDown = [self.UpdateDownCount2, self.UpdateDownCount1, self.UpdateDownCount0]
        let _upDownData = Data.init(_upDown)
        let upDown = Int(UInt16(bigEndian: _upDownData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _registrationID = [self.RegistrationID3, self.RegistrationID2, self.RegistrationID1, self.RegistrationID0]
        let _registrationIDData = Data.init(_registrationID)
        let registrationID = Int(UInt32(bigEndian: _registrationIDData.withUnsafeBytes { $0.load(as: UInt32.self) }))
        
        let crc16 = Utilities.instance.calculateCrc16From2bytes(hb: self.CRCHighByte, lb: self.CRCLowByte)
        
        self.SerialNumber = String(format: "%d", _serialNumber)
        self.Version = String(format: "%d", versionNumber)
        self.UpDownCount = String(format: "%d", upDown)
        self.RegistrationID = String(format: "%d", registrationID)
        
        print("versionNumber: ", Version)
        print("SerialNumber: ", SerialNumber)
        print("RegistrationID: ", RegistrationID)
    }
    
}

struct SPReport: PulseReportProtocol {
    var Length: Int = 0
    var Command: Int = 0
    var ReportingTime: Int = 0
    var YAxisAccRead: Int = 0
    var TemperatureOutput: Int = 0
    var PhotocellReading: Int  = 0
    var DbReading: Int  = 0
    var Sigma: Int = 0
    var SigmaHB: UInt8  = 0
    var SigmaLB: UInt8 = 0
    var RowSelectorSitting: Int  = 0
    var ColumnSelectorSitting: Int  = 0
    var RowSelectorStanding: Int = 0
    var ColumnSelectorStanding: Int = 0
    var CRCHighByte: UInt8  = 0
    var CRCLowByte: UInt8  = 0
    
    init(data: [UInt8]) {
        
        guard data.count > 0 else {
            return
        }
        
        self.Length = Int(data.item(at: 0) ?? 0)
        self.Command = Int(data.item(at: 1) ?? 0)
        self.ReportingTime = Int(data.item(at: 2) ?? 0)
        self.YAxisAccRead  = Int(data.item(at: 3) ?? 0)
        self.TemperatureOutput  = Int(data.item(at: 4) ?? 0) / 1000
        self.PhotocellReading   = Int(data.item(at: 5) ?? 0)
        self.DbReading   = Int(data.item(at: 6) ?? 0)
        self.SigmaHB = data.item(at: 7) ?? 0
        self.SigmaLB = data.item(at: 8) ?? 0
        
        let sigmaArr = [self.SigmaHB, self.SigmaLB]
        let sigmaData = Data.init(sigmaArr)
        let sigmaVal = Int(UInt8(bigEndian: sigmaData.withUnsafeBytes { $0.load(as: UInt8.self) }))
        self.Sigma = sigmaVal
        
        self.RowSelectorSitting = Int(data.item(at: 9) ?? 0)
        self.ColumnSelectorSitting  = Int(data.item(at: 10) ?? 0)
        self.RowSelectorStanding = Int(data.item(at: 11) ?? 0)
        self.ColumnSelectorStanding = Int(data.item(at: 12) ?? 0)
        
        self.CRCHighByte = data.item(at: 18) ?? 0
        self.CRCLowByte = data.item(at: 19) ?? 0
        
        let crc16 = Utilities.instance.calculateCrc16From2bytes(hb: self.CRCHighByte, lb: self.CRCLowByte)
    }
    
    func getReadablesTemp() -> Int {
         return TemperatureOutput / 1000
    }
}

struct SPServerData: PulseServerDataProtocol {
    var Length: Int = 0
    var Command: Int = 0
    var PushFrequency: UInt8 = 0
    var SitTimeStorageHB: UInt8 = 0
    var SitTimeStorageLB: UInt8 = 0
    var StandTimeStorageHB: UInt8 = 0
    var StandTimeStorageLB: UInt8 = 0
    var AwayTimeStorageHB: UInt8 = 0
    var AwayTimeStorageLB: UInt8 = 0
    var AutomaticTimeStorageHB: UInt8 = 0
    var AutomaticTimeStorageLB: UInt8 = 0
    var InteractiveTimeStorageHB: UInt8 = 0
    var InteractiveTimeStorageLB: UInt8 = 0
    var ManualTimeStorageHB: UInt8 = 0
    var ManualTimeStorageLB: UInt8 = 0
    var SafetyTriggerTallyStorage: UInt8 = 0
    var UpDownTallyStorage: UInt8 = 0
    var CurrentDeskAvailability: UInt8 = 0
    var CRCHighByte: UInt8 = 0
    var CRCLowByte: UInt8 = 0
    
    
    var SitTimeStorage: Int = 0
    var StandTimeStorage: Int = 0
    var AwayTimeStorage: Int = 0
    var AutomaticTimeStorage: Int = 0
    var InteractiveTimeStorage: Int = 0
    var ManualTimeStorage: Int = 0
    
    var byteArray: [UInt8] = [UInt8]()
    
    init(data: [UInt8]) {
        
        guard data.count > 0 else {
            return
        }
        byteArray = data
        Length = Int(data.item(at: 0) ?? 0)
        Command = Int(data.item(at: 1) ?? 0)
        PushFrequency = data.item(at: 2) ?? 0
        SitTimeStorageHB = data.item(at: 3) ?? 0
        SitTimeStorageLB = data.item(at: 4) ?? 0
        StandTimeStorageHB = data.item(at: 5) ?? 0
        StandTimeStorageLB = data.item(at: 6) ?? 0
        AwayTimeStorageHB = data.item(at: 7) ?? 0
        AwayTimeStorageLB = data.item(at: 8) ?? 0
        AutomaticTimeStorageHB = data.item(at: 9) ?? 0
        AutomaticTimeStorageLB = data.item(at: 10) ?? 0
        InteractiveTimeStorageHB = data.item(at: 11) ?? 0
        InteractiveTimeStorageLB = data.item(at: 12) ?? 0
        ManualTimeStorageHB = data.item(at: 13) ?? 0
        ManualTimeStorageLB = data.item(at: 14) ?? 0
        SafetyTriggerTallyStorage = data.item(at: 15) ?? 0
        UpDownTallyStorage = data.item(at: 16) ?? 0
        CurrentDeskAvailability = data.item(at: 17) ?? 0
        
        CRCHighByte = data.item(at: 18) ?? 0
        CRCLowByte = data.item(at: 19) ?? 0
        
        let _sitTimeStorage = [SitTimeStorageHB, SitTimeStorageLB]
        let _sitTimeStorageData = Data(_sitTimeStorage)
        SitTimeStorage = Int(UInt16(bigEndian: _sitTimeStorageData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _standTimeStorage = [StandTimeStorageHB, StandTimeStorageLB]
        let _standTimeStorageData = Data(_standTimeStorage)
        StandTimeStorage = Int(UInt16(bigEndian: _standTimeStorageData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _awayTimeStorage = [AwayTimeStorageHB, AwayTimeStorageLB]
        let _awayTimeStorageData = Data(_awayTimeStorage)
        AwayTimeStorage = Int(UInt16(bigEndian: _awayTimeStorageData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _automaticTimeStorage = [AutomaticTimeStorageHB, AutomaticTimeStorageLB]
        let _automaticTimeStorageData = Data(_automaticTimeStorage)
        AutomaticTimeStorage = Int(UInt16(bigEndian: _automaticTimeStorageData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _interactiveTimeStorage = [InteractiveTimeStorageHB, InteractiveTimeStorageLB]
        let _interactiveTimeStorageData = Data(_interactiveTimeStorage)
        InteractiveTimeStorage = Int(UInt16(bigEndian: _interactiveTimeStorageData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _manualTimeStorage = [ManualTimeStorageHB, ManualTimeStorageLB]
        let _manualTimeStorageData = Data(_manualTimeStorage)
        ManualTimeStorage = Int(UInt16(bigEndian: _manualTimeStorageData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
    }
    
}

struct SPAESKey: PulseAESKeyProtocol {
    var Length: Int = 0
    var Command: Int = 0
    var PayloadAESKey0: UInt8 = 0
    var PayloadAESKey1: UInt8 = 0
    var PayloadAESKey2: UInt8 = 0
    var PayloadAESKey3: UInt8 = 0
    var PayloadAESKey4: UInt8 = 0
    var PayloadAESKey5: UInt8 = 0
    var PayloadAESKey6: UInt8 = 0
    var PayloadAESKey7: UInt8 = 0
    var PayloadAESKey8: UInt8 = 0
    var PayloadAESKey9: UInt8 = 0
    var PayloadAESKey10: UInt8 = 0
    var PayloadAESKey11: UInt8 = 0
    var PayloadAESKey12: UInt8 = 0
    var PayloadAESKey13: UInt8 = 0
    var PayloadAESKey14: UInt8 = 0
    var PayloadAESKey15: UInt8 = 0
    var CRCHighByte: UInt8 = 0
    var CRCLowByte: UInt8 = 0
    
    var AESKey: Data = Data()
    var AESKeyString = ""
    
    init(data: [UInt8]) {
        guard data.count > 0 else {
            return
        }
        
        Length = Int(data.item(at: 0) ?? 0)
        Command = Int(data.item(at: 1) ?? 0)
        PayloadAESKey0  = data.item(at: 2) ?? 0
        PayloadAESKey1  = data.item(at: 3) ?? 0
        PayloadAESKey2  = data.item(at: 4) ?? 0
        PayloadAESKey3  = data.item(at: 5) ?? 0
        PayloadAESKey4  = data.item(at: 6) ?? 0
        PayloadAESKey5  = data.item(at: 7) ?? 0
        PayloadAESKey6  = data.item(at: 8) ?? 0
        PayloadAESKey7  = data.item(at: 9) ?? 0
        PayloadAESKey8  = data.item(at: 10) ?? 0
        PayloadAESKey9  = data.item(at: 11) ?? 0
        PayloadAESKey10  = data.item(at: 12) ?? 0
        PayloadAESKey11  = data.item(at: 13) ?? 0
        PayloadAESKey12  = data.item(at: 14) ?? 0
        PayloadAESKey13  = data.item(at: 15) ?? 0
        PayloadAESKey14  = data.item(at: 16) ?? 0
        PayloadAESKey15  = data.item(at: 17) ?? 0
        CRCHighByte  = data.item(at: 18) ?? 0
        CRCLowByte  = data.item(at: 19) ?? 0
        
        let aesBytes: [UInt8] = [PayloadAESKey0,
                       PayloadAESKey1,
                       PayloadAESKey2,
                       PayloadAESKey3,
                       PayloadAESKey4,
                       PayloadAESKey5,
                       PayloadAESKey6,
                       PayloadAESKey7,
                       PayloadAESKey8,
                       PayloadAESKey9,
                       PayloadAESKey10,
                       PayloadAESKey11,
                       PayloadAESKey12,
                       PayloadAESKey13,
                       PayloadAESKey14,
                       PayloadAESKey15]
        
        print("aesBytes : \(aesBytes)")
        
        AESKey = Data(bytes: aesBytes, count: aesBytes.count)
        
        AESKeyString = String(data: AESKey, encoding: .utf8)?.base64Encoded ?? ""
        print("AESKeyString : \(AESKeyString)")
    }
}

struct SPAESIV: PulseAESIVProtocol {
    var Length: Int = 0
    var Command: Int = 0
    var PayloadAESIV0: UInt8 = 0
    var PayloadAESIV1: UInt8 = 0
    var PayloadAESIV2: UInt8 = 0
    var PayloadAESIV3: UInt8 = 0
    var PayloadAESIV4: UInt8 = 0
    var PayloadAESIV5: UInt8 = 0
    var PayloadAESIV6: UInt8 = 0
    var PayloadAESIV7: UInt8 = 0
    var PayloadAESIV8: UInt8 = 0
    var PayloadAESIV9: UInt8 = 0
    var PayloadAESIV10: UInt8 = 0
    var PayloadAESIV11: UInt8 = 0
    var PayloadAESIV12: UInt8 = 0
    var PayloadAESIV13: UInt8 = 0
    var PayloadAESIV14: UInt8 = 0
    var PayloadAESIV15: UInt8 = 0
    var CRCHighByte: UInt8 = 0
    var CRCLowByte: UInt8 = 0
    
    var AESIV: Data = Data()
    var AESIVString = ""
    
    init(data: [UInt8]) {
        guard data.count > 0 else {
            return
        }
        
        Length = Int(data.item(at: 0) ?? 0)
        Command = Int(data.item(at: 1) ?? 0)
        PayloadAESIV0  = data.item(at: 2) ?? 0
        PayloadAESIV1  = data.item(at: 3) ?? 0
        PayloadAESIV2  = data.item(at: 4) ?? 0
        PayloadAESIV3  = data.item(at: 5) ?? 0
        PayloadAESIV4  = data.item(at: 6) ?? 0
        PayloadAESIV5  = data.item(at: 7) ?? 0
        PayloadAESIV6  = data.item(at: 8) ?? 0
        PayloadAESIV7  = data.item(at: 9) ?? 0
        PayloadAESIV8  = data.item(at: 10) ?? 0
        PayloadAESIV9  = data.item(at: 11) ?? 0
        PayloadAESIV10  = data.item(at: 12) ?? 0
        PayloadAESIV11  = data.item(at: 13) ?? 0
        PayloadAESIV12  = data.item(at: 14) ?? 0
        PayloadAESIV13  = data.item(at: 15) ?? 0
        PayloadAESIV14  = data.item(at: 16) ?? 0
        PayloadAESIV15  = data.item(at: 17) ?? 0
        CRCHighByte  = data.item(at: 18) ?? 0
        CRCLowByte  = data.item(at: 19) ?? 0
        
        let ivBytes: [UInt8] = [PayloadAESIV0,
                      PayloadAESIV1,
                      PayloadAESIV2,
                      PayloadAESIV3,
                      PayloadAESIV4,
                      PayloadAESIV5,
                      PayloadAESIV6,
                      PayloadAESIV7,
                      PayloadAESIV8,
                      PayloadAESIV9,
                      PayloadAESIV10,
                      PayloadAESIV11,
                      PayloadAESIV12,
                      PayloadAESIV13,
                      PayloadAESIV14,
                      PayloadAESIV15]
        
        print("ivBytes : \(ivBytes)")
        
        AESIV = Data(bytes: ivBytes, count: ivBytes.count)
        AESIVString = String(data: AESIV, encoding: .utf8)?.base64Encoded ?? ""
        
    }
}

//struct AES {
//
//    // MARK: - Value
//    // MARK: Private
//    private let key: Data
//    private let iv: Data
//
//
//    // MARK: - Initialzier
//    init?(key: String, iv: String) {
//        guard key.count == kCCKeySizeAES128 || key.count == kCCKeySizeAES256, let keyData = key.data(using: .utf8) else {
//            debugPrint("Error: Failed to set a key.")
//            return nil
//        }
//
//        guard iv.count == kCCBlockSizeAES128, let ivData = iv.data(using: .utf8) else {
//            debugPrint("Error: Failed to set an initial vector.")
//            return nil
//        }
//
//
//        self.key = keyData
//        self.iv  = ivData
//    }
//
//
//    // MARK: - Function
//    // MARK: Public
//    func encrypt(string: String) -> Data? {
//        return crypt(data: string.data(using: .utf8), option: CCOperation(kCCEncrypt))
//    }
//
//    func decrypt(data: Data?) -> String? {
//        guard let decryptedData = crypt(data: data, option: CCOperation(kCCDecrypt)) else { return nil }
//        return String(bytes: decryptedData, encoding: .utf8)
//    }
//
//    func crypt(data: Data?, option: CCOperation) -> Data? {
//        guard let data = data else { return nil }
//
//        let cryptLength = data.count + kCCBlockSizeAES128
//        var cryptData   = Data(count: cryptLength)
//
//        let keyLength = key.count
//        let options   = CCOptions(kCCOptionPKCS7Padding)
//
//        var bytesLength = Int(0)
//
//        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
//            data.withUnsafeBytes { dataBytes in
//                iv.withUnsafeBytes { ivBytes in
//                    key.withUnsafeBytes { keyBytes in
//                    CCCrypt(option, CCAlgorithm(kCCAlgorithmAES), options, keyBytes.baseAddress, keyLength, ivBytes.baseAddress, dataBytes.baseAddress, data.count, cryptBytes.baseAddress, cryptLength, &bytesLength)
//                    }
//                }
//            }
//        }
//
//        guard UInt32(status) == UInt32(kCCSuccess) else {
//            debugPrint("Error: Failed to crypt data. Status \(status)")
//            return nil
//        }
//
//        cryptData.removeSubrange(bytesLength..<cryptData.count)
//        return cryptData
//    }
//}
