//
//  BoxDataProtocols.swift
//  SPBluetooth
//
//  Created by Joseph on 2020-02-11.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation

//ENUM

enum MovementType: Int {
    case DOWN = 7
    case UP = 4
    case INVALID = 100
    
    var movement: String {
        switch self {
        case .DOWN:
          return "DOWN"
        case .UP:
          return "UP"
        case .INVALID:
          return "INVALID"
        }
    }
    
    var readableMovement: String {
        switch self {
        case .DOWN:
          return "Sit"
        case .UP:
          return "Stand"
        case .INVALID:
          return "INVALID"
        }
    }
    
    var movementRawString: String {
        switch self {
        case .DOWN:
          return "7"
        case .UP:
          return "4"
        case .INVALID:
          return "100"
        }
    }
}

protocol Loopable {
    var allProperties: [String: Any] { get }
    
}
extension Loopable {
    var allProperties: [String: Any] {
        var result = [String: Any]()
        Mirror(reflecting: self).children.forEach { child in
            if let property = child.label {
                result[property] = child.value
            }
        }
        return result
    }
}


extension NSString: Loopable {}

// PROTOCOL OBJECTS NEW INTERFACE

protocol CoreOneProtocol: ReflectedStringConvertible {
    
    /** BLE STRINGS **/
    var Length: Int { get set }
    var Command: Int { get set }
    var ReportedVerPosHB: UInt8 { get set }
    var ReportedVerPosLB: UInt8 { get set }
    var MainTimerCycleSecondsHB: UInt8 { get set }
    var MainTimerCycleSecondsLB: UInt8 { get set }
    var MovesreportedVertPos: Int { get set }
    var TimesreportedVertPosHB: UInt8 { get set }
    var TimesreportedVertPosLB: UInt8 { get set }
    var PendingMovementCode: Int { get set }
    var CondensedStatusOne: Int { get set }
    var CondensedStatusTwo: Int { get set }
    var CondensedEnableOne: Int { get set }
    var CondensedEnableTwo: Int { get set }
    var WifiSyncStatus: Int { get set }
    var CondensedWifi: Int { get set }
    var LoopTimeElapsed: Int { get set}
    var CRCHighByte: UInt8 { get set}
    var CRCLowByte: UInt8 { get set}
    /** END BLE STRINGS **/
    
    var ReportedVertPos: Int { get set }
    var MainTimerCycleSeconds: Int { get set }
    var TimesreportedVertPos: Int { get set }
    
    var RunSwitch: Bool { get set}
    var SafetyStatus: Bool { get set}
    var AwayStatus: Bool { get set}
    var Movingdownstatus: Bool { get set}
    var Movingupstatus: Bool { get set}
    var HeightSensorStatus: Bool { get set}
    var AlternateCalibrationMode: Bool { get  set}
    var AlternateAITBMode: Bool { get set}
    
    var EnableTwoStageCalibration: Bool { get }
    var EnableHeatSenseFlipSitting: Bool { get }
    var EnableHeatSenseFlipStanding: Bool { get }
    var EnableMotionDetection: Bool { get }
    var EnableTiMotionBus: Bool { get }
    var EnableSafety: Bool { get }
    var UserAuthenticated: Bool { get }
    var UseInteractiveMode: Bool { get }
    
    var AppRxFailFlag: Bool { get }
    var WifiTxpushFailure: Bool { get }
    var WeAreSitting: Bool { get }
    var ObstructionStatus: Bool { get }
    var CommissioningFlag: Bool { get }
    var HeartBeatOut: Bool { get }
}

protocol CoreTwoProtocol: ReflectedStringConvertible {
    
    /** BLE STRINGS **/
    var Length: Int { get set }
    var Command: Int { get set }
    var AppLEDIntensity: Int { get set }
    var AppReadingLightIntensity: Int { get set}
    var AppAwayAdjust: Int { get set}
    var AppSigmaSittingThreshold: Int { get set}
    var AppSigmaStandingThreshold: Int { get set }
    var AppSafetySensitivity: Int { get set}
    var RowSelectorSitting: Int { get set}
    var ColumnSelectorSitting: Int { get set}
    var RowSelectorStanding: Int { get set}
    var ColumnSelectorStanding: Int { get set}
    var TiMotionErrorCodeToPrint: Int { get set}
    var ErrorIDHB: UInt8 { get set}
    var ErrorIDLB: UInt8 { get set}
    var CRCHighByte: UInt8 { get set}
    var CRCLowByte: UInt8 { get set}
    /** END BLE STRINGS **/
}

protocol ReportOneProtocol: ReflectedStringConvertible {
    
    /** BLE STRINGS **/
    var Length: Int { get set }
    var Command: Int { get set }
    var StatusTimerHours: Int { get set }
    var StatusTimerMinutes: Int { get set }
    var StatusTimerSeconds: Int { get set }
    var ReportingTime: Int { get set }
    var TimeReportingIndex: Int { get set }
    var YAxisAccReadHB: UInt8 { get set }
    var YAxisAccReadLB: UInt8 { get set }
    var TemperatureOutputHB: UInt8 { get set }
    var TemperatureOutputLB: UInt8 { get set }
    var PhotocellReadingHB: UInt8 { get set }
    var PhotocellReadingLB: UInt8 { get set }
    var DbReadingHB: UInt8 { get set }
    var DbReadingLB: UInt8 { get set }
    var CRCHighByte: UInt8 { get set}
    var CRCLowByte: UInt8 { get set}
    /** END BLE STRINGS **/
    
    var YAxisAccRead: Int { get set }
    var TemperatureOutput: Int { get set }
    var PhotocellReading: Int { get set }

}


protocol ReportTwoProtocol: ReflectedStringConvertible {
    
    /** BLE STRINGS **/
    var Length: Int { get set }
    var Command: Int { get set }
    var SitTimeStorageHB: UInt8 { get set }
    var SitTimeStorageLB: UInt8 { get set }
    var StandTimeStorageHB: UInt8 { get set }
    var StandTimeStorageLB: UInt8 { get set }
    var AwayTimeStorageHB: UInt8 { get set }
    var AwayTimeStorageLB: UInt8 { get set }
    var AutomaticTimeStorageHB: UInt8 { get set }
    var AutomaticTimeStorageLB: UInt8 { get set }
    var InteractiveTimeStorageHB: UInt8 { get set }
    var InteractiveTimeStorageLB: UInt8 { get set }
    var ManualTimeStorageHB: UInt8 { get set }
    var ManualTimeStorageLB: UInt8 { get set }
    var SafetyTriggerTallyStorage: Int { get set }
    var UpDownTallyStorage: Int { get set }
    var DetectionTransitionTallyStorage: Int { get set }
    var CRCHighByte: UInt8 { get set}
    var CRCLowByte: UInt8 { get set}
    /** END BLE STRINGS **/
    
    var SitTime: Int { get  set }
    var StandTime: Int { get  set }
    var AwayTime: Int { get  set }
    var AutomaticTime: Int { get  set }
    var SemiAutomaticTime: Int { get  set }
    var ManualTime: Int { get  set }
    var SafetyIncrement: Int { get  set }
    var UpDownIncrement: Int { get  set }
    var DetectionThresholdTally: Int { get  set }
    
}

protocol VerticalProfileProtocol: ReflectedStringConvertible {
    
    /** BLE STRINGS **/
    var Length: Int { get set }
    var Command: Int { get set }
    var MoveOne: Int { get set }
    var TimeOneHB: UInt8 { get set }
    var TimeOneLB: UInt8 { get set }
    var MoveTwo: Int { get set }
    var TimeTwoHB: UInt8 { get set }
    var TimeTwoLB: UInt8 { get set }
    var MoveThree: Int { get set }
    var TimeThreeHB: UInt8 { get set }
    var TimeThreeLB: UInt8 { get set }
    var MoveFour: Int { get set }
    var TimeFourHB: UInt8 { get set }
    var TimeFourLB: UInt8 { get set }
    var CRCHighByte: UInt8 { get set}
    var CRCLowByte: UInt8 { get set}
    /** END BLE STRINGS **/
    
    var movements: [[String: Any]] {get set}
    var movement0: String { get set }
    var movement1: String { get set }
    var movement2: String { get set }
    var movement3: String { get set }
    var movementRawString: String { get set }
    
}

protocol IdentifierProtocol: ReflectedStringConvertible {
    
    /** BLE STRINGS **/
    var Length: Int { get set }
    var Command: Int { get set }
    var DeskIDMSB: UInt8 { get set }
    var DeskIDByte3: UInt8 { get set }
    var DeskIDByte2: UInt8 { get set }
    var DeskIDLSB: UInt8 { get set }
    var VersionNumberMSB: UInt8 { get set }
    var VersionNumberByte: UInt8 { get set }
    var VersionNumberByte2: UInt8 { get set }
    var VersionNumberLSB: UInt8 { get set }
    var VersionBoardType: UInt8 { get set }
    var CRCHighByte: UInt8 { get set}
    var CRCLowByte: UInt8 { get set}
    /** END BLE STRINGS **/
    
    var SerialNumber: String { get set }
    var Version: String { get set}
}

protocol BoxHeightProtocol: ReflectedStringConvertible {
    
    /** BLE STRINGS **/
    var Length: Int { get set }
    var Command: Int { get set }
    var ReportedMinHeightHB: UInt8 { get set }
    var ReportedMinHeightLB: UInt8 { get set }
    var ReportedMaxHeightHB: UInt8 { get set }
    var ReportedMaxHeightLB: UInt8 { get set }
    var ReportedSittingPosHB: UInt8 { get set }
    var ReportedSittingPosLB: UInt8 { get set }
    var ReportedStandingPosHB: UInt8 { get set }
    var ReportedStandingPosLB: UInt8 { get set }
    var DeskOvershootValueHB: UInt8 { get set }
    var DeskOvershootValueLB: UInt8 { get set }
    var DeskHeightOffsetHB: UInt8 { get set }
    var DeskHeightOffsetLB: UInt8 { get set }
    var SigmaHB: UInt8 { get set }
    var SigmaLB: UInt8 { get set }
    var SigmaSittingThreshold: Int { get set }
    var SigmaStandingThreshold: Int { get set }
    var CRCHighByte: UInt8 { get set}
    var CRCLowByte: UInt8 { get set}
    /** END BLE STRINGS **/
    
    var ReportedMinHeight: Int { get set }
    var ReportedMaxHeight: Int  { get set }
    var ReportedSittingPos: Int { get set }
    var ReportingStandingPos: Int { get set }
    var DeskOvershootValue: Int { get set }
    var DeskHeightOffset: Int { get set }
    
    var Sigma: Int { get set }
}

protocol CountProtocol: ReflectedStringConvertible {
    var Length: Int { get set }
    var Command: Int { get set }
    var DownMSB: UInt8 { get set }
    var DownMid: UInt8 { get set }
    var DownLSB: UInt8 { get set }
    var UpMSB: UInt8 { get set }
    var UpMid: UInt8 { get set }
    var UpLSB: UInt8 { get set }
    var watchdogTriggerCountHB: UInt8 { get set }
    var watchdogTriggerCountLB: UInt8 { get set }
    var cardResetCountHB: UInt8 { get set }
    var cardResetCountLB: UInt8 { get set }
    var CRCHighByte: UInt8 { get set }
    var CRCLowByte: UInt8 { get set }
}

/******************************************  OLD INTERFACE *************************************************/


// PROTOCOL OBJECTS OLD INTERFACE
protocol CoreObjectProtocol {
    var ReportedVertPos: Int { get set }
    var MainTimerCycleSeconds: Int { get set }
    var MovesreportedVertPos: Int { get set }
    var TimesreportedVertPos: Int { get set }
    var CondensedStatus: Int { get  set }
    var CondensedEnable: Int { get set }
    var AppLEDIntensity: Int { get set }
    var AppReadingLightIntensity: Int { get set}
    var AppAwayAdjust: Int { get set}
    var AppSigmaSittingThreshold: Int { get set}
    var AppSigmaStandingThreshold: Int { get set }
    var AppSafetySensitivity: Int { get set}
    var LoopTimeElapsed: Int { get set}
    var LastCommandStatus: Bool { get set}
    
    var RunSwitch: Bool { get set}
    var SafetyStatus: Bool { get set}
    var AwayStatus: Bool { get set}
    var Movingdownstatus: Bool { get set}
    var Movingupstatus: Bool { get set}
    var HeightSensorStatus: Bool { get set}
    var AlternateCalibrationMode: Bool { get  set}
    var AlternateAITBMode: Bool { get set}
    
    var EnableTwoStageCalibration: Bool { get }
    var EnableHeatSenseFlipSitting: Bool { get }
    var EnableHeatSenseFlipStanding: Bool { get }
    var EnableMotionDetection: Bool { get }
    var EnableTiMotionBus: Bool { get }
    var EnableSafety: Bool { get }
    var UserAuthenticated: Bool { get }
    var UseInteractiveMode: Bool { get }
}

protocol SensorObjectProtocol {
    var YAxisAccRead: Int { get set }
    var TemperatureOutput: Int { get set }
    var PhotocellReading: Int { get set }
    var DbReading: Int { get set }
    var Sigma: Int { get set }
    var SigmaSittingThreshold: Int { get set }
    var SigmaStandingThreshold: Int { get set }
    var RowSelectorSitting: Int { get set }
    var ColumnSelectorSitting: Int { get set }
    var RowSelectorStanding: Int { get set }
    var ColumnSelectorStanding: Int { get set }
    var TiMotionErrorCodeToPrint: Int { get set }
    var ErrorID: Int { get set }
    var LastCommandStatus: Bool { get set}
    
}

protocol HeightObjectProtocol {
    var ReportedMinHeight: Int { get set }
    var ReportedMaxHeight: Int  { get set }
    var ReportedSittingPos: Int { get set }
    var ReportingStandingPos: Int { get set }
    var DeskOvershootValue: Int { get set }
    var DeskHeightOffset: Int { get set }
    var CommissioningFlag: Bool { get set }
    var WeAreSitting: Bool { get set }
    var PendingMovementCode: Int { get set }
    var HeartBeatOut: Bool { get set }
    var LastCommandStatus: Bool { get set}
    
}

protocol IdentifierObjectProtocol {
    var SerialNumber: String { get set }
    var Version: String { get set}
    var LastCommandStatus: Bool { get set}
}

protocol DataStringObjectProtocol {
    var StatusTimerHours: Int { get set }
    var StatusTimerMinutes: Int { get  set }
    var StatusTimerSeconds: Int { get  set }
    var ReportingTime: Int { get  set }
    var TimeReportingIndex: Int { get  set }
    var SitTime: Int { get  set }
    var StandTime: Int { get  set }
    var AwayTime: Int { get  set }
    var AutomaticTime: Int { get  set }
    var SemiAutomaticTime: Int { get  set }
    var ManualTime: Int { get  set }
    var SafetyIncrement: Int { get  set }
    var UpDownIncrement: Int { get  set }
    var DetectionThresholdTally: Int { get  set }
    var CondensedWifi: Int { get  set }
    var LastConnStat: Int { get  set }
    var LastCommandStatus: Bool { get set}
}

protocol VerticalMoveObjectProtocol {
    var ProfileCommited: Bool { get set }
    var movements: [[String: Any]] {get set}
    var movement0: String { get set }
    var movement1: String { get set }
    var movement2: String { get set }
    var movement3: String { get set }
    var movementRawString: String { get set }
    var LastCommandStatus: Bool { get set}
    
//    func createMovement(string: String) -> [String: Any]
//    func checkValidMovement(str: String) -> Bool
}

protocol CountsObjectProtocol {
    var EEPROMReadCycleCounts_1: Int { get set }
    var EEPROMReadCycleCounts_4: Int { get set }
    var WatchdogTriggerCount: Int { get set }
    var CardResetCount: Int { get set }
    var LastCommandStatus: Bool { get set}
}
