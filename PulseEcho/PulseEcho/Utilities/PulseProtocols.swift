//
//  PulseProtocols.swift
//  PulseEcho
//
//  Created by Joseph on 2020-08-18.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation

/****************************************************** NEW BLE STRING DATA **************************************************************************/

protocol PulseCore: ReflectedStringConvertible {
    /** BLE STRINGS **/
    var Length: Int { get set }
    var Command: Int { get set }
    var ReportedVerPosHB: UInt8 { get set }
    var ReportedVerPosLB: UInt8  { get set }
    var MainTimerCycleSecondsHB: UInt8 { get set }
    var MainTimerCycleSecondsLB: UInt8 { get set }
    var MovesreportedVertPos: UInt8 { get set }
    var CondensedStatusOne: Int { get set }
    var CondensedStatusTwo: Int { get set }
    var CondensedStatusThree: Int { get set }
    var CondensedEnableOne: Int { get set }
    var CondensedEnableTwo: Int { get set }
    var WifiSyncStatus: UInt8 { get set }
    var PendingMoveAndSlider: UInt8 { get set }
    var SliderComboTwo: UInt8 { get set }
    var SliderComboThree: UInt8 { get set }
    var CRCHighByte: UInt8 { get set}
    var CRCLowByte: UInt8 { get set}
    /** END BLE STRINGS **/
    
    var ReportedVertPos: Int { get set }
    var MainTimerCycleSeconds: Int { get set }
    var TimesreportedVertPos: Int { get set }
    var NextMove: Int { get set }
    
    var WifiStatus: Int { get set }
    var AdapterError: Int { get set }
    
    var PendingMove: Int { get set }
    var LEDSlider: Int { get set }
    
    var SitPresence: Int { get set }
    var StandPresence: Int { get set }
    
    var AwaySlider: Int { get set }
    var SafetySlider: Int { get set }
    
    var RunSwitch: Bool { get set}
    var SafetyStatus: Bool { get set}
    var AwayStatus: Bool { get set}
    var Movingdownstatus: Bool { get set}
    var Movingupstatus: Bool { get set}
    var HeightSensorStatus: Bool { get set}
    var AlternateCalibrationMode: Bool { get  set}
    var AlternateAITBMode: Bool { get set}
    var NewInfoData: Bool { get set }
    var NewProfileData: Bool { get set }
    
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

protocol PulseVerticalProfileProtocol: ReflectedStringConvertible {
    
    /** BLE STRINGS **/
    var Length: Int { get set }
    var Command: Int { get set }
    var MoveOneCombo: UInt8 { get set }
    var MoveTwoCombo: UInt8 { get set }
    var MoveThreeCombo: UInt8 { get set }
    var MoveFourCombo: UInt8 { get set }
    var SittingPosHB: UInt8 { get set }
    var SittingPosLB: UInt8 { get set }
    var StandingHB: UInt8 { get set }
    var StandingLB: UInt8 { get set }
    var MinHeightHB: UInt8 { get set }
    var MinHeightLB: UInt8 { get set }
    var MaxHeightHB: UInt8 { get set }
    var MaxHeightLB: UInt8 { get set }
    var DeskHeightOffset: Int { get set }
    var DeskOverShoot: Int { get set }
    var CRCHighByte: UInt8 { get set}
    var CRCLowByte: UInt8 { get set}
    /** END BLE STRINGS **/
    
}

protocol PulseIdentifierProtocol: ReflectedStringConvertible {
    
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
    var UpdateDownCount2: UInt8 { get set }
    var UpdateDownCount1: UInt8 { get set }
    var UpdateDownCount0: UInt8 { get set }
    var RegistrationID3: UInt8 { get set }
    var RegistrationID2: UInt8 { get set }
    var RegistrationID1: UInt8 { get set }
    var RegistrationID0: UInt8 { get set }
    var CRCHighByte: UInt8 { get set}
    var CRCLowByte: UInt8 { get set}
    /** END BLE STRINGS **/
}

protocol PulseReportProtocol: ReflectedStringConvertible {
    
    /** BLE STRINGS **/
    var Length: Int { get set }
    var Command: Int { get set }
    var ReportingTime: Int { get set }
    var YAxisAccRead: Int { get set }
    var TemperatureOutput: Int { get set }
    var PhotocellReading: Int { get set }
    var DbReading: Int { get set }
    var SigmaHB: UInt8 { get set }
    var SigmaLB: UInt8 { get set }
    var RowSelectorSitting: Int { get set}
    var ColumnSelectorSitting: Int { get set }
    var RowSelectorStanding: Int { get set }
    var ColumnSelectorStanding: Int { get set }
    var CRCHighByte: UInt8 { get set}
    var CRCLowByte: UInt8 { get set}
    /** END BLE STRINGS **/

}

protocol PulseServerDataProtocol: ReflectedStringConvertible {
    var Length: Int { get set }
    var Command: Int { get set }
    var PushFrequency:  UInt8 { get set }
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
    var SafetyTriggerTallyStorage: UInt8 { get set }
    var UpDownTallyStorage: UInt8 { get set }
    var CurrentDeskAvailability: UInt8 { get set }
    var CRCHighByte: UInt8 { get set}
    var CRCLowByte: UInt8 { get set}
}

protocol PulseAESKeyProtocol: ReflectedStringConvertible {
    var Length: Int { get set }
    var Command: Int { get set }
    var PayloadAESKey0: UInt8 { get set }
    var PayloadAESKey1: UInt8 { get set }
    var PayloadAESKey2: UInt8 { get set }
    var PayloadAESKey3: UInt8 { get set }
    var PayloadAESKey4: UInt8 { get set }
    var PayloadAESKey5: UInt8 { get set }
    var PayloadAESKey6: UInt8 { get set }
    var PayloadAESKey7: UInt8 { get set }
    var PayloadAESKey8: UInt8 { get set }
    var PayloadAESKey9: UInt8 { get set }
    var PayloadAESKey10: UInt8 { get set }
    var PayloadAESKey11: UInt8 { get set }
    var PayloadAESKey12: UInt8 { get set }
    var PayloadAESKey13: UInt8 { get set }
    var PayloadAESKey14: UInt8 { get set }
    var PayloadAESKey15: UInt8 { get set }
    var CRCHighByte: UInt8 { get set}
    var CRCLowByte: UInt8 { get set}
}

protocol PulseAESIVProtocol: ReflectedStringConvertible {
    var Length: Int { get set }
    var Command: Int { get set }
    var PayloadAESIV0: UInt8 { get set }
    var PayloadAESIV1: UInt8 { get set }
    var PayloadAESIV2: UInt8 { get set }
    var PayloadAESIV3: UInt8 { get set }
    var PayloadAESIV4: UInt8 { get set }
    var PayloadAESIV5: UInt8 { get set }
    var PayloadAESIV6: UInt8 { get set }
    var PayloadAESIV7: UInt8 { get set }
    var PayloadAESIV8: UInt8 { get set }
    var PayloadAESIV9: UInt8 { get set }
    var PayloadAESIV10: UInt8 { get set }
    var PayloadAESIV11: UInt8 { get set }
    var PayloadAESIV12: UInt8 { get set }
    var PayloadAESIV13: UInt8 { get set }
    var PayloadAESIV14: UInt8 { get set }
    var PayloadAESIV15: UInt8 { get set }
    var CRCHighByte: UInt8 { get set}
    var CRCLowByte: UInt8 { get set}
}
