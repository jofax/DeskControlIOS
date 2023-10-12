//
//  Utilities.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-03.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import SPAlert
import NotificationBannerSwift
import CommonCrypto

fileprivate struct _firstAppLaunchStaticData {
    static var alreadyCalled = false
    static var isFirstAppLaunch = true
    static let appAlreadyLaunchedString = "__private__appAlreadyLaunchedOnce"
}

class Utilities{
    static let instance = Utilities()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let dataHelper = SPRealmHelper()
    var isGuest: Bool = false
    var boxControlOpen = false
    var boxControlButtonTag = 0
    var IS_FREE_VERSION = false
    var invertStandingThreshold = 0
    var invertSittingThreshold = 0
    var newSurveyAvailable = false
    var isCalibrationOn = false
    var isMovingProgress = false
    var permissionViewShown = false
    var isAppNotificationBannerShowing = false
    var notificationBanner: StatusBarNotificationBanner? //= StatusBarNotificationBanner(title: "", style: .warning)
    let bannerQueueToDisplaySeveralBanners = NotificationBannerQueue(maxBannersOnScreenSimultaneously: 1)
    var testbanner: StatusBarNotificationBanner?  //= StatusBarNotificationBanner(title: "Desk is currently booked.", style: .warning)
    fileprivate init() {
        
    }
}

extension Utilities {
    
    /**
     Utility function to check if an email address is valid.
     
    - Parameters: String email
    - Returns: Bool value.
    */
    
    func checkEmailAddress(email: String) -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = email as NSString
            let results = regex.matches(in: email, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    /**
     Validate Values
    - Parameter [String: Any] params
    - Returns: Bool status
    */
    
    func checkValidInput(parameters: [[String:Any]]) throws -> Bool {
        for params in parameters {
            let key = params["key"] as? String ?? ""
            let val = params["value"] as? String ?? ""
            
            guard !val.isEmpty else {
                switch key {
                    case "username":
                        throw ValidationError.EmailRequired
                    case "password":
                        throw ValidationError.PasswordRequired
                    case "verify_password":
                        throw RegisterValidationError.VerifyPasswordRequired
                    case "old_password":
                        throw ForgotPasswordValidationError.OldPasswordRequired
                    case "new_password":
                        throw ForgotPasswordValidationError.NewPasswordRequired
                default:
                    return false
                }
            }
        }
        
        return true
    }
    
    /**
     Check user default value.
    - Parameter String key
    - Returns: Bool value
    */
    
    func checkDefault(key: String) -> Bool {
        let defaults = UserDefaults.standard
        return (defaults.object(forKey: key) != nil) ? true : false
    }
    
    /**
     Save an object in user defaults.
    - Parameter String key
    - Parameter Any value
    - Returns: none
    */
    
    func saveDefaultValueForKey(value: Any, key: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    /**
     Bool for key.
    - Returns: Bool
    */
    
    func getBoolObject(key: String) -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: key) 
    }
    
    /**
     Remove an object from user defaults.
    - Parameter String key
    - Returns: none
    */
    
    func removeObjectFromDefaults(key: String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
        defaults.synchronize()
    }
    
    /**
     Retrieve an object from user defaults.
    - Parameter String key
    - Returns: Any object
    */
    
    func getObjectFromUserDefaults(key: String) -> Any {
        let defaults = UserDefaults.standard
        if (defaults.object(forKey: key) != nil) {
            return defaults.object(forKey: key) ?? (Any).self
        } else {
            return (Any).self
        }
    }
    
    /**
     Retrieve an object from user defaults.
    - Parameter String key
    - Returns: Any object
    */
    
    func getStringFromUserDefaults(key: String) -> String {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: key) ?? ""
    }
    
    /**
     Retrieve session key from user defaults.
    - Parameter none
    - Returns: String session key
    */
    
    func getToken()-> String {
        
        let email = self.getUserEmail()
        let state = dataHelper.getAppState(email)
        
        return state.SessionKey
    }
    
    /**
     Retrieve session date from user defaults.
    - Parameter none
    - Returns: String session date
    */
    
    func getTokenGenerate() -> String {
        
        let email = self.getUserEmail()
        let state = dataHelper.getAppState(email)
        
        return state.SessionDated
    }
    
    /**
     Retrieve email address of the current logged user from user defaults.
    - Parameter none
    - Returns: String email address
    */
    
    func getUserEmail() -> String {
        let defaults =  UserDefaults.standard
        return defaults.string(forKey: Constants.email) ?? ""
    }
    
    /**
     Retrieve  current logged user type from user defaults.
    - Parameter none
    - Returns: String user type
    */
    
    func typeOfUserLogged() -> CURRENT_LOGGED_USER {
        let defaults = UserDefaults.standard
        let _type = defaults.string(forKey: Constants.current_logged_user_type) ?? ""
        
        return CURRENT_LOGGED_USER(rawValue: _type) ?? CURRENT_LOGGED_USER.None
        
    }
    
    func getLoggedEmail() -> String {
       return Utilities.instance.typeOfUserLogged() == .Guest ? "guest" : Utilities.instance.getUserEmail()
    }
    
    func loginfo() -> String {
       let email = Utilities.instance.typeOfUserLogged() == .Guest ? "guest" : Utilities.instance.getUserEmail()
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? ""
       return String(format: "email: %@ | uuid: %@", email, uuid)
    }
    
    /**
     Retrieve organization code of the current logged user from user defaults.
    - Parameter none
    - Returns: String organization code
    */
    
    func getOrgCode() -> String {
        let email = self.getUserEmail()
        let state = dataHelper.getAppState(email)
        
        return state.OrgCode
    }
    
    /**
     Check dates if session token is valid.
    - Parameter none
    - Returns: String email address
    */
    
    func isValidSessionToken() -> Bool {
        
        let email = self.getUserEmail()
        
        let _app_state = dataHelper.getAppState(email)
        let dateExpiry = _app_state.SessionExpiryDated
        
        print("dateExpiry : \(dateExpiry)")
        
        guard !dateExpiry.isEmpty else {
            return true
        }        
        
        let now = Date()
        let _now = ISO8601Time(date: now)
        let dateNow = _now.date
        print("dateNow: ", dateNow)
        print("dateNow descrption: \(_now.description())")

        let expiry = ISO8601Time(string: dateExpiry)
        let dateExpired = expiry.date
        print("dateExpired: ", dateExpired)
        print("expiry descrption: \(expiry.localDateTime())")
        
        print("VALID AUTH TOKEN: ", (dateExpired > dateNow))
        
        
        let _token_refreshed_date = expiry.localDateTime().nearestHalfHour
        print("_token_refreshed_date : \(_token_refreshed_date)")
        
        let dtexpired = dateExpired.timeIntervalSinceNow
        let offsetDt = dtexpired - 60
        print("dateExpired objet : \(offsetDt)")
        let minusexpireydate = Date(timeInterval: offsetDt, since: dateNow)
        print("new expiryData : \(minusexpireydate)")
        
        //print("date in between: \(dateNow.isBetween(_newDate, dateExpired))")
        
        /*let expireydate = Date(calendar: .current,
                               timeZone: .current, era: .none,
                               year: 2021,
                               month: 05,
                               day: 21,
                               hour: 14,
                               minute: 27,
                               second: 0,
                               nanosecond: 0)
        
        let minusexpireydate = Date(calendar: .current,
                               timeZone: .current, era: .none,
                               year: 2021,
                               month: 05,
                               day: 21,
                               hour: 14,
                               minute: 24,
                               second: 0,
                               nanosecond: 0)
        
        print("date in between: \(dateNow.isBetween(minusexpireydate, expireydate))")*/
        
        if (dateExpired > dateNow) && (dateNow.isBetween(minusexpireydate, dateExpired)) {
                    let userViewModel = UserViewModel()
                    userViewModel.refreshSessionToken { (refreshed) in
                        print("refreshed token before expiry: \(refreshed)")
                    }
                }
        
        //if (dateExpired > dateNow) && (_newDate.isBetween(dateNow, dateExpired))
        
        /*
         var components = Calendar.current.dateComponents([.year, .month , .day , .hour , .minute], from: self)
         guard let min = components.minute else {
             return self
         }
         components.minute! = min % 30 < 15 ? min - min % 30 : min + 30 - (min % 30)
         components.second = 0
         if min > 30 {
             components.hour? += 1
         }
         return Calendar.current.date(from: components) ?? Date()
         
         **/
        
        return dateExpired > dateNow
    }
    
    /**
     Save predefined objects  in user defaults.
    - Parameter Array of [String:Any] objects
    - Returns: none
    */
    
    func saveObjectsInDefaults(objects: [[String:Any]]) {
        
        let defaults =  UserDefaults.standard
        
        for item in objects {
            let key = item["key"] as? String ?? ""
            let value = item["value"]
            
            print("key : \(key) value: \(String(describing: value))")
            
            defaults.set(value, forKey: key)
            defaults.synchronize()
        }

    }
    
    /**
        Retrieve last connected BLE device from user defaults.
       - Parameter none
       - Returns: String email address
       */
       
       func getBLEUUID() -> String {
        
        let email = self.getUserEmail()
        let state = dataHelper.getAppState(email)
        
        return state.BLEUUID
        
       }
    
    /**
     Remove predefined objects saved in  user defaults.
    - Parameter none
    - Returns: none
    */
    
    func cleanUpUserInfo() {
        let email = self.getUserEmail()
        /*let state = UserAppStates()
        
        if !Utilities.instance.isBLEBoxConnected() {
            state.BLEUUID = ""
            state.SerialNumber = ""
            state.OrgCode = ""
        }
        
        state.SessionDated = ""
        state.SessionKey = ""
        state.Email = ""
        state.RenewalKey = ""
        state.SessionExpiryDated = ""
        
        
        SPRealmHelper().saveAppStates(state, device: "", email: email)*/
        
        
        let params = ["DeviceId":"",
                      "BLEUUID":"",
                      "OrgCode":"",
                      "SerialNumber": "",
                      "SessionKey":"",
                      "SessionDated":"",
                      "SessionExpiryDated":"",
                      "RenewalKey":""]
        dataHelper.updateUserAppStateWithParams(params, email)

        
        SPBluetoothManager.shared.desktopApphasPriority = false
        SPBluetoothManager.shared.AppHeartbeatSetRetry = false
        PulseDataState.instance.isDeskCurrentlyBooked = false
        SPBluetoothManager.shared.PulseDeviceActivityTimer.suspend()
        SPBluetoothManager.shared.PulseHeartbeatReconnectTimer.suspend()
        SPBluetoothManager.shared.PulseDeviceReconnectWhenTimeout.suspend()
        
        removeObjectFromDefaults(key: "serialNumber")
        removeObjectFromDefaults(key: "registrationID")
        
        //removeObjectFromDefaults(key: Constants.app_token)
        //removeObjectFromDefaults(key: Constants.token_expiry)
        //removeObjectFromDefaults(key: Constants.token_dated)
        //removeObjectFromDefaults(key: Constants.organization_code)
        //removeObjectFromDefaults(key: Constants.email)
        removeObjectFromDefaults(key: Constants.SPBLEUUID)
        removeObjectFromDefaults(key: "survey_last_checked")
        removeObjectFromDefaults(key: Constants.current_logged_user_type)
        
        SPBluetoothManager.shared.disconnect(forget: true)
        
        let defaults =  UserDefaults.standard
        //defaults.removeObject(forKey: Constants.email)
        //defaults.removeObject(forKey: Constants.token_expiry)
        //defaults.removeObject(forKey: Constants.app_token)
        //defaults.removeObject(forKey: Constants.token_dated)
        //defaults.removeObject(forKey: Constants.organization_code)
        defaults.removeObject(forKey: Constants.SPBLEUUID)
        defaults.removeObject(forKey: "survey_last_checked")
        
        defaults.synchronize()
        
    }

    /**
     Get angle based on time duration.
    - Parameter Int duration
    - Returns: CGFloat angle
    */
    
    func getAngle(duration: Int) -> CGFloat {
        switch duration {
            case 5:
                return (5 * CGFloat.pi) / 3
            case 10:
                return (11 * CGFloat.pi) / 6
            case 15:
                return 2 * CGFloat.pi
            case 20:
                return CGFloat.pi / 6
            case 25:
                return CGFloat.pi / 3
            case 30:
                return CGFloat.pi / 2
            case 35:
                return (2  * CGFloat.pi) / 3
            case 40:
                return (5 * CGFloat.pi) / 6
            case 45:
                return CGFloat.pi
            case 50:
                return (7 * CGFloat.pi) / 6
            case 55:
                return (4 * CGFloat.pi) / 3
//            case 60:
//                return (3 * CGFloat.pi) / 2
            default:
                return (3 * CGFloat.pi) / 2
        }
        
    }
    
    /**
     Remove all layers added on view.
    - Parameter UIView view
    - Returns: None
    */
    
    func clearAllLayersInView(view: UIView) {
        view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    /**
      Check device connectivity status.
     - Parameters: None
     - Returns: Bool
     */
    
    func isBLEBoxConnected() -> Bool {
        guard SPBluetoothManager.shared.desktopApphasPriority == false else {
            return false
        }
        guard PulseDataState.instance.isDeskCurrentlyBooked == false else {
            return false
        }
        
        
        if (SPBluetoothManager.shared.state.peripheral?.state == nil) || (SPBluetoothManager.shared.state.peripheral?.state == .disconnecting) || (SPBluetoothManager.shared.state.peripheral?.state == .disconnected){
            return false
        } else {
            return true
        }
    }
    
    /**
      Default profile settings lifestyle.
     - Parameters: Int lifestyle
     - Returns: [String:Any] standing period time
     */
    
    func defaultProfileSettingsLifestyle(type: Int) -> [String: Any] {
        var _profileActive = [String: Any]()
        
        switch type {
            case 0:
                _profileActive = ["StandingTimeInMinutesPeriod1":"5",
                                  "StandingTimeInMinutesPeriod2":"0"]
            case 1:
                _profileActive = ["StandingTimeInMinutesPeriod1":"15",
                                  "StandingTimeInMinutesPeriod2":"0"]
            case 2:
                _profileActive = ["StandingTimeInMinutesPeriod1":"15",
                                  "StandingTimeInMinutesPeriod2":"15"]
        default:
            break
        }
        
        
        return _profileActive
    }
    
    /**
     Reset Button selected states.

    - Parameters: [UIButton] array of buttons
    - Returns: none
     
    */
    
    func setButtonStateSelected(sender: [UIButton]) {
        for item in sender {
            item.isSelected = false
        }
        
    }
    
    /**
     Filter string and remove characters.

    - Parameters: String raw
    - Parameters: Set<Character>) char
    - Returns: String
     
    */

    func filterRawData(raw: String, char: Set<Character>) -> String {
        guard !raw.isEmpty else {
            return ""
        }
        var rawString = raw
        let filters: Set<Character> = char
        rawString.removeAll{ filters.contains($0) }
        return rawString
        
    }
    
    /**
     Convert data to CRC16 checksum.

    - Parameters: [UInt8] data
    - Returns: UInt16
    */
    
    func convertCrc16(data: [UInt8])-> UInt16 {
        var crc = UInt16(Constants.BIT15_0_MASK)
        data.forEach { (byte) in
            crc ^= UInt16(UInt16(byte)) << 8
            (0..<8).forEach({ _ in
                crc = (crc & UInt16(Constants.BIT16_MASK)) != 0 ? (crc << 1) ^ UInt16(Constants.CRC16_POLY) : crc << 1
            })
        }
        return UInt16(crc & UInt16(Constants.INIT_CRC16_VAL))
    }
    
    func convertDesktopCrc16(data: [UInt8])-> UInt16 {
        var crc = UInt16(Constants.BIT15_0_MASK)
        data.forEach { (byte) in
            crc ^= UInt16(UInt16(byte)) << 8
            (0..<8).forEach({ _ in
                crc = (crc & UInt16(Constants.BIT16_MASK)) != 0 ? (crc << 1) ^ UInt16(Constants.CRC16_ENCRYPTED_POLY) : crc << 1
            })
        }
        return UInt16(crc & UInt16(Constants.INIT_CRC16_VAL))
    }
    
    /**
     Convert Int to binary and return boolean value.

    - Parameters: Int value
    - Parameters: Int index
    - Returns: Bool
     
    */
    
    func convertBitField(value: Int, index: Int) -> Bool {
        let str = String(value, radix: 2)
        let binaryString = pad(string: str)
        let _value: Character = binaryString.character(at: index) ?? "0"
        return String(_value).boolValue
    }
    
    func convertBitField2(value: Int, index: Int) -> Bool {
        let str = String(value, radix: 2)
        let binaryString = pad(string: str)
        let _value: Character = binaryString.character(at: index) ?? "0"
        return String(_value).boolValue
    }
    
    /**
     Add a padded string with 0 with maximum size.

    - Parameters: String string
    - Parameters: Int toSize
    - Returns: String
     
    */
    
    func pad(string : String, toSize: Int = 8) -> String {
      var padded = string
      for _ in 0..<(toSize - string.count) {
        padded = "0" + padded
      }
        return padded
    }
    
    /**
    Calculate CRC16 from 2 bytes.

    - Parameters: UInt8 hb
    - Parameters: UInt8 lb
    - Returns: Int
     
    */
    
    func calculateCrc16From2bytes(hb: UInt8, lb: UInt8) -> Int {
        let _crc16 = [hb, lb]
        let crcData = Data.init(_crc16)
        return Int(UInt16(bigEndian: crcData.withUnsafeBytes { $0.load(as: UInt16.self) }))
    }
    
    /**
    Validate and compare crc.

    - Parameters: [UInt8] byteArr
    - Returns: Bool
    */
    
    func validateStringWithCRC16(byteArr: [UInt8]) -> Bool {
        let crc = byteArr.suffix(from: byteArr.count-2)
        let crc16Data = Data.init(crc)
        let crc16 = Int(UInt16(bigEndian: crc16Data.withUnsafeBytes { $0.load(as: UInt16.self) }))
        
        let newByteArr = byteArr.prefix(through: byteArr.count-3)
        let dataCrc16 = Int(Utilities.instance.convertCrc16(data: Array(newByteArr)))
        
        return dataCrc16 == crc16
    }
    
    /**
     Calculate raw command CRC16 value.

    - Parameters: String raw
    - Parameters: [String] strings
    - Returns: UInt16
     
    */
    
    func getRawCommandCrc16(raw: String, strings: [String]) -> UInt16 {
        guard raw.isEmpty == false else {
            return 0
        }
        
        let _rawCommand = self.filterRawData(raw: raw, char: ["~"])
        let command = _rawCommand.split(separator: "|").dropLast().joined(separator: "|")
        let _crc16Validation =  self.convertCrc16(data: command.utf8Array)
        return _crc16Validation
    }
    
    /**
     Get string value from date..

    - Parameters: Date date
    - Returns: String
     
    */
    
    func stringDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        print(formatter.string(from: date))
        return formatter.string(from: date)
    }
    
    /**
     Method to compare the serial that has been saved from the user defaults and the box.

    - Parameters: String serial
    - Returns: Bool
    */
    
    func compareAndUpdateSerial(serial: String) -> Bool {
        let _serial = self.getStringFromUserDefaults(key: "serialNumber")
        
        //print("_serial: ", _serial)
        //print("serial: ", serial)
        
        if _serial.isEmpty {
            //self.saveDefaultValueForKey(value: serial, key: "serialNumber")
            return false
        } else {
            if _serial != serial {
                self.saveDefaultValueForKey(value: serial, key: "serialNumber")
                return false
            } else {
                return true
            }
        }
        
    }
    
    /**
     Method to compare the registration ID that has been saved from the user defaults and the box.

    - Parameters: String regitration ID
    - Returns: Bool
    */
    
    func compareRegistrationID(registration: String) -> Bool {
        let _registration = self.getStringFromUserDefaults(key: "registrationID")
        
        //print("_serial: ", _serial)
        //print("serial: ", serial)
        
        if _registration.isEmpty {
            //self.saveDefaultValueForKey(value: serial, key: "serialNumber")
            return false
        } else {
            if _registration != registration {
                self.saveDefaultValueForKey(value: registration, key: "registrationID")
                return false
            } else {
                return true
            }
        }
        
    }
    
    /**
     Response code message to specific response from web service.

    - Parameters: GenericResponse response
    - Returns: ResponseMessage
    */
    
    func responseCodeMessage(response: GenericResponse) -> ResponseMessage {
        
        switch response.ResultCode {
        case 0:
            return ResponseMessage(title: "success.title".localize(),
                                   message: "success.request_success".localize())
        case 1:
            return ResponseMessage(title: "generic.error_title".localize(),
                                   message: "generic.account_verification".localize())
        case 2:
            return ResponseMessage(title: "generic.error_title".localize(),
                                   message: "generic.account_locked".localize())
        case 3:
            return ResponseMessage(title: "generic.error_title".localize(),
                                   message: "generic.account_verification_failed".localize())
        case 4:
            return self.isLoggedIn() ? ResponseMessage(title: "generic.error_title".localize(),
                                                       message: "generic.new_organization_assigned".localize()) :
                                        ResponseMessage(title: "generic.error_title".localize(),
                                                        message: "generic.invalid_org_or_desk".localize())
        case 5:
            return ResponseMessage(title: "generic.error_title".localize(),
                                   message: "generic.desk_not_registered".localize())
        case 6:
            return ResponseMessage(title: "generic.error_title".localize(),
                                   message: "generic.invalid_registration".localize())
        case 7:
            return ResponseMessage(title: "generic.error_title".localize(),
                                   message: "generic.unknown_org".localize())
            
        case 9:
           
            
            return ResponseMessage(title: "generic.notice".localize(),
                                   message: "generic.desk_is_booked".localize())
            
        case 10:
            return ResponseMessage(title: "generic.notice".localize(),
                                   message: "generic.desk_disabled".localize())
        default:
            return ResponseMessage(title: "generic.error_title".localize(),
                                   message: "generic.unknow_error".localize())
        }
    }
    
    /**
     Check if serial key is available.

    - Parameters: none
    - Returns: Bool
    */
    
    func serialKeyAvailable() -> Bool {
        let serial = Utilities.instance.getObjectFromUserDefaults(key: "serialNumber") as? String
        guard (serial != nil) else {
            return false
        }
        
        return true
    }
    
    /**
     Check if user is logged using session token.

    - Parameters: none
    - Returns: Bool
    */
    
    func isLoggedIn() -> Bool {
        guard !getToken().isEmpty else {
            return false
        }
        
        return true
    }
    
    /**
     Check if local database is available and accessable.

    - Parameters: none
    - Returns: Bool
    */
    
    func isDatabaseAccessible() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "_db_access")
    }
    
    /**
     Create new app state object with the values from the current state.

    - Parameters: none
    - Returns: Bool
    */

    func appStateObjectUpdate() -> UserAppStates {
        let email = self.getUserEmail()
        let currentState = dataHelper.getAppState(email)
        return UserAppStates(value: currentState)
    }
 
    func getTimeCodes(code: Int) -> Int {
        switch code {
            case 0:
                return 3
            case 1:
                return 300
            case 2:
                return 600
            case 3:
                return 900
            case 4:
                return 1200
            case 5:
                return 1500
            case 6:
                return 1620
            case 7:
                return 1800
            case 8:
                return 2100
            case 9:
                return 2400
            case 10:
                return 2700
            case 11:
                return 3000
            case 12:
                return 3300
            case 13:
                return 3420
            case 14:
                return -1
            case 15:
                return 0
        default:
            return 0
        }
    }
    
    func firstChar(str:String) -> String {
        return String(Array(str)[0])
    }

    func byteArray<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }

    func getASCIIString(from binaryString: String) -> String? {

        guard binaryString.count % 8 == 0 else {
            return nil
        }

        var asciiCharacters = [String]()
        var asciiString = ""

        let startIndex = binaryString.startIndex
        var currentLowerIndex = startIndex

        while currentLowerIndex < binaryString.endIndex {

            let currentUpperIndex = binaryString.index(currentLowerIndex, offsetBy: 8)
            //let character = binaryString.substring(with: Range(uncheckedBounds: (lower: currentLowerIndex, upper: currentUpperIndex)))
            let character = binaryString[Range(uncheckedBounds: (lower: currentLowerIndex, upper: currentUpperIndex))]
            asciiCharacters.append(String(character))
            currentLowerIndex = currentUpperIndex
        }

        for asciiChar in asciiCharacters {
            if let number = UInt8(asciiChar, radix: 2) {
                let character = String(describing: UnicodeScalar(number))
                asciiString.append(character)
            } else {
                return nil
            }
        }

        return asciiString
    }
    
    func getCombined4Bits(value1: Int, value2: Int) -> UInt8 {
        let padValue1 = get4BitString(val: value1)
        let padValue2 = get4BitString(val: value2)
        let padValue = padValue1 + padValue2
        return UInt8(UInt(padValue.binToDec()))
    }

    func get4BitString(val: Int) -> String {
        let _stc = String(format: "%d", val)
        return _stc.pad(minLength: 4)
    }
    
    func showBits( _ list: [UInt8] )
    {
        for num in list
        {
            showBits(num)
        }
    }

    func showBits( _ num: UInt8 )
    {
        //print(num, String( num, radix : 2 ))
        print( "\(num) \t" +   num.toBits())
    }
    
    func getStringDate() -> String {
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.short
        return dateFormatter.string(from: date)
    }
    
    func getDateFromString(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateStyle = DateFormatter.Style.short
        
        guard !date.isEmpty else {
            return Date()
        }
        
        return dateFormatter.date(from: date) ?? Date()
    }
    
    func setFirstAppLaunch() {
        assert(_firstAppLaunchStaticData.alreadyCalled == false, "[Error] You called setFirstAppLaunch more than once")
        _firstAppLaunchStaticData.alreadyCalled = true
        let defaults = UserDefaults.standard

        if defaults.string(forKey: _firstAppLaunchStaticData.appAlreadyLaunchedString) != nil {
            _firstAppLaunchStaticData.isFirstAppLaunch = false
        }
        defaults.set(true, forKey: _firstAppLaunchStaticData.appAlreadyLaunchedString)
    }

    func isFirstAppLaunch() -> Bool {
        assert(_firstAppLaunchStaticData.alreadyCalled == true, "[Error] Function setFirstAppLaunch wasn't called")
        self.permissionViewShown = _firstAppLaunchStaticData.isFirstAppLaunch
        return _firstAppLaunchStaticData.isFirstAppLaunch
    }
    
    func alertBlePairPopUp() {
        let alertView = SPAlertView(title: "Notice", message: "Please ensure the Pulse box is on pairing mode.", image: UIImage(named: "pairing_mode")!)
        alertView.duration = 2.5
        alertView.present()
    }
    
    func debugAlertPopUp(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {_ in 
            alertController.dismiss(animated: true, completion: nil)
        })
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            if let controller = UIApplication.getTopViewController() {
                controller.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func alertPopUpWithActions(title: String?, message: String? , buttonTitle: String, buttonAction: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(title: buttonTitle, style: .default) { (action) in buttonAction?() }
        if let controller = UIApplication.getTopViewController() {
            controller.present(alert, animated: true, completion: nil)
        }
    }
    
    func initializeBanner() {
        
        guard notificationBanner != nil else {
            return
        }
       
        notificationBanner?.autoDismiss = false
        
        notificationBanner?.onTap = {
            self.notificationBanner?.dismiss()
        }
        
        notificationBanner?.onTap = {
            self.notificationBanner?.dismiss()
        }
        
    }
    
    func dismissStatusNotification() {
        if (notificationBanner != nil) {
            notificationBanner?.dismiss()
        }
    }
    
    func displayStatusNotification(title: String, style: BannerStyle) {
        
        
        //notificationBanner = StatusBarNotificationBanner(title: title, style: style)
        //notificationBanner.show()
        
        if notificationBanner == nil {
            notificationBanner = StatusBarNotificationBanner(title: title, style: .warning)
            initializeBanner()
        } else {
            notificationBanner?.titleLabel?.text =  title
            notificationBanner?.show(queue: bannerQueueToDisplaySeveralBanners)
        }
    }
    
    func convertDateFormat(inputDate: String) -> String {

         let olDateFormatter = DateFormatter()
         olDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

         let oldDate = olDateFormatter.date(from: inputDate)

         let convertDateFormatter = DateFormatter()
         convertDateFormatter.dateFormat = "MMM dd yyyy h:mm a"

         return convertDateFormatter.string(from: oldDate!)
    }
    
    func getBookingStartTime(bookingDate: String,
                             periods: [[String:Any]], offset: Int) -> Date {
        var _bookingDate: Date = Date()
        
        guard periods.count > 0 else {
            return _bookingDate
        }
        
        let _firstPeriod = periods.first
        let _timeIdFrom = _firstPeriod?["TimeIdFrom"] as? Int ?? 0
        let _dateTimePeriod = bookingInterval(strDate: bookingDate, period: _timeIdFrom)
        
        _bookingDate.addMinutes(minutes: _dateTimePeriod.minute)
        _bookingDate.addMinutes(minutes: offset)
        
        print("getBookingStartTime : \(_bookingDate)")
        
        return _bookingDate
        
    }
    
    func getBookingTime(bookingDate: String,
                        periods: [[String:Any]], offset: Int) -> [String: Date] {
        
        guard periods.count > 0 else {
            return ["BookFrom":Date(), "BookTo": Date()]
        }
        
        let durationPeriod = periods.first
        let _timeFrom = durationPeriod?["TimeIdFrom"] as? Int ?? 0
        let _timeTo = (durationPeriod?["TimeIdTo"] as? Int ?? 0) + 1
        
        let dateBooked = getDateFromString(dateStr: bookingDate) ?? Date()
        let bookingStartDate = ISO8601Time(date: dateBooked)
        let bookingEndDate = ISO8601Time(date: dateBooked)
        
        let timeFrom: TimeInterval = TimeInterval((30 * _timeFrom) * 60)
        let timeTo: TimeInterval = TimeInterval((30 * _timeTo) * 60)
        bookingStartDate.date.addTimeInterval(timeFrom)
        bookingEndDate.date.addTimeInterval(timeTo)
        
        print("dateOfBooking is from: \(bookingStartDate.date.toLocalTime()) to: \(bookingEndDate.date.toLocalTime())")
        
        return ["BookFrom":bookingStartDate.date,
                "BookTo": bookingEndDate.date]
        
    }
    
   


    func getDateFromString(dateStr: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: dateStr)
    }

    func bookingInterval(strDate: String, period: Int) -> Date {
        var _dateInterval = getDateFromString(dateStr: strDate)
        _dateInterval?.addMinutes(minutes: 30 * period)
        print("bookingInterval : \(_dateInterval?.preciseLocalTime)")
        return _dateInterval ?? Date()
    }
    
    func getDateBookingInterval(strDate: String, period: Int) -> Date {
        var _dateInterval = getDateFromString(dateStr: strDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let _timeCheck = (30 * period)
        
        print("_timeCheck: ", _timeCheck)
        
        guard var _newDate = _dateInterval?.addingTimeInterval(TimeInterval(30 * period)) else { return Date() }
        
        print("dgetDateBookingInterval ateNow: ", dateFormatter.string(from: _newDate))
        return _dateInterval ?? Date()
    }
    
    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    func getbyteArray<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }
    
    
    
    //get encrypted key
    
    func getKey(identifier: String) -> NSData {
            // Identifier for our keychain entry - should be unique for your application
            let keychainIdentifier = identifier
            let keychainIdentifierData = keychainIdentifier.data(using: String.Encoding.utf8, allowLossyConversion: false)!

            // First check in the keychain for an existing key
            var query: [NSString: AnyObject] = [
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
                kSecAttrKeySizeInBits: 512 as AnyObject,
                kSecReturnData: true as AnyObject
            ]

            // To avoid Swift optimization bug, should use withUnsafeMutablePointer() function to retrieve the keychain item
            // See also: http://stackoverflow.com/questions/24145838/querying-ios-keychain-using-swift/27721328#27721328
            var dataTypeRef: AnyObject?
            var status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
            if status == errSecSuccess {
                return dataTypeRef as! NSData
            }

            // No pre-existing key from this application, so generate a new one
            let keyData = NSMutableData(length: 64)!
            let result = SecRandomCopyBytes(kSecRandomDefault, 64, keyData.mutableBytes.bindMemory(to: UInt8.self, capacity: 64))
            assert(result == 0, "Failed to get random bytes")

            // Store the key in the keychain
            query = [
                kSecClass: kSecClassKey,
                kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
                kSecAttrKeySizeInBits: 512 as AnyObject,
                kSecValueData: keyData
            ]

            status = SecItemAdd(query as CFDictionary, nil)
            assert(status == errSecSuccess, "Failed to insert the new key in the keychain")

            return keyData
        }
    
    func getStringExtractDataObject(data: [UInt8]) -> String {
        var _object = data
        _object.remove(at: 0)
        _object.remove(at: 1)
        _object.remove(at: _object.count - 1)
        _object.remove(at: _object.count - 1)
        print("extractDataObject string: \(_object)")
        let _data = _object.map(String.init).joined(separator: ",")
        return _data
    }
    
    func getArrayExtractDataObject(data: [UInt8]) -> [UInt8] {
        var _object = data
        _object.remove(at: _object.count - 1)
        _object.remove(at: _object.count - 1)
        print("extractDataObject array: \(_object)")
        return _object
    }
    
    func aesCryptWith(data: Data?, key: Data, iv: Data, option: CCOperation) -> Data? {
        guard let data = data else { return nil }

        let cryptLength = data.count + kCCBlockSizeAES128
        var cryptData   = Data(count: cryptLength)

        let keyLength = key.count
        let options   = CCOptions(kCCOptionPKCS7Padding)

        var bytesLength = Int(0)

        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                    CCCrypt(option, CCAlgorithm(kCCAlgorithmAES), options, keyBytes.baseAddress, keyLength, ivBytes.baseAddress, dataBytes.baseAddress, data.count, cryptBytes.baseAddress, cryptLength, &bytesLength)
                    }
                }
            }
        }

        guard UInt32(status) == UInt32(kCCSuccess) else {
            debugPrint("Error: Failed to crypt data. Status \(status)")
            return nil
        }

        cryptData.removeSubrange(bytesLength..<cryptData.count)
        return cryptData
    }
    
    func crypttest(data: Data?, key: Data, iv: Data, option: CCOperation) -> Data? {
        guard let data = data else { return nil }

        let cryptLength = data.count + kCCBlockSizeAES128
        var cryptData   = Data(count: cryptLength)

        let keyLength = key.count
        let options   = CCOptions(kCCOptionPKCS7Padding)

        var bytesLength = Int(0)

        let status = cryptData.withUnsafeMutableBytes { cryptBytes in
            data.withUnsafeBytes { dataBytes in
                iv.withUnsafeBytes { ivBytes in
                    key.withUnsafeBytes { keyBytes in
                    CCCrypt(option, CCAlgorithm(kCCAlgorithmAES),
                            options,
                            keyBytes.baseAddress,
                            keyLength,
                            ivBytes.baseAddress,
                            dataBytes.baseAddress,
                            data.count,
                            cryptBytes.baseAddress,
                            cryptLength,
                            &bytesLength)
                    }
                }
            }
        }

        guard UInt32(status) == UInt32(kCCSuccess) else {
            debugPrint("Error: Failed to crypt data. Status \(status)")
            return nil
        }
        print("bytesLength : \(bytesLength)")
        print("cryptLength : \(cryptLength)")
        print("cryptData.count : \(cryptData.count)")
        print("cryptData.count : \(cryptData.count)")
        
        cryptData.removeSubrange(bytesLength..<cryptData.count)
        return cryptData
    }
}

/**
 
 Stopwatch struct for extracting time.
 
 */

struct StopWatch {

    var totalSeconds: Int

    var years: Int {
        return totalSeconds / 31536000
    }

    var days: Int {
        return (totalSeconds % 31536000) / 86400
    }

    var hours: Int {
        return (totalSeconds % 86400) / 3600
    }

    var minutes: Int {
        return (totalSeconds % 3600) / 60
    }

    var seconds: Int {
        return totalSeconds % 60
    }

    //simplified to what OP wanted
    var hoursMinutesAndSeconds: (hours: Int, minutes: Int, seconds: Int) {
        return (hours, minutes, seconds)
    }
}

class ISO8601Format
{
    let format: ISO8601DateFormatter

    init() {
        let format = ISO8601DateFormatter()
        format.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        format.timeZone = TimeZone(secondsFromGMT: 0)!
        self.format = format
    }

    func date(from string: String) -> Date {
        guard let date = format.date(from: string) else { return Date() }
        return date
    }

    func string(from date: Date) -> String { return format.string(from: date) }
}


class ISO8601Time
{
    var date: Date
    let format = ISO8601Format()

    required init(date: Date) { self.date = date }

    convenience init(string: String) {
        let format = ISO8601Format()
        let date = format.date(from: string)
        self.init(date: date)
    }

    func concise() -> String { return format.string(from: date) }
    func description() -> String { return date.description(with: .current) }
    func localDateTime() -> Date { return date }
}


extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

extension Date {

    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

}

