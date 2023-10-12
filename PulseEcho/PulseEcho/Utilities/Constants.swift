//
//  Constants.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-03.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import UIKit
import Localize
import CoreBluetooth
import EmptyStateKit
/**
  Constant Declrations
 */
var kBLEService_UUID = "00FF"
let kBLE_Characteristic_uuid_Tx = "FF01"
let kBLE_Characteristic_uuid_Rx = "FF01"
let MaxCharacters = 20

var BLEService_UUID = CBUUID(string: kBLEService_UUID)
let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)

struct Constants {
    static let app_key = "1E55B758773022899498EDEF044CC28E917C04D2F3B1E691BBBAC8155F252CD4"
    static let app_key_access = "SPAPPKEYCHAIN"
    static let renew_key = "RENEW_KEY"
    static let APP_NAME = "PULSE ECHO"
    static let DB_NAME = "smartpods.sqlite"
    static let smartpods_que = "SMARTPODS_QUE"
    static let app_token = "app_token"
    static let token_dated = "token_dated"
    static let token_expiry = "token_expiry"
    static let renewwal_key = "renewwal_key"
    static let organization_code = "OrgCode"
    static let email = "email"
    static let current_logged_user_type = "current_logged_user_type"
    static let SPBLEUUID = "SPBLEUUID"
    static let HasLaunched = "HasLaunched"
    static let supportUrl = "https://www.smartpodstech.com/support/"
    static let pingkey = "NDVHRDg1SlU0NDNGMjM0NQ=="
    static let pingiv = "Z0ZhNDMxMTIzNUdGNEZlZQ=="
    static let pingPacket: [UInt8] = [8, 16, 112, 105, 110, 103, 116, 227, 255, 255, 255, 255, 255, 255, 255, 255]
    
    static let arcBaseAngle = (3 * CGFloat.pi) / 2
    static let sitStandDifference = 7
    static let max_desk_height = 1000
    static let min_desk_height = 41

    //UI Constants
    static let smartpods_blue = "#1EB0FF"
    static let smartpods_green = "#02c491"
    static let smartpods_gray = "#676869"
    static let smartpods_purple = "#b33d9c"
    static let smartpods_stars = "#f09b38"
    static let smartpods_red = "#e00000"
    static let smartpods_yellow = "#ffcc00"
    static let smartpods_light_green = "#00cb0a"
    static let smartpods_teal = "#008181"
    static let smartpods_orange = "#ffa500"
    static let smartpods_purple_circle = "#cc00ff"
    static let smartpods_bluish_white = "#D2EFFF"
    
    static let heartProgressBonus = 25
    static let kiloJoulsToKiloCalories = 0.000239006
    static let hoursPerDayActivity = 8
    static let profileProgressOffState = [["key": "7", "end": 3.141592653589793, "start": 4.71238898038469, "value": 0]]
    static let defaultProfileSettingsCommand = "P3,7|3300,4~"
    static let defaultProfileSettingsMovement = [["key": "7", "end": 3.141592653589793, "start": 4.71238898038469, "value": 0], ["value": 2700, "start": 3.141592653589793, "end": 4.71238898038469, "key": "4"]]
    static let defaultProfileHexString = "1404704cffff02da03f2026703f7000d00007174"
    static let defaultSittingPosition = 730
    static let defaultStandingPosition = 1100
    
    static let smartpods_textfield_size_small: CGFloat = 15.0
    static let smartpods_text_size_small: CGFloat = 15.0
    static let smartpods_text_size_medium: CGFloat = 18.0
    static let smartpods_text_numbers_medium = 27
    static let smartpods_text_size_large: CGFloat = 21.0
    static let smartpods_text_numbers_large = 32
    static let smartpods_font_gotham = "GothamRounded-Bold"
    static let smartpods_font_ddin = "D-DINCondensed"
    static let BIT15_0_MASK = 0xFFFF
    static let BIT16_MASK = 0x8000
    static let INIT_CRC16_VAL = 0xffff
    static let CRC16_POLY = 0xBAAD
    static let CRC16_ENCRYPTED_POLY = 0x1021
    
    static let surveyBadgeTag = 0909
    static let BLE_BOND_TIMEOUT = 15 //6
    
    static let BLEPairingSuccessResponse =  "141f"
    static let PairingDesktopPriorityResponse = "1420"
    static let NewBlePairAttemptResponse = "1421"
    static let DesktopAppPriorityResponse = "1422"
    static let InvalidateCommandResponse = "1423"
    static let ResumeNormalBLEDataResponse = "1424"
    
    static let BLEGenericError = "4e"
    
    static let HexadecimalRegex: String = "[0-9A-F]+"
    static let charSet = CharacterSet(charactersIn: "<>")
    static let bleKeyConnected: String = "smartpods"
    static let desk_sitting_images = [UIImage(named: "DeskRaising_00005"),
                                      UIImage(named: "DeskRaising_00004"),
                                      UIImage(named: "DeskRaising_00003"),
                                      UIImage(named: "DeskRaising_00002"),
                                      UIImage(named: "DeskRaising_00001"),
                                      UIImage(named: "DeskRaising_00000")]
    
    static let desk_standing_images = [UIImage(named: "DeskRaising_00067"),
                                      UIImage(named: "DeskRaising_00068"),
                                      UIImage(named: "DeskRaising_00069"),
                                      UIImage(named: "DeskRaising_00070"),
                                      UIImage(named: "DeskRaising_00071"),
                                      UIImage(named: "DeskRaising_00072")]
    
    static let desk_sit_stand_images = [UIImage(named: "DeskRaising_00006"),
                                        UIImage(named: "DeskRaising_00007"),
                                        UIImage(named: "DeskRaising_00008"),
                                        UIImage(named: "DeskRaising_00009"),
                                        UIImage(named: "DeskRaising_000010"),
                                        UIImage(named: "DeskRaising_000011"),
                                        UIImage(named: "DeskRaising_000012"),
                                        UIImage(named: "DeskRaising_000013"),
                                        UIImage(named: "DeskRaising_000013"),
                                        UIImage(named: "DeskRaising_000014"),
                                        UIImage(named: "DeskRaising_000015"),
                                        UIImage(named: "DeskRaising_000016"),
                                        UIImage(named: "DeskRaising_000017"),
                                        UIImage(named: "DeskRaising_000018"),
                                        UIImage(named: "DeskRaising_000019"),
                                        UIImage(named: "DeskRaising_000020"),
                                        UIImage(named: "DeskRaising_000021"),
                                        UIImage(named: "DeskRaising_000022"),
                                        UIImage(named: "DeskRaising_000023"),
                                        UIImage(named: "DeskRaising_000024"),
                                        UIImage(named: "DeskRaising_000025"),
                                        UIImage(named: "DeskRaising_000026"),
                                        UIImage(named: "DeskRaising_000027"),
                                        UIImage(named: "DeskRaising_000028"),
                                        UIImage(named: "DeskRaising_000029"),
                                        UIImage(named: "DeskRaising_000030"),
                                        UIImage(named: "DeskRaising_000031"),
                                        UIImage(named: "DeskRaising_000032"),
                                        UIImage(named: "DeskRaising_000033"),
                                        UIImage(named: "DeskRaising_000034"),
                                        UIImage(named: "DeskRaising_000035"),
                                        UIImage(named: "DeskRaising_000036"),
                                        UIImage(named: "DeskRaising_000037"),
                                        UIImage(named: "DeskRaising_000038"),
                                        UIImage(named: "DeskRaising_000039"),
                                        UIImage(named: "DeskRaising_000040"),
                                        UIImage(named: "DeskRaising_000041"),
                                        UIImage(named: "DeskRaising_000042"),
                                        UIImage(named: "DeskRaising_000043"),
                                        UIImage(named: "DeskRaising_000044"),
                                        UIImage(named: "DeskRaising_000045"),
                                        UIImage(named: "DeskRaising_000046"),
                                        UIImage(named: "DeskRaising_000047"),
                                        UIImage(named: "DeskRaising_000048"),
                                        UIImage(named: "DeskRaising_000049"),
                                        UIImage(named: "DeskRaising_000050"),
                                        UIImage(named: "DeskRaising_000051"),
                                        UIImage(named: "DeskRaising_000052"),
                                        UIImage(named: "DeskRaising_000053"),
                                        UIImage(named: "DeskRaising_000054"),
                                        UIImage(named: "DeskRaising_000055"),
                                        UIImage(named: "DeskRaising_000056"),
                                        UIImage(named: "DeskRaising_000057"),
                                        UIImage(named: "DeskRaising_000058"),
                                        UIImage(named: "DeskRaising_000059"),
                                        UIImage(named: "DeskRaising_000060"),
                                        UIImage(named: "DeskRaising_000061"),
                                        UIImage(named: "DeskRaising_000062"),
                                        UIImage(named: "DeskRaising_000063"),
                                        UIImage(named: "DeskRaising_000064"),
                                        UIImage(named: "DeskRaising_000065"),
                                        UIImage(named: "DeskRaising_000066")]
    
    //static Data
    
    static let smartpods_menu =  [["title":"Height Settings",
                                   "icon":"height_settings",
                                   "selected_icon":"height_settings_click"],
                                  ["title":"Activity",
                                  "icon":"activity",
                                  "selected_icon":"activity_selected"],
                                  ["title":"User Profile",
                                   "icon":"profile",
                                   "selected_icon":"profile_selected"]]
    
    static let desk_statistics = [["title":"Utilization Rate",
                                   "value":"45%",
                                   "type":"1",
                                   "left_title":"wk",
                                   "left_value":"44%",
                                   "right_title":"mth",
                                   "right_value":"52%"],
                                  ["title":"Total Users",
                                   "value":"4",
                                   "type":"0"],
                                  ["title":"Utilization Peak Time",
                                  "value":"2 - 4 pm",
                                  "type":"0"],
                                  ["title":"Avg. Stand Rate",
                                  "value":"2h 6m",
                                  "type":"1",
                                  "left_title":"wk",
                                  "left_value":"8h",
                                  "right_title":"mth",
                                  "right_value":"30h"],
                                  ["title":"Sit/Stand Peak Time",
                                  "value":"3h 10m",
                                  "type":"0"],
                                  ["title":"Type of Users",
                                   "type":"2",
                                  "row1":"Male",
                                  "row1_value":"40%",
                                  "row2":"Female",
                                  "row2_value":"40%",
                                  "row3":"",
                                  "row3_value":""],
                                  ["title":"Movement Type",
                                   "type":"2",
                                  "row1":"Auto",
                                  "row1_value":"0%",
                                  "row2":"Semi-A",
                                  "row2_value":"0%",
                                  "row3":"Manual",
                                  "row3_value":"0%"],
                                  ["title":"Triggers",
                                  "value":"0 / 0",
                                  "type":"0"],
                                  ["title":"Presence At Desk",
                                  "value":"0 H",
                                  "type":"0"],
                                  ["title":"Away",
                                   "type":"2",
                                   "row1":"Meeting",
                                   "row1_value":"0h 0m",
                                   "row2":"Break",
                                   "row2_value":"0h 0m",
                                   "row3":"Lunch",
                                   "row3_value":"0h 0m"],
                                  ["title":"Life Cycle",
                                   "type":"3",
                                   "row1":"Up/Down",
                                   "row1_value":"0%",
                                   "row2":"In/Out",
                                   "row2_value":"0%"],
                                  ["title":"Movement at Desk",
                                   "value":"0 H",
                                   "type":"0"],
                                  ["title":"Avg. Temperature",
                                   "type":"4",
                                   "value":"0 C",
                                   "night":"0 C",
                                   "day":"0 C"],
                                  ["title":"Avg. Light Intensity",
                                   "type":"5",
                                   "value":"Dark",
                                   "night":"Dark",
                                   "day":"Dark"],
                                  ["title":"Avg. Sound Intensity",
                                   "type":"6",
                                   "value":"Quite",
                                   "night":"Quite",
                                   "day":"Quite"]]
    
    static let sp_control_sliders = [["title":"",
                                      "sub_title":"",
                                      "type":""]]
    
    
}

enum CURRENT_LOGGED_USER: String {
    case Guest = "guest"
    case Cloud = "cloud"
    case Local = "local"
    case None =  "none"
}

enum STORYBOARD_NAME: String {
    case Main = "Main"
    case Login = "Login"
}

enum CONTROLLER_NAME: String {
    case Login = "LoginController"
    case Register = "RegisterController"
    case ForgotPassword = "ForgotPasswordController"
    case ResetPassword = "ResetPasswordController"
    case Activate = "ActivateController"
    case Home = "HomeController"
    case HeartStats = "HeartStatsController"
    case HeartStatDetails = "HeartStatDetailsController"
}


enum API_ERROR_CODES: Int {
    case CANNOT_ACCESS = 401
    case INVALID = 403
}

enum AppDatabaseError: Error {
    case DatabaseError
    case DatabaseTableError
}

extension AppDatabaseError: CustomStringConvertible {
    var description: String {
        switch self {
        case .DatabaseError:
            return "database.db_error".localize()
        case .DatabaseTableError:
            return "database.db_table_error".localize()
        }
    }
    
}

enum ValidationError: Error {
    case EmptyCredentials
    case EmailRequired
    case PasswordRequired
    case InvalidEmailAddress
    case EmptyCode
    case InvalidSession
}

extension ValidationError: CustomStringConvertible {
         var description: String {
         switch self {
         case .EmptyCredentials:
            return "login.empty".localize()
         case .InvalidEmailAddress:
            return "login.invalid_email".localize()
         case .EmailRequired:
            return "login.email_required".localize()
         case .PasswordRequired:
            return "login.password_required".localize()
         case .EmptyCode:
            return "login.empty_code".localize()
         case .InvalidSession:
            return "Invalid session"
        }
   }
    
    var stringRepresentation:String {
        switch self {
        case .EmptyCredentials:
           return "EmptyCredentials"
        case .InvalidEmailAddress:
           return "InvalidEmailAddress"
        case .EmailRequired:
           return "EmailRequired"
        case .PasswordRequired:
           return "PasswordRequired"
        case .EmptyCode:
           return "Empty Code"
        case .InvalidSession:
           return "Invalid Session"
       }
    }
}

enum AuthenticateError: Error {
    case invalidUsernamePassword

}

extension AuthenticateError: CustomStringConvertible {
         var description: String {
         switch self {
         case .invalidUsernamePassword:
            return "login.invalid".localize()
      }
   }
}

enum RegisterValidationError: Error {
    case EmptyForm
    case EmailRequired
    case PasswordRequired
    case VerifyPasswordRequired
    case InvalidEmailAddress
    case PasswordNotEqual
}

extension RegisterValidationError: CustomStringConvertible {
         var description: String {
         switch self {
         case .EmptyForm:
            return "registration.empty".localize()
         case .InvalidEmailAddress:
            return "login.invalid_email".localize()
         case .EmailRequired:
            return "login.email_required".localize()
         case .PasswordRequired:
            return "login.password_required".localize()
         case .PasswordNotEqual:
            return "registration.password_mismatch".localize()
         case .VerifyPasswordRequired:
            return "registration.verify_password_required".localize()
        }
   }
}

enum ForgotPasswordValidationError: Error {
    case EmptyForm
    case PasswordRequired
    case VerifyPasswordRequired
    case InvalidPincode
    case PincodeRequired
    case PasswordNotEqual
    case OldPasswordRequired
    case NewPasswordRequired
    case NewPasswordAndVerifyPasswordNotEqual
    case ResetPasswordEmptyForm
}

extension ForgotPasswordValidationError: CustomStringConvertible {
         var description: String {
         switch self {
         case .EmptyForm:
            return "forgot.empty_form".localize()
         case .PasswordRequired:
            return "login.password_required".localize()
         case .PasswordNotEqual:
            return "registration.password_mismatch".localize()
         case .VerifyPasswordRequired:
            return "registration.verify_password_required".localize()
         case .PincodeRequired:
            return "forgot.pincode_required".localize()
         case .InvalidPincode:
            return "forgot.invalid_pincode".localize()
        case .OldPasswordRequired:
           return "options_password_change.old_password_required".localize()
        case .NewPasswordRequired:
           return "options_password_change.new_password_required".localize()
        case .NewPasswordAndVerifyPasswordNotEqual:
            return "options_password_change.new_old_password".localize()
         case .ResetPasswordEmptyForm:
            return "options_password_change.empty_form".localize()
        }
   }
}

enum Gender: Int {
    case EMPTY = 0
    case MALE = 1
    case FEMALE = 2
}

enum Languages: Int {
    case EN = 0
    case FR = 1
    case ES = 2
    case NULL = 3
}

enum StepType: Int {
    case NONE = 0
    case MANUAL = 1
    case AUTOMATIC = 2
}

enum LifeStyle: Int {
    case Sedentary = 0
    case ModeratelyActive = 1
    case VeryActive = 2
}

enum JobDescription: Int {
    case Empty = 0
    case CustomerService = 1
    case ITProgramming = 2
    case Director = 3
    case Manager = 4
    case AdminAssistant = 5
}

extension Gender{
    var stringRepresentation:String {
        switch self {
          case .EMPTY:
            return ""
          case .MALE:
            return "MALE"
          case .FEMALE:
            return "FEMALE"
        }
    }
    var rawValue: Int {
        switch self {
        case .EMPTY:
          return 0
        case .MALE:
          return 1
        case .FEMALE:
          return 2
        }
    }
    
    var genderParameter: String {
        switch self {
            case .EMPTY:
                return "0"
            case .MALE:
                return "1"
            case .FEMALE:
                return "2"
        }

    }
}

extension Languages{
    var stringRepresentation:String {
        switch self {
          case .EN:
            return "EN"
          case .FR:
            return "FR"
          case .ES:
            return "ES"
        case .NULL:
            return ""
        }
    }
}

extension StepType{
    var stringRepresentation:String {
        switch self {
          case .NONE:
            return "NONE"
          case .MANUAL:
            return "MANUAL"
          case .AUTOMATIC:
            return "AUTOMATIC"
        }
    }
}

extension LifeStyle{
    var stringRepresentation:String {
        switch self {
          case .Sedentary:
            return "Sedentary"
          case .ModeratelyActive:
            return "Moderately Active"
          case .VeryActive:
            return "Very Active"
        }
    }
    
    var rawValue:Int {
        switch self {
          case .Sedentary:
            return 0
          case .ModeratelyActive:
            return 1
          case .VeryActive:
            return 2
        }
    }
    
    var lifestyleParameter: String {
        switch self {
            case .Sedentary:
                return "0"
            case .ModeratelyActive:
                return "1"
            case .VeryActive:
                return "2"
        }
    }
}

extension JobDescription{
    var stringRepresentation:String {
        switch self {
        case .Empty:
            return "Empty"
        case .CustomerService:
            return "CustomerService"
        case .ITProgramming:
            return "ITProgramming"
        case .Director:
            return "Director"
        case .Manager:
            return "Manager"
        case .AdminAssistant:
            return "AdminAssistant"
        }
    }
}

enum ActionSheetType: String {
    case GENDER = "Gender"
    case LIFESTYLE = "Lifestyle"
    case HEIGHT = "Height"
    case WEIGHT = "Weight"
}

enum PresetActivityProfile: Int {
    case None = 0
    case Five = 5
    case Fifteen = 15
    case Thirthy = 30
}

enum CustomActivityProfile: Int {
    case None = 0
    case Thirthy = 30
    case Sixty = 60
}

enum USER_INTERACTION_STATE: Int {
  case NORMAL
  case MANUAL_DESK_MODE
  case INTERACTIVE_DESK_MODE
  case AUTOMATIC_DESK_MODE
  case SAFETY_TRIGGERED
  case AWAY_TRIGGERED
}

enum INVERT_TYPE: Int {
    case SIT
    case STAND
}

enum STATISTIC_VIEW_TYPE {
    case DeskMode
    case UpDown
    case DeskActivity
}

enum ProfileSettingsType: Int {
    case Active =  0
    case ModeratelyActive = 1
    case VeryActive = 2
    case Custom = 3
    
    var rawValue:Int {
        switch self {
          case .Active:
            return 0
          case .ModeratelyActive:
            return 1
          case .VeryActive:
            return 2
        case .Custom:
            return 3
        }
    }
}

enum PulseDataRequest: Int {
    case All = 0
    case Pairing = 1
    case Profile = 2
    case Info = 3
    case Report = 4
    case CustomAll = 5
    case CustomProfile = 6
    case LegacyDetection = 7
    case AutoPresence = 8
    case NeedPresence = 9
    case PushCredentials = 10
    
    var stringRepresentation:String {
        switch self {
        case .All:
            return "PulseDataRequest.All"
        case .Pairing:
            return "PulseDataRequest.Pairing"
        case .Profile:
            return "PulseDataRequest.Profile"
        case .Info:
            return "PulseDataRequest.Info"
        case .Report:
            return "PulseDataRequest.Report"
        case .CustomAll:
            return "PulseDataRequest.CustomAll"
        case .CustomProfile:
            return "PulseDataRequest.CustomProfile"
        case .LegacyDetection:
            return "PulseDataRequest.LegacyDetection"
        case .AutoPresence:
            return "PulseDataRequest.AutoPresence"
        case .NeedPresence:
            return "PulseDataRequest.NeedPresence"
        case .PushCredentials:
            return "PulseDataRequest.PushCredentials"
        }
    }
}

enum ViewEventListenerType: String {
    case BaseViewDataStream = "BaseViewDataStream"
    case LoginDataStream = "LoginDataStream"
    case ActivateDataStream = "ActivateDataStream"
    case HomeDataStream = "HomeDataStream"
    case DeskDataStream = "DeskDataStream"
    case DeskModeDataStream = "DeskModeDataStream"
    case ActivityDataStream = "ActivityDateStream"
    case BoxControlDataStream = "BoxControlDataStream"
    case BoxMainControlDataStream = "BoxMainControlDataStream"
    case AppVersion = "AppVersion"
    case BLEConnectivityStream = "bleConnectivity"
    case DeviceListStream = "DeviceListStream"
    case PairScreenDataStream = "PairScreenDataStream"
}

enum DataState: CustomState {
    case noData
    case noSurvey
    case noBLEDevices
    
    var image: UIImage? {
        switch self {
        case .noData, .noSurvey, .noBLEDevices: return UIImage(named: "empty")
        }
    }
    
    var title: String? {
        switch self {
        case .noData: return "No data available"
        case .noSurvey: return "No survey available"
        case .noBLEDevices: return "No desk available"
        }
    }
    
    var description: String? {
        switch self {
        case .noData: return "Sorry, no results found."
        case .noSurvey: return ""
        case .noBLEDevices: return "Please ensure that you did unpair the device in the bluetooth settings and as well the device is on pairing mode."
        }
    }
    
    var titleButton: String? {
        switch self {
        case .noData, .noSurvey: return "Try again?"
        case .noBLEDevices: return "Try again?"
        
        }
    }
}

enum DeskSequence {
    case DeskUp
    case DeskDown
    case None
}


extension DataState {
    var format: EmptyStateFormat {
        switch self {
            
        case .noData, .noSurvey, .noBLEDevices:
            
            var format = EmptyStateFormat()
            format.backgroundColor = .clear
            format.buttonColor = UIColor(hexString: Constants.smartpods_blue)
            format.position = EmptyStatePosition(view: .top, text: .center, image: .top)
            //format.verticalMargin = 40
            //format.horizontalMargin = 40
            //format.imageSize = CGSize(width: 320, height:200)
            format.buttonShadowRadius = 10
            format.titleAttributes = [.font: UIFont(name: Constants.smartpods_font_gotham, size: 20)!, .foregroundColor: UIColor.darkGray]
            format.descriptionAttributes = [.font: UIFont(name: Constants.smartpods_font_gotham, size: 14)!, .foregroundColor: UIColor.darkGray]
            //format.gradientColor = (UIColor(hexString: "#3854A5"), UIColor(hexString: "#2A1A6C"))
            format.gradientColor = (UIColor.clear, UIColor.clear)
            
            return format
        }
        
    }
}

