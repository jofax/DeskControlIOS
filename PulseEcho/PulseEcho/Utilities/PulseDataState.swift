//
//  PulseDataInstance.swift
//  PulseEcho
//
//  Created by Joseph on 2021-04-22.
//  Copyright © 2021 Smartpods. All rights reserved.
//

import Foundation
import Moya
import CommonCrypto

/// A  protocol to update the UI when an event occurs
protocol PulseDataStateDelegate: class {
    func notificationAlertMessages(title: String, message: String)
}

class PulseDataState: ReflectedStringConvertible{
    
    var currentHeight: Int = 0
    var standHeight: Int = 0
    var sittingHeight: Int = 0
    var sittingHeightTruncated: Bool = false
    var standHeightTruncated: Bool = false
    var movesReported: Int = 0
    var profileRawString = ""
    var delegate: PulseDataStateDelegate?
    
    var userProfileSittingHeight = 0
    var userProfileStandingHeight = 0
    var desktopApphasPriority: Bool = false
    var isDeskCurrentlyBooked: Bool = false
    var isDeskHasIncomingBooking = false
    var isDeskEnabled = false
    
    var bookingSchedulerCount = 0
    var bookingSchedulerLimit = 1
    
    var deskCurrentlyBookAlertCount = 0
    var deskCurrentlyBookAlertLimit = 1
    
    
    var heightsAdjusted: Bool = false
    
    var commitProfileCount = 0
    let commitProfileLimit = 2
    
    var truncatedAlertShown = 0
    var truncatedAlertShownLimit = 1
    
    var boxSerial: String = Utilities.instance.getObjectFromUserDefaults(key: "serialNumber") as? String ?? ""
    var DeskID: UInt32 = 0
    var DeskBytes = [UInt8]()
    
    lazy var SPCommand = PulseCommands()
    lazy var dataHelper = SPRealmHelper()
    lazy var profileViewModel = ProfileSettingsViewModel()
    
    var serverProvider: MoyaProvider<DataPushService>?
    
//    static let instance: PulseDataState = {
//        let instance = PulseDataState()
//        return instance
//    }()
    static let instance = PulseDataState()
        
    private init() {}
    
    func PulseDataValues() {
        let dataProperties = self
        print("dataProperties : \(dataProperties.reflectedDescription(Style.normal))")
    }
    
    func adjustSittingAndStandHeights(profile: ProfileSettings) -> ProfileSettings {
        print("currentHeight : \(currentHeight)")
        
        print("sittingHeight : \(sittingHeight)")
        print("sittingHeightTruncated : \(sittingHeightTruncated)")
        
        print("standHeight : \(standHeight)")
        print("standHeightTruncated : \(standHeightTruncated)")
    
        print("user sitHeight: \(userProfileSittingHeight)")
        print("user standHeight: \(userProfileStandingHeight)")
        
        print("adjustSittingAndStandHeights Profile: \(profile)")
        
        let updateSittingHeight = (sittingHeight != profile.SittingPosition) && sittingHeightTruncated
        let updateStandHeight = (standHeight != profile.StandingPosition) && standHeightTruncated
        
        print("updateSittingHeight : \(updateSittingHeight)")
        print("updateStandHeight : \(updateStandHeight)")

        
        if updateStandHeight || updateSittingHeight {
            print("adjustSittingAndStandHeights update: \(updateStandHeight || updateSittingHeight)")
            //update profile in the settings
            
            let userProfile = SPCommand.CreateVerticalProfile(settings: profile)
            
            do {
                try SPBluetoothManager.shared.sendCommand(command: userProfile)
                print("PulseDataState | SPCommand.CreateVerticalProfile")
            } catch let error as NSError {
                
                if LOGS.BUILDTYPE.boolValue == false {
                    print("PulseDataState error sending  command: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                    print("PulseDataState device state: \(SPBluetoothManager.shared.state) | info: \(Utilities.instance.loginfo())")
                } else {
                    print("PulseDataState error sending  command: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                    print("PulseDataState device state: \(SPBluetoothManager.shared.state) | info: \(Utilities.instance.loginfo())")
                }
            } catch {
                if LOGS.BUILDTYPE.boolValue == false {
                    print("Unable to send command inside PulseDataState | info: \(Utilities.instance.loginfo())")
                } else {
                    print("Unable to send command inside PulseDataState | info: \(Utilities.instance.loginfo())")
                }
            }

            
            let pulseObj = ["UserProfile": self.profileRawString] as [String : Any]
            _  = dataHelper.updatePulseObject(pulseObj, Utilities.instance.getLoggedEmail())
            let newProfile =  dataHelper.updateUserProfileSettings(["SittingPosition": sittingHeight,
                                                                    "StandingPosition":standHeight], Utilities.instance.getLoggedEmail())
            
            userProfileSittingHeight = newProfile.SittingPosition
            userProfileStandingHeight = newProfile.StandingPosition

            
            //Submit new profile changes to cloud if user is not guest
            
            let current_logged = Utilities.instance.typeOfUserLogged()
            if (current_logged == .Cloud) {
//                profileViewModel.requestUpdateProfileSettings(newProfile.generateProfileParameters()) { data in
//                    Utilities.instance.appDelegate.debug("PulseDataState new profile push with data: \(data)")
//                }
            }
            
            
            return newProfile
        }
        
        return ProfileSettings()
    }
    
    func adjustSitAndStandHeights() {
        
        guard sittingHeightTruncated || standHeightTruncated else {
            return
        }
        
        
        let pulseObj = ["UserProfile": self.profileRawString] as [String : Any]
        _  = dataHelper.updatePulseObject(pulseObj, Utilities.instance.getLoggedEmail())
        _  =  dataHelper.updateUserProfileSettings(["SittingPosition": sittingHeight,
                                                    "StandingPosition":standHeight], Utilities.instance.getLoggedEmail())
    }
    
    func savePushCredentials(data: [String: Any]) {
        let email = Utilities.instance.getLoggedEmail()
        var _data = data
        _data["Serial"] = boxSerial
        _data["Email"] = email
        
        guard !boxSerial.isEmpty else {
            return
        }
        
        if dataHelper.credentialsExist(email: email, serial: boxSerial) {
            _ = dataHelper.updatePushCredentials(_data,
                                                 email,
                                                 boxSerial)
        } else {
            let _credentials = PulseDataPush(params: _data)
            _ = dataHelper.savePushCredentials(email,
                                               boxSerial, _credentials)
        }
    }
    
    func pushDataToCloud(data: SPServerData) {
        let packetArray = Utilities.instance.getArrayExtractDataObject(data: data.byteArray)
        
        dataHelper.retrievePulseDataPush(Utilities.instance.getLoggedEmail(),
                                         boxSerial) { (credentials, exist) in
            guard !credentials.AESKey.isEmpty && !credentials.AESIV.isEmpty else {
                return
            }
            
            let aesBytes = credentials.AESKey.hexaBytes
            let aesivBytes = credentials.AESIV.hexaBytes
            
            let aes = SPAESKey(data: aesBytes)
            let aesiv = SPAESIV(data: aesivBytes)
            
            var initialPacket: Array<UInt8> = [UInt8]()
            initialPacket.append(contentsOf: packetArray)
            
            let _packetCRC = Utilities.instance.convertDesktopCrc16(data: initialPacket).bigEndian.data.array
            
            initialPacket.append(contentsOf: _packetCRC)
            initialPacket.append(contentsOf: [255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255 ,255])
            
            print("_packet CRC 16 : \(Utilities.instance.convertDesktopCrc16(data: initialPacket))")
            print("_packetCRC16 array : \(_packetCRC)")
            print("initialPacket : \(initialPacket)")
            
            let encryptedPacket = Utilities.instance.aesCryptWith(data: Data(bytes: initialPacket, count: initialPacket.count),
                                                                  key: aes.AESKey,
                                                                  iv: aesiv.AESIV,
                                                                  option: CCOperation(kCCEncrypt))


            print("push encryptedPacket array: \(String(describing: encryptedPacket?.array))")
            
            
            var finalPacket = [UInt8]()
            finalPacket.append(contentsOf: self.DeskBytes)
            finalPacket.append(124)
            finalPacket.append(contentsOf: encryptedPacket?.array ?? [UInt8]())
            
            self.serverProvider = MoyaProvider<DataPushService>(requestClosure: MoyaProvider<DataPushService>.endpointRequestResolver(),
                                                           session: smartpodsManager(withSSL: true),
                                                           trackInflights: true)
            print("push finalPacket: \(finalPacket)")
            
            self.serverProvider?.request(.pushData(Data(finalPacket))) { result in
                    switch result {
                    case .success(let response):
                        let _responseData = response.data
                        print("response push data: \(_responseData.array)")
                        
                        guard _responseData.array.count > 0 else {
                            return
                        }
                        
                        let filterPacket = _responseData.array.slice(start: 5, end: _responseData.count - 1)
                        
                        let decryptPacket = Utilities.instance.aesCryptWith(data: Data(filterPacket),
                                                                            key: aes.AESKey,
                                                                            iv: aesiv.AESIV,
                                                                            option: CCOperation(kCCDecrypt))
                        
                        print("push response.data filterPacket: \(String(describing: filterPacket))")
                        print("push response.data decryptPacket: \(String(describing: decryptPacket?.array))")
                        
                        if let strResponse = String(bytes: decryptPacket?.array ?? [UInt8](), encoding: .ascii) {
                           //print("push ascci response: \(strResponse)")
                            if strResponse.contains("ack") {
                                print("push array response: \(String(describing: decryptPacket?.array))")
                                
                                if let bookPacket = decryptPacket {
                                    var _bookingPacket = bookPacket.array.slice(start: 5, end: bookPacket.count - 7)
                                    //let _isLoggedin = bookingInfo.IsLoggedIn ? 1 : 0
                                    
                                    var bookingPacket: [UInt8] = [10, 17, 96]
                                    bookingPacket.append(contentsOf: _bookingPacket)
                                    let crc = Utilities.instance.convertCrc16(data: bookingPacket).bigEndian.data.array
                                    bookingPacket.append(contentsOf: crc)
                                    
                                    do {
                                        try SPBluetoothManager.shared.sendCommand(command: bookingPacket)
                                        print("ATTEMP_BOOKING_PACKET_SERVER_PUSH")
                                    } catch let error as NSError {
                                        if LOGS.BUILDTYPE.boolValue == false {
                                            print("BOOKING_PACKET_SERVER_PUSH error sending  command: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                                            print("BOOKING_PACKET_SERVER_PUSH device state: \(SPBluetoothManager.shared.state) | info: \(Utilities.instance.loginfo())")
                                        } else {
                                            print("BOOKING_PACKET_SERVER_PUSH error sending  command: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                                            print("BOOKING_PACKET_SERVER_PUSH device state: \(SPBluetoothManager.shared.state) | info: \(Utilities.instance.loginfo())")
                                        }
                                    } catch {
                                        if LOGS.BUILDTYPE.boolValue == false {
                                            print("Unable to send command BOOKING_PACKET_SERVER_PUSH | info: \(Utilities.instance.loginfo())")
                                        } else {
                                            print("Unable to send command BOOKING_PACKET_SERVER_PUSH | info: \(Utilities.instance.loginfo())")
                                        }
                                    }
                                    
                                }
                                
                            }
                        }
                        
                    case .failure(let error):
                        if LOGS.BUILDTYPE.boolValue == false {
                            print("pushData error : \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                            print("pushData error code : \(error.errorCode) | info: \(Utilities.instance.loginfo())")
                        } else {
                            print("pushData error : \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                            print("pushData error code : \(error.errorCode) | info: \(Utilities.instance.loginfo())")
                        }
                    }
                }
        }
        
    }
    
    func checkDeskBookingInformation() {
        let deskServiceViewModel = DeskViewModel()
        
        dataHelper.retrievePulseDataPush(Utilities.instance.getLoggedEmail(),
                                         boxSerial) { (credentials, exist) in
            guard !credentials.AESKey.isEmpty && !credentials.AESIV.isEmpty else {
                return
            }
            
            guard let randomIV = Data().randomGenerateBytes(count: kCCBlockSizeAES128) else { return }
            
            guard self.boxSerial.isEmpty == false else { return }
            
            let aesBytes = credentials.AESKey.hexaBytes
            let aes = SPAESKey(data: aesBytes)
            
            
            let dataSerial = self.boxSerial.data(using: .utf8)!
            
            let encryptedPacket = Utilities.instance.aesCryptWith(data: dataSerial,
                                                                  key: aes.AESKey,
                                                                  iv: randomIV,
                                                                  option: CCOperation(kCCEncrypt))
            
            
            print("checkDeskBookingInformation array: \(String(describing: encryptedPacket?.array))")
            
            let deskBookingObj = DeskBooking(SerialNumber: self.boxSerial,
                                             EncryptedData: encryptedPacket?.array ?? [UInt8](),
                                             Iv: randomIV.base64EncodedString())
            
            deskServiceViewModel.requestDeskBookingInformation(deskBookingObj) { DeskBookingInfo in
                print("checkDeskBookingInformation DeskBookingInfo: \(DeskBookingInfo))")
                var alertMessage = ""
                
                if (DeskBookingInfo.BookingId != 0) {
                    let _dateBook = Utilities.instance.getBookingTime(bookingDate: DeskBookingInfo.BookingDate,
                                                                      periods: DeskBookingInfo.Periods,
                                                                      offset: DeskBookingInfo.TzOffset)
                    
                    let startTime = _dateBook["BookFrom"] ?? Date()
                    let endTime = _dateBook["BookTo"] ?? Date()
                    
                    let dateformat = DateFormatter()
                    dateformat.dateStyle = .medium
                    
                    let bookingDate =  dateformat.string(from: startTime)
                    
                    let timeFormat = DateFormatter()
                    timeFormat.dateFormat = "h:mm a"
                    
                    let startTimeDate =  timeFormat.string(from: startTime)
                    let endTimeDate =  timeFormat.string(from: endTime)
                    
                    let username = DeskBookingInfo.Email.stringBefore(Character("@"))
                    
                    alertMessage = String(format: "%@ %@ on %@, from %@ to %@. %@", "generic.desk_has_incoming_booking".localize(), username, bookingDate, startTimeDate, endTimeDate, "generic.clean_desk".localize())
                    
                    BaseController().showAlert(title: "generic.notice".localize(), message:alertMessage)
                    
                }
            }
            
        }
        
        
    }
}

