//
//  BoxDataObjects.swift
//  PulseEcho
//
//  Created by Joseph on 2020-07-06.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import EventCenter
import SwiftEventBus

struct CoreOne: CoreOneProtocol {
    var Length: Int = 0
    var Command: Int = 0
    var ReportedVerPosHB: UInt8 = 0
    var ReportedVerPosLB: UInt8 = 0
    var MainTimerCycleSecondsHB: UInt8 = 0
    var MainTimerCycleSecondsLB: UInt8  = 0
    var MovesreportedVertPos: Int  = 0
    var TimesreportedVertPosHB: UInt8  = 0
    var TimesreportedVertPosLB: UInt8  = 0
    var PendingMovementCode: Int  = 0
    var CondensedStatusOne: Int  = 0
    var CondensedStatusTwo: Int  = 0
    var CondensedEnableOne: Int  = 0
    var CondensedEnableTwo: Int  = 0
    var WifiSyncStatus: Int  = 0
    var CondensedWifi: Int  = 0
    var LoopTimeElapsed: Int  = 0
    var CRCHighByte: UInt8  = 0
    var CRCLowByte: UInt8 = 0
    
    var ReportedVertPos: Int  = 0
    var MainTimerCycleSeconds: Int  = 0
    var TimesreportedVertPos: Int  = 0
    var RunSwitch: Bool = false
    var SafetyStatus: Bool = false
    var AwayStatus: Bool = false
    var Movingdownstatus: Bool = false
    var Movingupstatus: Bool = false
    var HeightSensorStatus: Bool = false
    var AlternateCalibrationMode: Bool = false
    var AlternateAITBMode: Bool = false
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
    var CommissioningFlag: Bool  = false
    var HeartBeatOut: Bool = false
    
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
        self.MovesreportedVertPos = Int(data.item(at: 6) ?? 0)
        self.TimesreportedVertPosHB = data.item(at: 7) ?? 0
        self.TimesreportedVertPosLB = data.item(at: 8) ?? 0
        self.PendingMovementCode = Int(data.item(at: 9) ?? 0)
        self.CondensedStatusOne = Int(data.item(at: 10) ?? 0)
        self.CondensedStatusTwo = Int(data.item(at: 11) ?? 0)
        self.CondensedEnableOne = Int(data.item(at: 12) ?? 0)
        self.CondensedEnableTwo = Int(data.item(at: 13) ?? 0)
        self.WifiSyncStatus = Int(data.item(at: 14) ?? 0)
        self.CondensedWifi = Int(data.item(at: 15) ?? 0)
        self.LoopTimeElapsed = Int(data.item(at: 16) ?? 0)
        self.CRCHighByte = data.item(at: 17) ?? 0
        self.CRCLowByte = data.item(at: 18) ?? 0
        
        let _verticalPosition = [self.ReportedVerPosHB, self.ReportedVerPosLB]
        let _verticalPositionData = Data.init(_verticalPosition)
        
        let _mainTimerCycle = [self.MainTimerCycleSecondsHB, self.MainTimerCycleSecondsLB]
        let _mainTimerCycleData = Data.init(_mainTimerCycle)
        
        let _timesReportVertPos = [self.TimesreportedVertPosHB, self.TimesreportedVertPosLB]
        let _timesReportVertPosData = Data.init(_timesReportVertPos)
        
        self.ReportedVertPos = Int(UInt16(bigEndian: _verticalPositionData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        self.MainTimerCycleSeconds = Int(UInt16(bigEndian: _mainTimerCycleData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        self.TimesreportedVertPos = Int(UInt16(bigEndian: _timesReportVertPosData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        self.RunSwitch = Utilities.instance.convertBitField(value: self.CondensedStatusOne, index: 0)
        self.SafetyStatus =  Utilities.instance.convertBitField(value: self.CondensedStatusOne, index: 1)
        self.AwayStatus =  Utilities.instance.convertBitField(value: self.CondensedStatusOne, index: 2)
        self.Movingdownstatus =  Utilities.instance.convertBitField(value: self.CondensedStatusOne, index: 3)
        self.Movingupstatus =  Utilities.instance.convertBitField(value: self.CondensedStatusOne, index: 4)
        self.HeightSensorStatus =  Utilities.instance.convertBitField(value: self.CondensedStatusOne, index: 5)
        self.AlternateCalibrationMode =  Utilities.instance.convertBitField(value: self.CondensedStatusOne, index: 6)
        self.AlternateAITBMode =  Utilities.instance.convertBitField(value: self.CondensedStatusOne, index: 7)
        
        self.EnableTwoStageCalibration = Utilities.instance.convertBitField(value: self.CondensedEnableOne, index: 0)
        self.EnableHeatSenseFlipSitting = Utilities.instance.convertBitField(value: self.CondensedEnableOne, index: 1)
        self.EnableHeatSenseFlipStanding = Utilities.instance.convertBitField(value: self.CondensedEnableOne, index: 2)
        self.EnableMotionDetection = Utilities.instance.convertBitField(value: self.CondensedEnableOne, index: 3)
        self.EnableTiMotionBus = Utilities.instance.convertBitField(value: self.CondensedEnableOne, index: 4)
        self.EnableSafety = Utilities.instance.convertBitField(value: self.CondensedEnableOne, index: 5)
        self.UserAuthenticated = Utilities.instance.convertBitField(value: self.CondensedEnableOne, index: 6)
        self.UseInteractiveMode = Utilities.instance.convertBitField(value: self.CondensedEnableOne, index: 7)
        
        
        self.AppRxFailFlag = Utilities.instance.convertBitField(value: self.CondensedEnableTwo, index: 0)
        self.WifiTxpushFailure = Utilities.instance.convertBitField(value: self.CondensedEnableTwo, index: 1)
        self.WeAreSitting = Utilities.instance.convertBitField(value: self.CondensedEnableTwo, index: 4)
        self.ObstructionStatus = Utilities.instance.convertBitField(value: self.CondensedEnableTwo, index: 5)
        self.CommissioningFlag = Utilities.instance.convertBitField(value: self.CondensedEnableTwo, index: 6)
        self.HeartBeatOut = Utilities.instance.convertBitField(value: self.CondensedEnableTwo, index: 7)
        
        if self.RunSwitch == false {
            Utilities.instance.saveDefaultValueForKey(value: "Manual", key: "desk_mode")
        }
    }
}

struct CoreTwo: CoreTwoProtocol {
    var Length: Int = 0
    var Command: Int = 0
    var AppLEDIntensity: Int = 0
    var AppReadingLightIntensity: Int = 0
    var AppAwayAdjust: Int = 0
    var AppSigmaSittingThreshold: Int = 0
    var AppSigmaStandingThreshold: Int = 0
    var AppSafetySensitivity: Int = 0
    var RowSelectorSitting: Int = 0
    var ColumnSelectorSitting: Int = 0
    var RowSelectorStanding: Int = 0
    var ColumnSelectorStanding: Int = 0
    var TiMotionErrorCodeToPrint: Int = 0
    var ErrorIDHB: UInt8 = 0
    var ErrorIDLB: UInt8 = 0
    var CRCHighByte: UInt8 = 0
    var CRCLowByte: UInt8 = 0
    
   init(data: [UInt8], ec: EventCenter? = nil) {
        guard data.count > 0 else {
            return
        }
    
        self.Length = Int(data.item(at: 0) ?? 0)
        self.Command = Int(data.item(at: 1) ?? 0)
        self.AppLEDIntensity = Int(data.item(at: 2) ?? 0)
        self.AppReadingLightIntensity = Int(data.item(at: 3) ?? 0)
        self.AppAwayAdjust = Int(data.item(at: 4) ?? 0)
        self.AppSigmaSittingThreshold = Int(data.item(at: 5) ?? 0)
        self.AppSigmaStandingThreshold = Int(data.item(at: 6) ?? 0)
        self.AppSafetySensitivity = Int(data.item(at: 7) ?? 0)
        self.RowSelectorSitting = Int(data.item(at: 8) ?? 0)
        self.ColumnSelectorSitting = Int(data.item(at: 9) ?? 0)
        self.RowSelectorStanding = Int(data.item(at: 10) ?? 0)
        self.ColumnSelectorStanding = Int(data.item(at: 11) ?? 0)
        self.TiMotionErrorCodeToPrint = Int(data.item(at: 12) ?? 0)
        self.ErrorIDHB = data.item(at: 13) ?? 0
        self.ErrorIDLB = data.item(at: 14) ?? 0
        self.CRCHighByte = data.item(at: 15) ?? 0
        self.CRCLowByte = data.item(at: 16) ?? 0
        
    }
}


struct ReportOne: ReportOneProtocol {
    var Length: Int = 0
    var Command: Int = 0
    var StatusTimerHours: Int = 0
    var StatusTimerMinutes: Int = 0
    var StatusTimerSeconds: Int = 0
    var ReportingTime: Int = 0
    var TimeReportingIndex: Int = 0
    var YAxisAccReadHB: UInt8 = 0
    var YAxisAccReadLB: UInt8 = 0
    var TemperatureOutputHB: UInt8 = 0
    var TemperatureOutputLB: UInt8 = 0
    var PhotocellReadingHB: UInt8 = 0
    var PhotocellReadingLB: UInt8 = 0
    var DbReadingHB: UInt8 = 0
    var DbReadingLB: UInt8 = 0
    var CRCHighByte: UInt8 = 0
    var CRCLowByte: UInt8 = 0
    
    var YAxisAccRead: Int = 0
    var TemperatureOutput: Int  = 0
    var PhotocellReading: Int  = 0
    var DbReading: Int = 0
    
    func getReadablesTemp() -> Int {
         return TemperatureOutput / 1000
     }
    
    init(data: [UInt8], ec: EventCenter? = nil) {
         guard data.count > 0 else {
             return
         }
        
        self.Length = Int(data.item(at: 0) ?? 0)
        self.Command = Int(data.item(at: 1) ?? 0)
        self.StatusTimerHours = Int(data.item(at: 2) ?? 0)
        self.StatusTimerMinutes = Int(data.item(at: 3) ?? 0)
        self.StatusTimerSeconds = Int(data.item(at: 4) ?? 0)
        self.ReportingTime = Int(data.item(at: 5) ?? 0)
        self.TimeReportingIndex = Int(data.item(at: 6) ?? 0)
        
        self.YAxisAccReadHB = data.item(at: 7) ?? 0
        self.YAxisAccReadLB = data.item(at: 8) ?? 0
        
        self.TemperatureOutputHB = data.item(at: 9) ?? 0
        self.TemperatureOutputLB = data.item(at: 10) ?? 0
        
        self.PhotocellReadingHB = data.item(at: 11) ?? 0
        self.PhotocellReadingLB = data.item(at: 12) ?? 0
        
        self.DbReadingHB = data.item(at: 13) ?? 0
        self.DbReadingLB = data.item(at: 14) ?? 0
        
        self.CRCHighByte = data.item(at: 15) ?? 0
        self.CRCLowByte = data.item(at: 16) ?? 0
        
        let _yAxisAccRead = [self.YAxisAccReadHB, self.YAxisAccReadLB]
        let _yAxisAccReadData = Data.init(_yAxisAccRead)
        self.YAxisAccRead = Int(UInt16(bigEndian: _yAxisAccReadData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _temperatureOutput = [self.TemperatureOutputHB, self.TemperatureOutputLB]
        let _temperatureOutputData = Data.init(_temperatureOutput)
        self.TemperatureOutput = Int(UInt16(bigEndian: _temperatureOutputData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        
        let _photocellReading = [self.PhotocellReadingHB, self.PhotocellReadingLB]
        let _photocellReadingData = Data.init(_photocellReading)
        self.PhotocellReading = Int(UInt16(bigEndian: _photocellReadingData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _dbReading = [self.DbReadingHB, self.DbReadingLB]
        let _dbReadingData = Data.init(_dbReading)
        self.DbReading = Int(UInt16(bigEndian: _dbReadingData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
       // ec?.post(event: Event.Name("dataStringObject"), object: self)
    }
    
}

struct ReportTwo: ReportTwoProtocol {
    var Length: Int = 0
    var Command: Int = 0
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
    var SafetyTriggerTallyStorage: Int = 0
    var UpDownTallyStorage: Int = 0
    var DetectionTransitionTallyStorage: Int = 0
    var CRCHighByte: UInt8 = 0
    var CRCLowByte: UInt8 = 0
    
    var SitTime: Int = 0
    var StandTime: Int = 0
    var AwayTime: Int = 0
    var AutomaticTime: Int = 0
    var SemiAutomaticTime: Int = 0
    var ManualTime: Int = 0
    var SafetyIncrement: Int = 0
    var UpDownIncrement: Int = 0
    var DetectionThresholdTally: Int = 0
    
   init(data: [UInt8], ec: EventCenter? = nil) {
        guard data.count > 0 else {
            return
        }
        
        self.Length = Int(data.item(at: 0) ?? 0)
        self.Command = Int(data.item(at: 1) ?? 0)
        self.SitTimeStorageHB  = data.item(at: 2) ?? 0
        self.SitTimeStorageLB  = data.item(at: 3) ?? 0
        self.StandTimeStorageHB  = data.item(at: 4) ?? 0
        self.StandTimeStorageLB  = data.item(at: 5) ?? 0
        self.AwayTimeStorageHB  = data.item(at: 6) ?? 0
        self.AwayTimeStorageLB  = data.item(at: 7) ?? 0
        self.AutomaticTimeStorageHB  = data.item(at: 8) ?? 0
        self.AutomaticTimeStorageLB  = data.item(at: 9) ?? 0
        self.InteractiveTimeStorageHB  = data.item(at: 10) ?? 0
        self.InteractiveTimeStorageLB  = data.item(at: 11) ?? 0
        self.ManualTimeStorageHB  = data.item(at: 12) ?? 0
        self.ManualTimeStorageLB  = data.item(at: 13) ?? 0
        self.SafetyTriggerTallyStorage  = Int(data.item(at: 14) ?? 0)
        self.UpDownTallyStorage  = Int(data.item(at: 15) ?? 0)
        self.DetectionTransitionTallyStorage  = Int(data.item(at: 16) ?? 0)
        self.CRCHighByte  = data.item(at: 17) ?? 0
        self.CRCLowByte  = data.item(at: 18) ?? 0
    
        let _sitTime = [self.SitTimeStorageHB, self.SitTimeStorageLB]
        let _sitTimeData = Data.init(_sitTime)
        self.SitTime = Int(UInt16(bigEndian: _sitTimeData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _standTime = [self.StandTimeStorageHB, self.StandTimeStorageLB]
        let _standTimeData = Data.init(_standTime)
        self.StandTime = Int(UInt16(bigEndian: _standTimeData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _awayTime = [self.AwayTimeStorageHB, self.AwayTimeStorageLB]
        let _awayTimeData = Data.init(_awayTime)
        self.AwayTime = Int(UInt16(bigEndian: _awayTimeData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _automaticTime = [self.AutomaticTimeStorageHB, self.AutomaticTimeStorageLB]
        let _automaticTimeData = Data.init(_automaticTime)
        self.AutomaticTime = Int(UInt16(bigEndian: _automaticTimeData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _semiAutomaticTime = [self.InteractiveTimeStorageHB, self.InteractiveTimeStorageLB]
        let _semiAutomaticTimeData = Data.init(_semiAutomaticTime)
        self.SemiAutomaticTime = Int(UInt16(bigEndian: _semiAutomaticTimeData.withUnsafeBytes { $0.load(as: UInt16.self) }))
    
        let _manualTime = [self.ManualTimeStorageHB, self.ManualTimeStorageLB]
        let _manualTimeData = Data.init(_manualTime)
        self.ManualTime = Int(UInt16(bigEndian: _manualTimeData.withUnsafeBytes { $0.load(as: UInt16.self) }))
    
        self.SafetyIncrement  = self.SafetyTriggerTallyStorage
        self.UpDownIncrement  = self.UpDownTallyStorage
        self.DetectionThresholdTally = self.DetectionTransitionTallyStorage
    }
    
}

struct VerticalProfile: VerticalProfileProtocol {
    var Length: Int = 0
    var Command: Int = 0
    var MoveOne: Int = 0
    var TimeOneHB: UInt8 = 0
    var TimeOneLB: UInt8 = 0
    var MoveTwo: Int = 0
    var TimeTwoHB: UInt8 = 0
    var TimeTwoLB: UInt8 = 0
    var MoveThree: Int = 0
    var TimeThreeHB: UInt8 = 0
    var TimeThreeLB: UInt8 = 0
    var MoveFour: Int = 0
    var TimeFourHB: UInt8 = 0
    var TimeFourLB: UInt8 = 0
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
    
    var vertical_profile = [UInt8]()

    init(data: [UInt8], rawString: String, notify: Bool, ec: EventCenter? = nil) {
        
        guard data.count > 0 else {
            return
        }
        
        self.vertical_profile = data
        self.Length = Int(data.item(at: 0) ?? 0)
        self.Command = Int(data.item(at: 1) ?? 0)
        
        if self.Length == 10 {
            self.MoveOne = Int(data.item(at: 2) ?? 0)
            self.TimeOneHB = data.item(at: 3) ?? 0
            self.TimeOneLB = data.item(at: 4) ?? 0
            
            let _timeOne = [self.TimeOneHB, self.TimeOneLB]
            let _timeOneData = Data.init(_timeOne)
            timeOne = Int(UInt16(bigEndian: _timeOneData.withUnsafeBytes { $0.load(as: UInt16.self) }))
            
            self.MoveTwo = Int(data.item(at: 5) ?? 0)
            self.TimeTwoHB = data.item(at: 6) ?? 0
            self.TimeTwoLB = data.item(at: 7) ?? 0

            let _timeTwo = [self.TimeTwoHB, self.TimeTwoLB]
            let _timeTwoData = Data.init(_timeTwo)
            timeTwo = Int(UInt16(bigEndian: _timeTwoData.withUnsafeBytes { $0.load(as: UInt16.self) }))

            self.CRCHighByte = data.item(at: 8) ?? 0
            self.CRCLowByte = data.item(at: 9) ?? 0
            
        } else {
            self.MoveOne = Int(data.item(at: 2) ?? 0)
            self.TimeOneHB = data.item(at: 3) ?? 0
            self.TimeOneLB = data.item(at: 4) ?? 0
            
            let _timeOne = [self.TimeOneHB, self.TimeOneLB]
            let _timeOneData = Data.init(_timeOne)
            timeOne = Int(UInt16(bigEndian: _timeOneData.withUnsafeBytes { $0.load(as: UInt16.self) }))
            
            self.MoveTwo = Int(data.item(at: 5) ?? 0)
            self.TimeTwoHB = data.item(at: 6) ?? 0
            self.TimeTwoLB = data.item(at: 7) ?? 0

            let _timeTwo = [self.TimeTwoHB, self.TimeTwoLB]
            let _timeTwoData = Data.init(_timeTwo)
            timeTwo = Int(UInt16(bigEndian: _timeTwoData.withUnsafeBytes { $0.load(as: UInt16.self) }))

            self.MoveThree = Int(data.item(at: 8) ?? 0)
            self.TimeThreeHB = data.item(at: 9) ?? 0
            self.TimeThreeLB = data.item(at: 10) ?? 0
            
            let _timeThree = [self.TimeThreeHB, self.TimeThreeLB]
            let _timeThreeData = Data.init(_timeThree)
            timeThree = Int(UInt16(bigEndian: _timeThreeData.withUnsafeBytes { $0.load(as: UInt16.self) }))
            
            self.MoveFour = Int(data.item(at: 11) ?? 0)
            self.TimeFourHB = data.item(at: 12) ?? 0
            self.TimeFourLB = data.item(at: 13) ?? 0
            
            let _timeFour = [self.TimeFourHB, self.TimeFourLB]
            let _timeFourData = Data.init(_timeFour)
            timeFour = Int(UInt16(bigEndian: _timeFourData.withUnsafeBytes { $0.load(as: UInt16.self) }))
            
            self.CRCHighByte = data.item(at: 14) ?? 0
            self.CRCLowByte = data.item(at: 15) ?? 0
            
        }
        
        let _movement0 = self.MoveOne != 0 ? String(format: "%d,%d",timeOne,self.MoveOne) : ""
        let _movement1 = self.MoveTwo != 0 ? String(format: "%d,%d",timeTwo,self.MoveTwo) : ""
        let _movement2 = self.MoveThree != 0 ? String(format: "%d,%d",timeThree,self.MoveThree) : ""
        let _movement3 = self.MoveFour != 0 ?  String(format: "%d,%d",timeFour,self.MoveFour) : ""
        
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
    
    //Dummy vertical profile
    init(rawString: String, strings:[String.SubSequence], ec: EventCenter? = nil, raw: String? = nil, notify: Bool) {
     // need to get rid of the string substring sequence casting to string
     let _converted = strings.map { String($0) }
     let _crcString = String(_converted.item(at: _converted.count - 1) ?? "0")
     let _crc16Validation =  Utilities.instance.getRawCommandCrc16(raw: rawString, strings: _converted)
     
     let _movement0 = _converted.item(at: 1) ?? ""
     let _movement1 = _converted.item(at:2) ?? ""
     let _movement2 = _converted.item(at:3) ?? ""
     let _movement3 = _converted.item(at:4) ?? ""
     
     self.movement0 = _movement0
     self.movement1 = _movement1
     self.movement2 = _movement2
     self.movement3 = _movement3
     self.movementRawString = raw ?? ""

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


struct Identifier: IdentifierProtocol {
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
    var CRCHighByte: UInt8 = 0
    var CRCLowByte: UInt8 = 0
    
    var SerialNumber: String = ""
    var Version: String = ""
    
    init(data: [UInt8], ec: EventCenter? = nil) {
        guard data.count > 0 else {
         return
        }
        
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
        self.CRCHighByte = data.item(at: 11) ?? 0
        self.CRCLowByte = data.item(at: 12) ?? 0
        
        let _deskId = [self.DeskIDMSB, self.DeskIDByte3, self.DeskIDByte2, DeskIDLSB]
        let deskData = Data.init(_deskId)
        let _serialNumber = Int(UInt32(bigEndian: deskData.withUnsafeBytes { $0.load(as: UInt32.self) }))
        
        let _versionNo = [self.VersionNumberMSB, self.VersionNumberByte, self.VersionNumberByte2, self.VersionNumberLSB, self.VersionBoardType]
        let versionData = Data.init(_versionNo)
        let versionNumber = Int(UInt32(bigEndian: versionData.withUnsafeBytes { $0.load(as: UInt32.self) }))
        
        self.SerialNumber = String(format: "%d", _serialNumber)
        self.Version = String(format: "%d", versionNumber)

    }
    
}

struct BoxHeight: BoxHeightProtocol {
    var Length: Int = 0
    var Command: Int = 0
    var ReportedMinHeightHB: UInt8 = 0
    var ReportedMinHeightLB: UInt8 = 0
    var ReportedMaxHeightHB: UInt8 = 0
    var ReportedMaxHeightLB: UInt8 = 0
    var ReportedSittingPosHB: UInt8 = 0
    var ReportedSittingPosLB: UInt8 = 0
    var ReportedStandingPosHB: UInt8 = 0
    var ReportedStandingPosLB: UInt8 = 0
    var DeskOvershootValueHB: UInt8 = 0
    var DeskOvershootValueLB: UInt8 = 0
    var DeskHeightOffsetHB: UInt8 = 0
    var DeskHeightOffsetLB: UInt8 = 0
    var SigmaHB: UInt8 = 0
    var SigmaLB: UInt8 = 0
    var SigmaSittingThreshold: Int = 0
    var SigmaStandingThreshold: Int = 0
    var CRCHighByte: UInt8 = 0
    var CRCLowByte: UInt8 = 0
    
    var ReportedMinHeight: Int = 0
    var ReportedMaxHeight: Int = 0
    var ReportedSittingPos: Int = 0
    var ReportingStandingPos: Int = 0
    var DeskOvershootValue: Int = 0
    var DeskHeightOffset: Int = 0
    var Sigma: Int = 0
    
    init(data: [UInt8], ec: EventCenter? = nil) {
        guard data.count > 0 else {
         return
        }
     
        self.Length = Int(data.item(at: 0) ?? 0)
        self.Command = Int(data.item(at: 1) ?? 0)
        self.ReportedMinHeightHB = data.item(at: 2) ?? 0
        self.ReportedMinHeightLB = data.item(at: 3) ?? 0
        self.ReportedMaxHeightHB  = data.item(at: 4) ?? 0
        self.ReportedMaxHeightLB  = data.item(at: 5) ?? 0
        self.ReportedSittingPosHB  = data.item(at: 6) ?? 0
        self.ReportedSittingPosLB  = data.item(at: 7) ?? 0
        self.ReportedStandingPosHB  = data.item(at: 8) ?? 0
        self.ReportedStandingPosLB  = data.item(at: 9) ?? 0
        self.DeskOvershootValueHB  = data.item(at: 10) ?? 0
        self.DeskOvershootValueLB  = data.item(at: 11) ?? 0
        self.DeskHeightOffsetHB  = data.item(at: 12) ?? 0
        self.DeskHeightOffsetLB  = data.item(at: 13) ?? 0
        self.SigmaHB  = data.item(at: 14) ?? 0
        self.SigmaLB  = data.item(at: 15) ?? 0
        self.SigmaSittingThreshold  = Int(data.item(at: 16) ?? 0)
        self.SigmaStandingThreshold  = Int(data.item(at: 17) ?? 0)
        self.CRCHighByte  = data.item(at: 18) ?? 0
        self.CRCLowByte  = data.item(at: 19) ?? 0
        
        let _minHeight = [self.ReportedMinHeightHB, self.ReportedMinHeightLB]
        let minHeightData = Data.init(_minHeight)
        self.ReportedMinHeight = Int(UInt16(bigEndian: minHeightData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _maxHeight = [self.ReportedMaxHeightHB, self.ReportedMaxHeightLB]
        let maxHeightData = Data.init(_maxHeight)
        self.ReportedMaxHeight = Int(UInt16(bigEndian: maxHeightData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _sittingPos = [self.ReportedSittingPosHB, self.ReportedSittingPosLB]
        let sittingPosData = Data.init(_sittingPos)
        self.ReportedSittingPos = Int(UInt16(bigEndian: sittingPosData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _standingPos = [self.ReportedStandingPosHB, self.ReportedStandingPosLB]
        let standingPostData = Data.init(_standingPos)
        self.ReportingStandingPos = Int(UInt16(bigEndian: standingPostData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _deskOvershoot = [self.DeskOvershootValueHB, self.DeskOvershootValueLB]
        let deskOvershootData = Data.init(_deskOvershoot)
        self.DeskOvershootValue = Int(UInt16(bigEndian: deskOvershootData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _deskHeight = [self.DeskHeightOffsetHB, self.DeskHeightOffsetLB]
        let deskHeightData = Data.init(_deskHeight)
        self.DeskHeightOffset = Int(UInt16(bigEndian: deskHeightData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let _sigma = [self.SigmaHB, self.SigmaLB]
        let sigmaData = Data.init(_sigma)
        self.Sigma = Int(UInt16(bigEndian: sigmaData.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
    }
}

struct CountData: CountProtocol {
    var Length: Int = 0
    var Command: Int = 0
    var DownMSB: UInt8 = 0
    var DownMid: UInt8 = 0
    var DownLSB: UInt8 = 0
    var UpMSB: UInt8 = 0
    var UpMid: UInt8 = 0
    var UpLSB: UInt8 = 0
    var watchdogTriggerCountHB: UInt8 = 0
    var watchdogTriggerCountLB: UInt8 = 0
    var cardResetCountHB: UInt8 = 0
    var cardResetCountLB: UInt8 = 0
    var CRCHighByte: UInt8 = 0
    var CRCLowByte: UInt8 = 0
    
    init(data: [UInt8], ec: EventCenter? = nil) {
        guard data.count > 0 else {
         return
        }
        
        self.Length = Int(data.item(at: 0) ?? 0)
        self.Command = Int(data.item(at: 1) ?? 0)
        self.DownMSB = data.item(at: 2) ?? 0
        self.DownMid = data.item(at: 3) ?? 0
        self.DownLSB = data.item(at: 4) ?? 0
        self.UpMSB = data.item(at: 5) ?? 0
        self.UpMid = data.item(at: 6) ?? 0
        self.UpLSB = data.item(at: 7) ?? 0
        self.watchdogTriggerCountHB = data.item(at: 8) ?? 0
        self.watchdogTriggerCountLB = data.item(at: 9) ?? 0
        self.cardResetCountHB = data.item(at: 10) ?? 0
        self.cardResetCountLB = data.item(at: 11) ?? 0
        self.CRCHighByte = data.item(at: 12) ?? 0
        self.CRCLowByte = data.item(at: 13) ?? 0
    }
}
