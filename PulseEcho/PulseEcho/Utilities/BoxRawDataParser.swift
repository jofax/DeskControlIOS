//
//  BoxRawDataParser.swift
//  PulseEcho
//
//  Created by Joseph on 2020-07-07.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import EventCenter
import SwiftEventBus


var presenceSentCount = 0
var presenceSentLimit = 2

struct BLEDataParser {
    
    func initWithString(raw: String) {

        let data = raw.split(separator: "-").map{ UInt8( $0)! }
        parseItem(byteArr: data, raw: raw)
    }
    
    func initWithHexString(raw: String) {
        let data = raw.hexaBytes
        //print("data string: ", data)
        guard data.count > 0 else {
            return
        }
        
        parseItem(byteArr: data, raw: raw)
    }
    
    func parseItem(byteArr: [UInt8], raw: String) {
        guard byteArr.count > 0 else {
            return
        }
        //print("parseItemRaw: ", raw)
        let length = Int(byteArr.item(at: 0) ?? 0)
        let header = Int(byteArr.item(at: 1) ?? 0)
        var dataRepresentation: String = ""
        guard checkCrc16(byteArr: byteArr) else {
            if LOGS.BUILDTYPE.boolValue == false {
                print("invalid crc: \(byteArr) | info: \(Utilities.instance.loginfo())")
            } else {
                print("invalid crc: \(byteArr) | info: \(Utilities.instance.loginfo())")
            }
            return
        }
        
        //print("*****************************************************************************************************************************************")
        if raw.hasPrefix("1405") || raw.hasPrefix("1414") || raw.hasPrefix("1415") {
            print("raw: \(header)")
        }
        
        switch header {
            case 1:
               guard (length == 20) else {
                    break
                }
                let core = SPCoreObject(data: byteArr)
                if LOGS.BLELOGS.boolValue {
                    print("---------------------------------------------------------------------")
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("core : \(core) | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("core : \(core) | info: \(Utilities.instance.loginfo())")
                    }
                    print("---------------------------------------------------------------------")
                }
                
                //print("core.HeartBeatOut: ", core.HeartBeatOut)
                SPBluetoothManager.shared.PulseHeartbeatReconnectTimer.suspend()
                SPBluetoothManager.shared.PulseDeviceReconnectWhenTimeout.suspend()
                if core.HeartBeatOut == true {
                    if let peripheral = SPBluetoothManager.shared.state.peripheral {
                        SPBluetoothManager.shared.sendHeartBeat(peripheral, peripheral.spDesiredCharacteristic!)
                    }
                } else {
                    SPBluetoothManager.shared.heartBeatSentCount = 0
                }
                
                //print("core.NeedPresenceCapture: ", core.NeedPresenceCapture)
                //print("presenceSentCount: ", presenceSentCount)
                
                if core.NeedPresenceCapture == true {
                    if presenceSentCount < presenceSentLimit && presenceSentCount != presenceSentLimit {
                        presenceSentCount += 1
                        if let peripheral = SPBluetoothManager.shared.state.peripheral {
                           SPBluetoothManager.shared.requestWriteToCharacteristic(SPRequestParameters.CaptureAutomaticDetection, peripheral, peripheral.spDesiredCharacteristic!)
                        }
                    } else {
                        presenceSentCount = 0
                    }
                }
                
                PulseDataState.instance.sittingHeightTruncated = core.SitHeightAdjusted
                PulseDataState.instance.standHeightTruncated = core.StandHeightAdjusted
                PulseDataState.instance.currentHeight = core.ReportedVertPos
                PulseDataState.instance.movesReported = core.NextMove
                
                
                PulseDataState.instance.isDeskCurrentlyBooked = core.DeskCurrentlyBooked
                PulseDataState.instance.isDeskHasIncomingBooking = core.DeskUpcomingBooking
                PulseDataState.instance.isDeskEnabled = core.DeskEnabledStatus
                
                if (PulseDataState.instance.isDeskHasIncomingBooking) {
                    if PulseDataState.instance.bookingSchedulerCount < PulseDataState.instance.bookingSchedulerLimit && PulseDataState.instance.bookingSchedulerCount != PulseDataState.instance.bookingSchedulerLimit {
                        PulseDataState.instance.bookingSchedulerCount += 1
                       
                        print("booking scheduler timer exist")
                        
                        PulseDataState.instance.checkDeskBookingInformation()
                        
                    }
                } else {
                    PulseDataState.instance.bookingSchedulerCount = 0
                }
                
                if (core.SitHeightAdjusted == false && core.StandHeightAdjusted == false) {
                    PulseDataState.instance.truncatedAlertShown = 0
                }
                
                //log.debug("truncated sit: \(core.SitHeightAdjusted) | truncated stand: \(core.StandHeightAdjusted)")
                
                SwiftEventBus.postToMainThread(ViewEventListenerType.DeviceListStream.rawValue, sender: core)
                SwiftEventBus.postToMainThread(ViewEventListenerType.HomeDataStream.rawValue, sender: core)
                SwiftEventBus.postToMainThread(ViewEventListenerType.DeskDataStream.rawValue, sender: core)
                SwiftEventBus.postToMainThread(ViewEventListenerType.BaseViewDataStream.rawValue, sender: core)
                SwiftEventBus.postToMainThread(ViewEventListenerType.DeskModeDataStream.rawValue, sender: core)
                SwiftEventBus.postToMainThread(ViewEventListenerType.BoxControlDataStream.rawValue, sender: core)
                SwiftEventBus.postToMainThread(ViewEventListenerType.ActivityDataStream.rawValue, sender: core)
                SwiftEventBus.postToMainThread(ViewEventListenerType.BoxMainControlDataStream.rawValue, sender: core)
                dataRepresentation = core.reflectedDescription(Style.normal)
                
            case 2:
                guard (length == 20) else {
                    break
                }
                let report = SPReport(data: byteArr)
                if LOGS.BLELOGS.boolValue {
                    print("---------------------------------------------------------------------")
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("report : \(report) | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("report : \(report) | info: \(Utilities.instance.loginfo())")
                    }
                    print("---------------------------------------------------------------------")
                }
                SwiftEventBus.postToMainThread(ViewEventListenerType.HomeDataStream.rawValue, sender: report)
                SwiftEventBus.postToMainThread(ViewEventListenerType.BoxControlDataStream.rawValue, sender: report)
                dataRepresentation = report.reflectedDescription(Style.normal)
            case 3:
                guard (length == 20) else {
                        break
                    }
                
                let information = SPIdentifier(data: byteArr)
                if LOGS.BLELOGS.boolValue {
                    print("*********************************************************************")
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("information : \(information) | info: \(Utilities.instance.loginfo())")
                    } else {
                        print("information : \(information) | info: \(Utilities.instance.loginfo())")
                    }
                    print("*********************************************************************")
                }
                
                PulseDataState.instance.boxSerial = information.SerialNumber
                PulseDataState.instance.DeskID = information.DeskID
                PulseDataState.instance.DeskBytes = [information.DeskIDMSB,
                                                     information.DeskIDByte3,
                                                     information.DeskIDByte2,
                                                     information.DeskIDLSB]
                
                SwiftEventBus.postToMainThread(ViewEventListenerType.HomeDataStream.rawValue, sender: information)
                SwiftEventBus.postToMainThread(ViewEventListenerType.BaseViewDataStream.rawValue, sender: information)
                SwiftEventBus.postToMainThread(ViewEventListenerType.AppVersion.rawValue, sender: information)
                SwiftEventBus.postToMainThread(ViewEventListenerType.DeskDataStream.rawValue, sender: information)
                SwiftEventBus.postToMainThread(ViewEventListenerType.PairScreenDataStream.rawValue, sender: information)
                
                dataRepresentation = information.reflectedDescription(Style.normal)
            case 4:
                guard (length == 20) else {
                    break
                }
                let verticalMovements = SPVerticalProfile(data: byteArr, rawString: raw, notify: true)
                
                if LOGS.BLELOGS.boolValue {
                    print("---------------------------------------------------------------------")
                    if LOGS.BUILDTYPE.boolValue == false {
                        print("verticalMovements : \(verticalMovements) | info: \(Utilities.instance.loginfo())")
                    } else {
                       print("verticalMovements : \(verticalMovements) | info: \(Utilities.instance.loginfo())")
                    }
                    print("---------------------------------------------------------------------")
                }
                PulseDataState.instance.standHeight = verticalMovements.StandingPos
                PulseDataState.instance.sittingHeight = verticalMovements.SittingPos
                PulseDataState.instance.profileRawString = verticalMovements.movementRawString
                
                SwiftEventBus.postToMainThread(ViewEventListenerType.HomeDataStream.rawValue, sender: verticalMovements)
                SwiftEventBus.postToMainThread(ViewEventListenerType.DeskDataStream.rawValue, sender: verticalMovements)
                dataRepresentation = verticalMovements.reflectedDescription(Style.normal)
                
                print("PulseDataState.instance.sittingHeight : \(PulseDataState.instance.sittingHeight)")
                
                let updateSittingHeight = (PulseDataState.instance.sittingHeight != PulseDataState.instance.userProfileSittingHeight) && PulseDataState.instance.sittingHeightTruncated
                let updateStandHeight = (PulseDataState.instance.standHeight != PulseDataState.instance.userProfileStandingHeight) && PulseDataState.instance.standHeightTruncated
                
                //bool updateSittingHeight = (sittingPosition != userSittingProfilePos) && !cbCore1.SitHeightTruncated;

                if (updateSittingHeight || updateStandHeight) {
                    guard Utilities.instance.isBLEBoxConnected() && SPBluetoothManager.shared.desktopApphasPriority == false  else {
                        return
                    }
                    
                    guard Utilities.instance.isBLEBoxConnected() && PulseDataState.instance.isDeskCurrentlyBooked == false  else {
                        return
                    }
                    
                    let dataHelper = SPRealmHelper()
                    let email = Utilities.instance.getLoggedEmail()
                    
                    if dataHelper.profileExists(email) {
                        let _profile = dataHelper.getProfileSettings(email)
                        
                        if PulseDataState.instance.truncatedAlertShown < PulseDataState.instance.truncatedAlertShownLimit && PulseDataState.instance.truncatedAlertShown != PulseDataState.instance.truncatedAlertShownLimit {
                            PulseDataState.instance.truncatedAlertShown += 1
                            BaseController().showAlert(title: "generic.notice".localize(), message:"generic.desk_adjusted".localize())
                        }
                        
                        
                        //BaseController().showAlert(title: "generic.notice".localize(), message:"generic.desk_adjusted".localize())
                        //_ = PulseDataState.instance.adjustSittingAndStandHeights(profile: _profile)
                    }
                }
                
                print("profile sit: \(verticalMovements.SittingPos) | profile stand: \(verticalMovements.StandingPos)")
                
              
                
            case 5:
                guard (length == 20) else {
                    break
                }
                let serverData = SPServerData(data: byteArr)
                //log.debug("ServerData: \(serverData)")
                //log.debug("ServerData byteArr: \(byteArr)")
                //push data to cloud
                if Utilities.instance.typeOfUserLogged() == .Cloud {
                    PulseDataState.instance.pushDataToCloud(data: serverData)
                }
        
            case 20:
                guard (length == 20) else {
                    break
                }
                let AESData = SPAESKey(data: byteArr)
                //log.debug("AESData: \(AESData)")
                
                if Utilities.instance.typeOfUserLogged() == .Cloud {
                    PulseDataState.instance.savePushCredentials(data: ["AESKey": raw])
                }
                
            case 21:
                guard (length == 20) else {
                    break
                }
                let AESIVData = SPAESIV(data: byteArr)
                //log.debug("AESIVData: \(AESIVData)")
                
                
                if Utilities.instance.typeOfUserLogged() == .Cloud {
                    PulseDataState.instance.savePushCredentials(data: ["AESIV":raw])
                }
                
            default:
            break
        }
        
        //print("dataRepresentation: ", dataRepresentation)
    }
    
    func checkCrc16(byteArr: [UInt8]) -> Bool {
        
        guard byteArr.count > 2 else {
             return false
            
        }
        
        let crc = byteArr.suffix(from: byteArr.count-2)
        let crc16Data = Data.init(crc)
        let crc16 = Int(UInt16(bigEndian: crc16Data.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let newByteArr = byteArr.prefix(through: byteArr.count-3)
        let dataCrc16 = Int(Utilities.instance.convertCrc16(data: Array(newByteArr)))
        
        return dataCrc16 == crc16
    }
}
