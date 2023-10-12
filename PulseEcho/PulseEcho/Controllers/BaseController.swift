//
//  ViewController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-03.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import FontAwesome_swift
import Localize
import NotificationBannerSwift
import GradientLoadingBar
import Alamofire
import EventCenter
import CoreBluetooth
import PanModal
import SwiftEventBus
import SPAlert
import PopupDialog
import TBDropdownMenu
import WebKit
import CoreLocation
import SPPermissions

protocol BaseControllerDelegate
{
    
}

class BaseController: UIViewController {
    var coreOne: SPCoreObject?
    var identifier: SPIdentifier?
    
    var bleButton = UIButton(type: .custom)
    var cloudBarButton = UIButton(type: .custom)
    var drawerButton = UIButton(type: .custom)
    
    var selectedMenu: Int = 0
    var selectedMenuIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var items: [[DropdownItem]]!
    var menuView: DropdownMenu?
    
    var bookingInfo: DeskBookingInfo?
    
    //var deviceInComingScheduler = SPTimeScheduler(timeInterval: 300)
     
    //Slider outlets
    @IBOutlet weak var sliderView: UIView?
    @IBOutlet weak var subMenuStackView: UIStackView?
    @IBOutlet weak var leadingSlideMenuConstraint: NSLayoutConstraint?
    @IBOutlet weak var btnControlMenu: UIButton?
    
    //slider
    var boxControlViewOpen = false
    
    //Event observer
    let event = EventCenter()
    
    //Command
    
    let SPCommand = PulseCommands()
    
    //app Delegate Instance
    private static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //Navigation Bar
    var navBar: UINavigationBar = UINavigationBar()
    
    // Gradient loader
    let gradientLoadingBar = GradientLoadingBar(
        height: 4.0,
        isRelativeToSafeArea: true
    )
     public let gradientProgressIndicatorView = GradientActivityIndicatorView()
     public var statusBarErrorNotification = StatusBarNotificationBanner(title: "", style: .danger)
    public var api_response: API_RESPONSE?
    //move Up status
    var moveUpStatus: Bool = false
    
    //move down status
    var moveDownStatus: Bool = false
    
    lazy var boxControl: BoxMainControls = {
        let _boxControler: BoxMainControls = BoxMainControls.fromNib()
        return _boxControler
    }()
    
    var isBluetoothPermissionGranted: Bool {
        if #available(iOS 13.1, *) {
            return CBCentralManager.authorization == .allowedAlways
        } else if #available(iOS 13.0, *) {
            return CBCentralManager().authorization == .allowedAlways
        }
        return true
    }

    var activeButtonTag: Int = 0
    
    var profileAttemptCount: Int = 0
    var profileIsCommitted: Bool = false
    var isAuthenticated: Bool?
    var isSafetyStatus: Bool?
    var isRunSwitchStatus: Bool?
    var hasBleIcon: Bool = false
    
    /**
    Initialize Login Screen

    - Parameter none
    - Returns: none.
    */
    
    public let reachability = NetworkReachabilityManager()
    
    static func loginController(_ guestLogin: Bool) {
        let controller = LoginController.instantiateFromStoryboard(storyboard: "Login") as! LoginController
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = false
        appDelegate.window?.rootViewController = navController
        appDelegate.window?.makeKeyAndVisible()
        
        if guestLogin {
            controller.loggedAsGuest()
        }

    }
    
    /**
    Pairing screen when user is not logged in

    - Parameters none
    - Returns:  none.
    */
    
    static func deviceListController() {
        let controller: MainController = MainController.instantiateFromStoryboard() as! MainController
        let deviceList = DeviceListViewController.instantiateFromStoryboard(storyboard: "Settings") as! DeviceListViewController
        
        let dataHelper = SPRealmHelper()
        
        deviceList.needOrgCodeToSyncData = true
        appDelegate.window?.rootViewController = controller
        appDelegate.window?.makeKeyAndVisible()
        
    }
    
    
    /**
    Initialize Main Screen

    - Parameters none
    - Returns:  none.
    */
    
    static func mainController(_ data: Any?) {
        let controller: MainController = MainController.instantiateFromStoryboard() as! MainController
        controller.data = data
        appDelegate.window?.rootViewController = controller
        appDelegate.window?.makeKeyAndVisible()
        
    }
    
    /**
    Show a specific screen.

    - Parameters none
    - Returns:  none.
    */
    
    static func showController(storyboard: String, controller: String) {
        switch controller {
        case CONTROLLER_NAME.Login.rawValue:
            let controller: HomeController = HomeController.instantiateFromStoryboard() as! HomeController
            appDelegate.window?.rootViewController = controller
            appDelegate.window?.makeKeyAndVisible()
        case CONTROLLER_NAME.HeartStatDetails.rawValue:
            let controller: HeartStatDetailsController = HeartStatDetailsController.instantiateFromStoryboard() as! HeartStatDetailsController
            appDelegate.window?.rootViewController = controller
            appDelegate.window?.makeKeyAndVisible()
        default:
            break
        }
    }
    
    /**
    Create a custom navigation bar

    - Parameter String title
    - Parameter String Username.
    - Returns: none.
    */
    
    func createCustomNavigationBar(title: String, user: String, cloud: Bool, back: Bool, ble: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        
        let navStyles = UINavigationBar.appearance()
        navStyles.tintColor =  .white //UIColor(hexString: "#708090")
        navStyles.barTintColor = .white
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        let navTitleView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 2, height: 44))
        navTitleView.sizeToFit()
        
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 3, width: navTitleView.bounds.size.width , height: user.isEmpty ? 44 : 22)) //22
        let lblUsername = UILabel(frame: CGRect(x: 0, y: 20, width: navTitleView.bounds.size.width, height: 24))
        
        
        lblTitle.textAlignment = .center
        lblTitle.text = title
        lblTitle.font = UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_text_size_small)
        lblTitle.textColor = UIColor(hexString: Constants.smartpods_blue)
        
        lblUsername.textAlignment = .center
        lblUsername.text = title //user
        lblUsername.font = UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_text_size_small)
        lblUsername.textColor = UIColor(hexString: Constants.smartpods_blue)
        lblUsername.fitTextToBounds()
        
        let logo = UIImageView(frame: CGRect(x: 0, y: 3, width: navTitleView.bounds.size.width, height: 20))
        logo.image = UIImage(named: "smartpods_logo_blue")
        logo.contentMode = .scaleAspectFit
        
        
        navTitleView.addSubview(logo)
        navTitleView.addSubview(lblUsername)
        
        //navTitleView.gestureRecognizers?.removeAll()
        #warning ("need to disable prior to release")
        //if (API_ENDPOINT.env == "Development") {
        
        if LOGS.BUILDTYPE.boolValue == false {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.showDebugger(_:)))
            navTitleView.addGestureRecognizer(tap)

        }
        
        self.navigationItem.titleView = navTitleView
        
        let rightBarViews = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
        let leftBarViews = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
        self.hasBleIcon = ble
        if ble {
            
            if let peripheral = SPBluetoothManager.shared.state.peripheral {
                bleButton.setImage(UIImage.fontAwesomeIcon(name: .bluetoothB,
                                                               style: .brands,
                                                               textColor: ((peripheral.state == .connected) ? UIColor(hexString: Constants.smartpods_green) : UIColor(hexString: Constants.smartpods_gray)),
                                                               size: CGSize(width: 30, height: 30)), for: .normal)
            } else {
                bleButton.setImage(UIImage.fontAwesomeIcon(name: .bluetoothB,
                                                               style: .brands,
                                                               textColor: UIColor(hexString: Constants.smartpods_gray),
                                                               size: CGSize(width: 30, height: 30)), for: .normal)
            }
        }
        
        if back {
           let backButton = UIButton(type: .custom)
            backButton.setImage(UIImage(named: "back"), for: .normal)
            backButton.setImage(UIImage.fontAwesomeIcon(name: .chevronLeft,
                                                           style: .solid,
                                                           textColor: UIColor(hexString: Constants.smartpods_blue),
                                                           size: CGSize(width: 30, height: 30)), for: .normal)
           backButton.contentMode = .scaleAspectFill
           backButton.addTarget(self, action: #selector(backButtonPress), for: .touchUpInside)
           backButton.frame = CGRect(x: -10, y: 0, width: 40, height: 40)
           leftBarViews.addSubview(backButton)
           
           let leftBarItem = UIBarButtonItem(customView: leftBarViews)
           self.navigationItem.leftBarButtonItems = [leftBarItem]
        } else {
            
            if Utilities.instance.IS_FREE_VERSION == false {
                bleButton.contentMode = .scaleAspectFill
                bleButton.addTarget(self, action: #selector(bluetoothAction), for: .touchUpInside)
                bleButton.frame = CGRect(x: 0, y: 2, width: 30, height: 40)
                
                if ble{
                    leftBarViews.addSubview(bleButton)
                }
                
            }
            
            if cloud {
                cloudStatusIndicator()
                cloudBarButton.contentMode = .scaleAspectFill
                cloudBarButton.addTarget(self, action: #selector(cloudAction), for: .touchUpInside)
                
                if Utilities.instance.IS_FREE_VERSION == false {
                     cloudBarButton.frame = CGRect(x: 30, y: 2, width: 30, height: 40)
                } else {
                    cloudBarButton.frame = CGRect(x: 0, y: 2, width: 30, height: 40)
                }
                
                
                leftBarViews.addSubview(cloudBarButton)
            }
            
            
              
            let leftBarItem = UIBarButtonItem(customView: leftBarViews)
            self.navigationItem.leftBarButtonItems = [leftBarItem]
            

        }
        
        
        if cloud {
            drawerButton.setImage(UIImage.fontAwesomeIcon(name: .ellipsisV,
                                                            style: .solid,
                                                            textColor: UIColor(hexString: Constants.smartpods_gray),
                                                            size: CGSize(width: 30, height: 30)), for: .normal)
            drawerButton.contentMode = .scaleAspectFill
            drawerButton.addTarget(self, action:  #selector(openDrawerMenu), for: .touchUpInside)
            drawerButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: drawerButton)
            
        }
        
        self.navigationItem.hidesBackButton = !back //true
        
    }
    
    @objc func testPushMobile(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        let controller = AppLogController()
        controller.pushMobileAppPacket()
    }
    
    @objc func backButtonPress() {
        self.navigationController?.popViewController(animated: true)
    }
    
    /**
     Bluetooth button action from navigation bar.
     - Parameters: None
     - Returns: none
     */
    
    @objc func bluetoothAction() {
        
        guard SPBluetoothManager.shared.central == nil else {
            userBLEPermission()
            return
        }
        
        
        Threads.performTaskAfterDealy(0.5, {
            SPBluetoothManager.shared.initializeBleCentral{
                self.userBLEPermission()
            }
        })
        
    }
    
    /**
     User check if BLE access is allowed.
     - Parameters: None
     - Returns: none
     */
    
    func userBLEPermission() {
        if let peripheral = SPBluetoothManager.shared.state.peripheral {
            if peripheral.state == .connected {
                Utilities.instance.saveDefaultValueForKey(value: false, key: pairingDefaultsKey)
                SPBluetoothManager.shared.disconnect(forget: true)
                
                //need to save the last state interaction of the ble
                let device = ["State": PulseState.Disconnected.rawValue,
                              "Identifier": peripheral.identifier.uuidString,
                              "DisconnectedByUser": true] as [String : Any]
                PulseDeviceStateUpdate(params: device)
                
                checkBLEConnectivityIndicator()
                let serial = Utilities.instance.getObjectFromUserDefaults(key: "serialNumber") as? String
                let registrationID = Utilities.instance.getObjectFromUserDefaults(key: "registrationID") as? String
                updateDeviceConnectStatus(serial: serial ?? "",registration: registrationID ?? "", connected: false)
            } else {
                showPairingDialog()
            }
        } else {
            showPairingDialog()
        }
    }
    
    func PulseDeviceStateUpdate(params: [String: Any]) {
        
        guard Utilities.instance.typeOfUserLogged() != .None else {
            return
        }
        
        let dataHelper = SPRealmHelper()
        let email = Utilities.instance.getLoggedEmail()
        
        var device = [String: Any]()
        
        if dataHelper.pulseDeviceExists(email) == false {
            
            if params["Identifier"] != nil {
               device["Identifier"] = params["Identifier"]
            } else {
                device["Identifier"] = ""
            }
            
            if params["Serial"] != nil {
               device["Serial"] = params["Serial"]
            } else {
                device["Serial"] = ""
            }
            
            if params["PeripheralName"] != nil {
               device["PeripheralName"] = params["PeripheralName"]
            } else {
                device["PeripheralName"] = ""
            }
            
            if params["UserProfile"] != nil {
               device["UserProfile"] = params["UserProfile"]
            } else {
                device["UserProfile"] = ""
            }
           
            if params["DisconnectedByUser"] != nil {
               device["DisconnectedByUser"] = params["DisconnectedByUser"]
            } else {
                device["DisconnectedByUser"] = false
            }
            
            if params["State"] != nil {
               device["State"] = params["State"]
            } else {
                device["State"] = PulseState.Unknown.rawValue
            }
            
            device["Email"] = email
            
            SPRealmHelper.saveObject(from: device, primaryKey: email) { (result: Result<PulseDevices, Error>) in
                switch result {
                case .success:break
                case .failure: break
                }
            }
        } else {
            
            if params["Identifier"] != nil {
               device["Identifier"] = params["Identifier"]
            }
            
            if params["Serial"] != nil {
               device["Serial"] = params["Serial"]
            }
            
            if params["PeripheralName"] != nil {
               device["PeripheralName"] = params["PeripheralName"]
            }
            
            if params["UserProfile"] != nil {
               device["UserProfile"] = params["UserProfile"]
            }
           
            if params["DisconnectedByUser"] != nil {
               device["DisconnectedByUser"] = params["DisconnectedByUser"]
            }
            
            if params["State"] != nil {
               device["State"] = params["State"]
            }
            
            _ = dataHelper.updatePulseObject(device, email)
            
            
        }
    }
    
    /**
     Show survey pop up.
     - Parameters: Survey survey
     - Returns: none
     */
    
    func showSurvey(survey: Survey) {
    
        let checkSurveyPopup = Utilities.instance.getBoolObject(key: "survery_popup_already_shown")
        
        guard Utilities.instance.isLoggedIn() else {
            return
        }
        
        if let controller = UIApplication.getTopViewController() {
            
            if controller is MainController {
                let _controller = controller as! MainController
                _controller.home.surveyBadge()
            }
        }
        
        guard checkSurveyPopup == false else {
            return
        }
    }
    
    /**
     BLE customize pop up permission.
     - Parameters: None
     - Returns: none
     */
    
    func requestBLEPermission() {
        
    }
    
    /**
     Bluetooth button indicator check  from navigation bar.
     - Parameters: None
     - Returns: none
     */
    
    func checkBLEConnectivityIndicator() {
        
        guard self.hasBleIcon else {
            return
        }
        
        if let peripheral = SPBluetoothManager.shared.state.peripheral {

            DispatchQueue.main.async {
                self.bleButton.setImage(UIImage.fontAwesomeIcon(name: .bluetoothB,
                                                               style: .brands,
                                                               textColor: ((peripheral.state == .connected) ? UIColor(hexString: Constants.smartpods_green) : UIColor(hexString: Constants.smartpods_gray)),
                                                               size: CGSize(width: 30, height: 30)), for: .normal)
            }
            
            //sync user profile
            
            

        } else {
            DispatchQueue.main.async {
                self.bleButton.setImage(UIImage.fontAwesomeIcon(name: .bluetoothB,
                                                               style: .brands,
                                                               textColor: UIColor(hexString: Constants.smartpods_gray),
                                                               size: CGSize(width: 30, height: 30)), for: .normal)
            }
        }
    }
    
    
    /**
     Update device connectivity to cloud.
     - Parameters: String serial
     - Returns: none
     */
    
    func updateDeviceConnectStatus(serial: String, registration: String,  connected: Bool) {
        
        let viewModel = UserViewModel()
        let token = Utilities.instance.getToken()
        
        guard !token.isEmpty else {
            return
        }
        
        guard !serial.isEmpty else {
            return
        }
        
        if connected {
            let should_syncronize: Bool = Utilities.instance.getObjectFromUserDefaults(key: "should_syncronize") as? Bool ?? false
            if should_syncronize {
                self.checkAndUpdateProfileSettings()
            }
            
            //request push credentials
            let command = SPRequestParameters.GetAESKey
            sendACommand(command: command, name: "SPRequestParameters.GetAESKey")
        }
        let dataHelper = SPRealmHelper()
        let email = Utilities.instance.getUserEmail()
        let appState = dataHelper.getAppState(email)
        let hasOrgCode = appState.HasOrgCode
        var parameters: [String : Any] = ["Connected":connected,
                          "OrgCode":appState.OrgCode,
                          "SerialNumber":serial,
                          "RegistrationId": registration]
        
        
        if (!hasOrgCode) {
            parameters = ["Connected":connected,
                          "SerialNumber":serial,
                          "RegistrationId": registration]
        }
        
        viewModel.requestSetDeviceConnected(parameters, { response in
                                                print("updateDeviceConnectStatus: \(response)")
                                                
                                                let generic = GenericResponse(params: response)
                                                let responsemsg = Utilities.instance.responseCodeMessage(response: generic)
                                                
                                                switch(generic.ResultCode) {
                                                    case 0:
                                                        let _booking = response["DeskBookingInfo"] as? [String: Any] ?? [String: Any]()
                                                        var packets = [UInt8]()
                                                        
                                                        if !_booking.isEmpty {
                                                            let bookingInfo = DeskBookingInfo(params: _booking)
                                                            
                                                            let _isEnabled = bookingInfo.IsEnabled ? 1 : 0
                                                            let _isLoggedin = bookingInfo.IsLoggedIn ? 1 : 0
                                                            let _IsHotelingStateEnabled = bookingInfo.IsHotelingStateEnabled ? 1 : 0
                                                            
                                                            packets.append(UInt8(10))
                                                            packets.append(UInt8(17))
                                                            packets.append(UInt8(96))
                                                            
                                                            let _bookingId = (bookingInfo.BookingId != 0) ? 1 : 0
                                                                           
                                                            packets.append(UInt8(_isEnabled))
                                                            packets.append(UInt8(_bookingId))
                                                            packets.append(UInt8(_isLoggedin))
                                                            
                                                            if (bookingInfo.BookingId != 0) {
                                                                let _bookingDate = Utilities.instance.getBookingTime(bookingDate: bookingInfo.BookingDate,
                                                                                                                          periods: bookingInfo.Periods,
                                                                                                                          offset: bookingInfo.TzOffset)
                                                                let startTime = _bookingDate["BookFrom"] ?? Date()
                                                                let utcTime = Utilities.instance.getDateFromString(dateStr: bookingInfo.UtcDateTime)
                                                                let timeOfBooking = startTime.addMinutes(minutes: 15)
                                                                let totalSeconds = Int(timeOfBooking - (utcTime ?? Date()))
                                                                
                                                                print("totalSeconds : \(totalSeconds)")
                                                                
                                                                var timeBytes = UInt16(bigEndian: UInt16.init(totalSeconds))
                                                                let timePacket = withUnsafeBytes(of: &timeBytes) { Array($0) }
                                                                packets.append(contentsOf: timePacket)
                                                            } else {
                                                                packets.append(UInt8(0))
                                                                packets.append(UInt8(0))
                                                            }
                                                            
                                                            packets.append(UInt8(_IsHotelingStateEnabled)) 
                                                        }
                                                        
                                                        print("BOOKING PACKETS : \(packets)")
                                                        
                                                        let crc = Utilities.instance.convertCrc16(data: packets).bigEndian.data.array
                                                        packets.append(contentsOf: crc)
                                                        
                                                        self.sendACommand(command: packets, name: "BOOKING_PACKET")
                                                        
                                                        if (!hasOrgCode) {
                                                            let viewModel = UserViewModel()
                                                            let dataHelper = SPRealmHelper()
                                                            let profileSettingsViewModel = ProfileSettingsViewModel()
                                                            let loginResult = Login(params: response)
                                                            let _orgCode = response["OrgCode"] as? String ?? ""
                                                            let _orgName = response["OrgName"] as? String ?? ""
                                                            
                                                            //SAVE APPSTATE
                                                            let appState = UserAppStates()
                                                            
                                                            appState.SerialNumber = serial
                                                            appState.OrgCode = _orgCode
                                                            appState.OrgName = _orgName
                                                            appState.HasOrgCode = true
                                                            appState.SessionExpiryDated = loginResult.SessionExpiryDated
                                                            appState.SessionKey = loginResult.SessionKey
                                                            appState.SessionDated = loginResult.SessionDated
                                                            appState.RenewalKey = loginResult.RenewalKey
                                                            
                                                            if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                                                                appState.DeviceId = uuid
                                                                dataHelper.saveAppStates(appState, device: uuid, email: email)
                                                            }
                                                            
                                                            let newAppState: [String: Any] = ["Email": email,
                                                                                              "SerialNumber":serial,
                                                                                              "OrgCode":_orgCode,
                                                                                              "OrgName":_orgName,
                                                                                              "HasOrgCode":true,
                                                                                              "SessionKey":loginResult.SessionKey,
                                                                                              "SessionDated":loginResult.SessionDated,
                                                                                              "RenewalKey":loginResult.RenewalKey,
                                                                                              "SessionExpiryDated":loginResult.SessionExpiryDated]
                                                        
                                                            
                                                            SPRealmHelper.saveObject(from: newAppState, primaryKey: email) { (result: Result<UserAppStates, Error>) in
                                                                switch result {
                                                                    case .success:
                                                                        //SAVE USER
                                                                        viewModel.getUserInformation(completion: { [weak self] object in })
                                                                        
                                                                        //PUSH DEFAULT PROFILE
                                                                        let defaultProfile = self.SPCommand.GenerateVerticalProfile(movements: Constants.defaultProfileSettingsMovement)
                                                                        let setSit = self.SPCommand.GetSetDownCommand(value: Double(Constants.defaultSittingPosition))
                                                                        let setStand = self.SPCommand.GetSetTopCommand(value: Double(Constants.defaultStandingPosition))

                                                                        SPBluetoothManager.shared.pushProfileTotheBox(profile: defaultProfile, sit: setSit, stand: setStand)
                                                                        profileSettingsViewModel.createDefaultProfileSettings(pushToBox: false, emailAdress: email)
                                                                        
                                                                        Threads.performTaskAfterDealy(1) {
                                                                            self.showActivityIndicator(show: false)
                                                                            BaseController.mainController(nil)
                                                                        }
                                                                        
                                                                    case .failure:
                                                                        self.displayNotificationMessage(title: "generic.error_title".localize(),
                                                                                                        subTitle: "generic.other_error".localize(),
                                                                                                        style: .danger)
                                                                }
                                                            }
                                                            
                                                            
                                                            
                                                        }
                                                        
                                                        
                                                    case 6:
                                                        self.showAlertWithAction(title: responsemsg.title, message: responsemsg.message, buttonTitle: "OK") {
                                                            SPBluetoothManager.shared.disconnect(forget: true)
                                                            SPBluetoothManager.shared.forgetPeripheral(forget: false)
                                                            //SPBluetoothManager.shared.forgetPeripheral()
                                                            
                                                            SPBluetoothManager.shared.pulse = .ResetBond
                                                            let device = ["State": PulseState.ResetBond.rawValue] as [String : Any]
                                                            self.PulseDeviceStateUpdate(params: device)
                                                            self.logoutAction()
                                                            
                                                    }
                                                case 9:
//                                                    self.showAlertWithAction(title: responsemsg.title, message: responsemsg.message, buttonTitle: "OK") {
//                                                    }
                                                    break
                                                case 10:
//                                                    self.showAlertWithAction(title: responsemsg.title, message: responsemsg.message, buttonTitle: "OK") {
//                                                    }
                                                    break
                                                default:
                                                    break
                                                }
                                                
                                                
                                                    
                                                    
                                            
                                               
                                                
        })
    }
    
    /**
     WIFI button action from navigation bar.
     - Parameters: None
     - Returns: none
     */
    
    @objc func wifiAction() {
        
    }
    
    /**
     Cloud button action from navigation bar.
     - Parameters: None
     - Returns: none
     */
    
    @objc func cloudAction() {
        //log.debug("GUEST USER: ", context: Utilities.instance.isGuest)
        let current_logged = Utilities.instance.typeOfUserLogged()
        guard (current_logged == .Guest || current_logged == .None) else {
            return
        }
        //let defaults =  UserDefaults.standard
        //defaults.removeObject(forKey: Constants.email)
        //defaults.removeObject(forKey: Constants.current_logged_user_type)
        //defaults.synchronize()
        BaseController.loginController(false)
    }
    
    @objc func openDrawerMenu() {
        menuView?.showMenu()
    }
    
    @objc func logoutAction() {
        logoutUser(useGuest:false)
    }
    
    func logoutUser(useGuest: Bool) {
        Utilities.instance.cleanUpUserInfo()
        
        if let controller = UIApplication.getTopViewController() {
            if controller is MainController {
                let _controller = controller as! MainController
            }
        }
        
        
        BaseController.loginController(useGuest)
    }
    
    /**
     Cloud status indicator from navigation bar.
     - Parameters: None
     - Returns: none
     */
    
    func cloudStatusIndicator() {
        cloudBarButton.setImage(UIImage.fontAwesomeIcon(name: .cloud,
                                                        style: .solid,
                                                        textColor: (Utilities.instance.isGuest ? UIColor(hexString: Constants.smartpods_gray): UIColor(hexString: Constants.smartpods_green)),
                                                        size: CGSize(width: 20, height: 20)), for: .normal)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //fontNames()
        //log.debug("DEVICE IS: \(deviceSize)")
        bindViewModelAndCallbacks()
        setupGradientProgressIndicatorView()
        bindlistenerforreachability()
        setUpSlideMenu()
        setUpNavMenu()
        PulseDataState.instance.delegate = self
        
        guard !Utilities.instance.IS_FREE_VERSION else {
            return
        }
        
        registerEventObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !Utilities.instance.IS_FREE_VERSION else {
            return
        }
        
        
        //SPBluetoothManager.shared.getSignalStrength()
        
        let email = Utilities.instance.getUserEmail()
        guard !Utilities.instance.isGuest && !email.isEmpty  else {
           return
         }

//        if CLLocationManager.locationServicesEnabled() {
//            LocationService.shared.startUpdatingLocation()
//        }
        
        
        if isBluetoothPermissionGranted {
            SPBluetoothManager.shared.initializeBleCentral {
                //log.debug("BLE REQUEST")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard !Utilities.instance.IS_FREE_VERSION else {
            return
        }
        
        checkBLEConnectivityIndicator()
        checkToggleBoxMenuSlider()
        self.boxControl.updateSelectedTag(tag: Utilities.instance.boxControlButtonTag)
    }
    
    /**
     Reachability listener.
     - Parameters: None
     - Returns: none
     */
    
    func bindlistenerforreachability() {
        //reachability?.listener = { print("isReachable: \($0)") }
        //reachability?.startListening()
        
        reachability?.startListening(onUpdatePerforming: { (status) in
            print("isReachable : \(status)")
        })
    }
    
    /**
     Setup custom gradient progress indicator below navigation bar
     - Parameters: None
     - Returns: none
     */
    
    private func setupGradientProgressIndicatorView() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        Threads.performTaskInMainQueue {
            
            self.gradientProgressIndicatorView.fadeOut(duration: 0)

            self.gradientProgressIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            navigationBar.addSubview(self.gradientProgressIndicatorView)

            NSLayoutConstraint.activate([
                self.gradientProgressIndicatorView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor),
                self.gradientProgressIndicatorView.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor),

                self.gradientProgressIndicatorView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
                self.gradientProgressIndicatorView.heightAnchor.constraint(equalToConstant: 3.0)
            ])
            
        }
    }
    
    /**
     Print font names
     - Parameters: None
     - Returns: none
     */
    
    func fontNames() {
        let familyNames = UIFont.familyNames

        for family in familyNames {
            print("Family name " + family)
            let fontNames = UIFont.fontNames(forFamilyName: family)
            
            for font in fontNames {
                print("    Font name: " + font)
            }
        }
    }
    
    /**
     Customnize UI
     - Parameters: None
     - Returns: none
     */
    
    func customizeUI() { }
    
    /**
     Bind view model and its callbacks.
     - Parameters: None
     - Returns: none
     */
    
    func bindViewModelAndCallbacks() { }
    
    /**
     Show native style alert.
     - Parameters: String title
     - Parameters: String message
     - Returns: none
     */
    
   func displayAlert(title: String?, message: String?) {
       showAlert(title: title, message: message)
   }
    
    /**
     Show native style alert with button actions.
     - Parameters: Optional String title
     - Parameters: Optional String message
     - Parameters: String positive  message
     - Parameters: String negative message
     - Parameters: Closure success
     - Parameters: Closure cancel
     - Returns: none
     */
   
   func displayAlert(title: String?, message: String?, positiveText: String, negativeText: String, success: (() -> Void)? , cancel: (() -> Void)?) {
       showAlert(title: title, message: message, positiveText: positiveText, negativeText: negativeText, success: success, cancel: cancel)
   }

    /**
     Show a notification message in status bar.
     - Parameters: String title
     - Parameters: BannerStyle style
     - Returns: none
     */
    
    func displayStatusNotification(title: String, style: BannerStyle) {
        
        let banner = StatusBarNotificationBanner(title: title, style: style)
        //banner.autoDismiss = true
        
        if banner.isDisplaying == false {
            banner.show()
        } else {
            banner.dismiss()
        }
    }
    
    /**
     Show a notification message  style..
     - Parameters: String title
     - Parameters: BannerStyle style
     - Returns: none
     */
    
    func displayNotificationMessage(title: String,subTitle: String, style: BannerStyle) {
        let banner = NotificationBanner(title: title, subtitle: subTitle, style: style)
        banner.show()
    }
    
    /**
     Show/hide gradient loading bar on top of navigation bar.
     - Parameters: Bool status
     - Returns: None
     */
    
    func showActivityIndicator(show: Bool) {
        guard show else {
            Threads.performTaskInMainQueue {
                self.gradientProgressIndicatorView.fadeOut()
            }
            return
        }
         Threads.performTaskInMainQueue {
            self.gradientProgressIndicatorView.fadeIn()
        }
    }
    
    /**
     Dismiss keyboard on screen.
     
    - Parameters: UITextField sender.
    - Returns: none.
    */

    func textFieldDismissKeyboard(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    /**
     Empty textfield values.
     
    - Parameters: UITextField sender.
    - Returns: none.
    */

    func clearTextField(sender: UITextField) {
        sender.text = ""
    }
    
    /**
     Customize textfield display.
     
    - Parameters: UITextField sender.
    - Returns: none.
    */

    func customizeTextField(sender: UITextField) {
        sender.font = UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_text_size_small)
    }
    
    /**
     Reset Button states.

    - Parameters: UIButton sender
    - Returns: none
     
    */
    
    func setButtonTabSelected(sender: [UIButton]) {
        for item in sender {
            item.isSelected = false
        }
        
    }
    
    /**
     Display alert message.
     - Parameters: Optional String title
     - Parameters: Optional String message
     - Parameters: Closure success
     - Parameters: Closure cancel
     - Returns: none
     */
    
    func displayAlertMessage(title: String,
                             message: String,
                             successAction: UIAlertAction,
                             cancelAction: UIAlertAction)  {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

            alert.addAction(successAction)
            alert.addAction(cancelAction)
        
        DispatchQueue.main.async(execute: {
           self.present(alert, animated: true)
        })
        
        
    }
    
    /**
     Display alert message.
     - Parameters: Optional String title
     - Parameters: Optional String message
     - Parameters: Closure success
     - Returns: none
     */
    
    func displayAlertMessage(title: String,
                             message: String,
                             successAction: UIAlertAction){
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

            alert.addAction(successAction)
        
        Threads.performTaskInMainQueue {
            self.present(alert, animated: true)
        }
    }
    
    /**
     Check if ble device is connected.
     - Parameters: None
     - Returns: Bool
     */
    
    func SPDeviceConnected() -> Bool {
       if (SPBluetoothManager.shared.state.peripheral?.state == nil) || (SPBluetoothManager.shared.state.peripheral?.state == .disconnecting) || (SPBluetoothManager.shared.state.peripheral?.state == .disconnected){
            
            self.notificationBleNotConnected()
            
            return false
        } else {
            //synchronizeProfileSettings()
            return true
        }
    }
    
    @objc func showDebugger(_ sender: UITapGestureRecognizer? = nil) {
        let controller: AppLogController = AppLogController.instantiateFromStoryboard() as! AppLogController
        
        DispatchQueue.main.async {
            self.present(controller, animated: true, completion: nil)
        }
    }

    
    func checkAndUpdateProfileSettings() {
        
        guard !Utilities.instance.IS_FREE_VERSION else {
            return
        }
        
        if Utilities.instance.serialKeyAvailable() {
            let should_syncronize: Bool = Utilities.instance.getObjectFromUserDefaults(key: "should_syncronize") as? Bool ?? false
            let email = Utilities.instance.getUserEmail()
            let serial = Utilities.instance.getObjectFromUserDefaults(key: "serialNumber") as? String ?? ""
            let profileSettingsViewModel = ProfileSettingsViewModel()
            
            profileSettingsViewModel.forceLogout = { [weak self] () in
                self?.logoutUser(useGuest: false)
            }
            
           profileSettingsViewModel.alertMessage = { [weak self](title: String, message: String, tag: Int) in
                
            if tag == 4 {
                self?.showAlert(title: title, message: message, tapped: {
                    self?.logoutUser(useGuest: false)
                })
             } else if tag == 5 {
                    self?.showAlert(title: title,
                                   message: message,
                                   positiveText: "common.yes".localize(),
                                   negativeText: "common.no".localize(),
                                   success: {
                                    
                                    self?.logoutUser(useGuest: true)
                                    
                                    },
                                   cancel: {
                                    SPBluetoothManager.shared.disconnect(forget: false)
                    })
                } else {
                    
                    self?.displayStatusNotification(title: message, style: .danger)
                }
                
                
            }
            
           guard !Utilities.instance.isGuest else
           {
                return
            }

            profileSettingsViewModel.requestProfileSettings(email, serial, "", "") { raw in
                //log.debug("raw object for profile: \(raw)")
                if raw.count > 0 {
                    let profile = ProfileSettings(params: raw)
                    
                    if should_syncronize {
                        self.synchronizeUserProfileSettings(defaultProfile: false, profile: profile)
                        
                    }
                } else {
                    profileSettingsViewModel.createDefaultProfileSettings(pushToBox: true, emailAdress: email)
                }
            }
            
        } else {
             Utilities.instance.saveDefaultValueForKey(value: true, key: "should_syncronize")
           //s log.debug("serial is not available")
        }
    }
    
    func notificationBleNotConnected() {
        DispatchQueue.main.async {
            SPAlert.present(title: "Notice", message: "Not connected to the device.", image: UIImage(named: "ble_not_connected")!)
        }
        
    }
    
    func chooseAndUpdateDepartmentList(shouldUpdate: Bool, completion: @escaping ((_ object: Department) -> Void)) {
        let alert = UIAlertController(style: .alert)
        alert.set(title: "departments.title".localize(), font: UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_text_size_small) ?? UIFont.systemFont(ofSize: 15.0), color: UIColor(hexString: Constants.smartpods_gray))
        alert.addDepartmentsPicker { (data) in
            
            if shouldUpdate {
                let viewModel = UserViewModel()
               
                let email = Utilities.instance.getUserEmail()
                var userObject = User(params: [String : Any]())
                viewModel.getLocalUserInformation { (object) in
                    userObject = object
                }
                
                let updateObject = SPRealmHelper.update(email, userObject) { object in
                    object.DepartmentID = data?.ID ?? 0
                }
               
                viewModel.requestUpdateUserInformation(updateObject.generateUserParams()) { (object) in
                
                }
                
            }else {
                completion(data ?? Department(params: [String : Any]()))
            }
        }
        alert.addAction(title: "Cancel", style: .cancel)
        alert.show()
    }
    
    func defaultGuestProfile(authenticateStat: Bool, runSwitchStat: Bool, safetyStat: Bool) {
        guard Utilities.instance.typeOfUserLogged() != .None else {
            return
        }
        
        if SPDeviceConnected() {
            self.resetBoxAuthentication(authenticate: authenticateStat, run_switch: runSwitchStat, safety: safetyStat)
            
            if LOGS.BUILDTYPE.boolValue == false {
                print("default push profile: func defaultGuestProfile(authenticateStat: Bool, runSwitchStat: Bool, safetyStat: Bool) | info: \(Utilities.instance.loginfo())")
            } else {
                print("default push profile: func defaultGuestProfile(authenticateStat: Bool, runSwitchStat: Bool, safetyStat: Bool) | info: \(Utilities.instance.loginfo())")
            }
            
            let setProfile = Constants.defaultProfileSettingsMovement
            let setSit = SPCommand.GetSetDownCommand(value: Double(Constants.defaultSittingPosition))
            let setStand = SPCommand.GetSetTopCommand(value: Double(Constants.defaultStandingPosition))
            let command = SPCommand.GenerateVerticalProfile(movements: setProfile)
            
            let _pulseObject = SPRealmHelper().retrievePulseObject(Utilities.instance.getLoggedEmail()) { (obj, exist) in
                print("pulse object: ", obj.UserProfile)
                print("pulse exist: ", exist)
                
                if (obj.UserProfile.isEmpty) {
                    Threads.performTaskAfterDealy(0.5) {
                        self.sendACommand(command: command, name: "SPCommand.GenerateVerticalProfile")
                    }
                }
            }
            //self.guestProfileSettings()
            Threads.performTaskAfterDealy(1.0) {
                self.sendACommand(command: setSit, name: "SPCommand.GetSetDownCommand")
                self.sendACommand(command: setStand, name: "SPCommand.GetSetTopCommand")
            }
            
            BaseController.mainController(nil)
        } else {
            
            let _pulseObject = SPRealmHelper().retrievePulseObject(Utilities.instance.getLoggedEmail()) { (obj, exist) in
                print("pulse object: ", obj.UserProfile)
                print("pulse exist: ", exist)
                //self.guestProfileSettings()
            }
            
            BaseController.mainController(nil)
        }
    }
    
    func guestProfileSettings() {
        let email = Utilities.instance.getLoggedEmail()
        
        let standingTime = Utilities.instance.defaultProfileSettingsLifestyle(type: ProfileSettingsType.Active.rawValue)
        let serial = Utilities.instance.getObjectFromUserDefaults(key: "serialNumber") as? String
        
        let profile_settings = ProfileSettings().createNewProfileObject()
        profile_settings.Email = email
        profile_settings.ProfileID = -1
        profile_settings.SerialNumber = serial ?? ""
        profile_settings.StandingTime1 = standingTime["StandingTimeInMinutesPeriod1"] as? Int ?? 5
        profile_settings.StandingTime2 = standingTime["StandingTimeInMinutesPeriod2"] as? Int ?? 0
        profile_settings.ProfileSettingType = ProfileSettingsType.Active.rawValue
        profile_settings.SittingPosition = Constants.defaultSittingPosition
        profile_settings.StandingPosition = Constants.defaultStandingPosition
        profile_settings.IsInteractive = false
        
        _ = SPRealmHelper().saveProfileSettings(profile_settings, email)
    }
    
    func executeCommitProfile() {
        //log.debug("commitProfile")
        let commitProfile = SPCommand.GetCommitProfile()
        
        if profileIsCommitted == false {
            while profileAttemptCount <= 3 {
                self.profileAttemptCount += 1
                //log.debug("profileCommitCount: \(self.profileAttemptCount)")
                //self.sendACommand(command: commitProfile)
            }
        } else {
            profileAttemptCount = 0
        }
        
    }
    
    func requestProfileSettingsIfAvailable() {
        guard Utilities.instance.isLoggedIn() else {
            return
        }
        
        let profile = ProfileSettingsViewModel()
        
        profile.forceLogout = { [weak self] () in
            self?.logoutUser(useGuest: false)
        }
        
        
        profile.alertMessage = { (title: String, message: String, tag: Int) in
            
            if tag == 4 {
               self.showAlert(title: title, message: message, tapped: {
                   self.logoutUser(useGuest: false)
               })
            } else if tag == 5 {
                   self.showAlert(title: title,
                                  message: message,
                                  positiveText: "common.yes".localize(),
                                  negativeText: "common.no".localize(),
                                  success: {
                                   self.checkBLEConnectivityIndicator()
                                   self.logoutUser(useGuest: true)
                                   
                                   },
                                  cancel: {
                                   SPBluetoothManager.shared.disconnect(forget: false)
                   })
               } else {
                   
                   self.displayStatusNotification(title: message, style: .danger)
               }
        }
        
        profile.getProfileSettings { (profile_settings) in
            //log.debug("profile_settings: \(profile_settings)")
        }
    }
    
    func callNumber(phoneNumber:String) {

        if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {

            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                     application.openURL(phoneCallURL as URL)

                }
            }
        }
    }
    
    //Deinitialize
    deinit {
        reachability?.stopListening()
    }
    
}

extension BaseController {
    
    /**
     Setup slider view to be available to all views..

    - Parameters: none
    - Returns: none
     
    */
    
    func setUpSlideMenu() {
        
        guard !Utilities.instance.IS_FREE_VERSION else {
            
            self.leadingSlideMenuConstraint?.constant = view.bounds.width

            boxControl.delegate = self
            boxControl.frame = CGRect(x: 0, y: 0, width: self.sliderView?.frame.size.width ?? .zero, height: self.sliderView?.frame.size.height ?? .zero)
            self.sliderView?.addSubview(boxControl)
            
            return
        }
        
                
        btnControlMenu?.setImage(UIImage(named: "desk_control_button"),
                                 for: .normal)
        
        btnControlMenu?.setImage(UIImage(named: "desk_control_button"),
                                 for: .highlighted)

        
        self.leadingSlideMenuConstraint?.constant = view.bounds.width

        boxControl.delegate = self
        boxControl.frame = CGRect(x: 0, y: 0, width: self.sliderView?.frame.size.width ?? .zero, height: self.sliderView?.frame.size.height ?? .zero)
        self.sliderView?.addSubview(boxControl)
        
    }
    
    func setUpNavMenu() {
        
        if Utilities.instance.isGuest {
            let item1 = DropdownItem(title: "Contact Support")
            items = [[item1]]
            menuView = DropdownMenu(navigationController: self.navigationController ?? UINavigationController(), items: [item1], selectedRow: selectedMenu)
        } else {
            let email = Utilities.instance.getUserEmail()
            
            let item1 = DropdownItem(title: email)
            let item2 = DropdownItem(title: "Contact Support")
            let item3 = DropdownItem(title: "Logout")
            
            items = [[item1, item2,item3]]
            menuView = DropdownMenu(navigationController: self.navigationController ?? UINavigationController(), items: [item1, item2, item3], selectedRow: selectedMenu)
        }
        menuView?.displaySelected = false
        menuView?.separatorStyle = .none
        menuView?.zeroInsetSeperatorIndexPaths = [IndexPath(row: 1, section: 0)]
        menuView?.delegate = self
        menuView?.rowHeight = 50
    }
    
    /**
     Toggle  box control buttons.

    - Parameters: Bool show
    - Returns: none
     
    */
    
    func checkToggleBoxMenuSlider() {
        
        if Utilities.instance.boxControlOpen {
            self.leadingSlideMenuConstraint?.constant = 0
            self.subMenuStackView?.isHidden = true
        } else {
            self.leadingSlideMenuConstraint?.constant = view.bounds.width
            self.subMenuStackView?.isHidden = false
        }
    }
    
    /**
     Hide or show box control buttons.

    - Parameters: Bool show
    - Returns: none
     
    */

    func showBoxControl(show: Bool) {
        
        if show {
            self.boxControlViewOpen = true
            Utilities.instance.boxControlOpen = true
            UIView.animate(withDuration: 0.5,
                                    delay: 0.0,
                                    options: [.curveEaseOut],
                                    animations: {
                                        self.leadingSlideMenuConstraint?.constant = 0
                                        self.subMenuStackView?.isHidden = true
                                        self.view.layoutIfNeeded()
            },
            completion: { finished in
                                        
            })
            
        } else {
            self.boxControlViewOpen = false
            Utilities.instance.boxControlOpen = false
            UIView.animate(withDuration: 0.5,
                                    delay: 0.0,
                                    options: [.curveEaseIn],
                                    animations: {
                                       self.leadingSlideMenuConstraint?.constant = self.view.bounds.width
                                       
                                       self.view.layoutIfNeeded()
                                       
            },
            completion: { finished in
                self.subMenuStackView?.fadeIn(0.5, delay: 0.5, completion: { complete in
                    self.subMenuStackView?.isHidden = false
                })
            })
        
        }
    }
    
    /**
     Slide menu actions to show box controls (sit / stand / stop)

    - Parameters: Button sender
    - Returns: none
     
    */
    
    @IBAction func onBtnShowControlMenu(sender: UIButton) {
        guard !Utilities.instance.IS_FREE_VERSION else {
            return
        }
        
       showBoxControl(show: true)
    }

    /**
     Show dialog on how to pair the device.

    - Parameters: none
    - Returns: none
     
    */
    
    func showPairingDialog() {
        let state = SPPermission.bluetooth.isAuthorized
        
        guard state else {

            let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                self.openSettingsApp()
            })
            self.displayAlertMessage(title: "permissions.title".localize(), message: "permissions.bluetooth_permission".localize(), successAction: ok)

            return
        }
        
        if Utilities.instance.isFirstAppLaunch() {
            // Create a custom view controller
            videoInstruction()
        } else {
            self.showDeviceList()
        }
        
    }
    
    func videoInstruction() {
        // Create a custom view controller
        let pairingView = PairingController.instantiateFromStoryboard(storyboard: "Settings") as! PairingController
        pairingView.delegate = self
        // Create the dialog
        let popup = PopupDialog(viewController: pairingView,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: true,
                                panGestureDismissal: false)

        // Present dialog
        present(popup, animated: true, completion: nil)
    }
    
    /**
     Register event observer stream of data.

    - Parameters: none
    - Returns: none
     
    */
    
    func registerEventObserver() {
        
        SwiftEventBus.onMainThread(self, name: ViewEventListenerType.BLEConnectivityStream.rawValue) {_ in
            
//            if !SPBluetoothManager.shared.desktopApphasPriority || !PulseDataState.instance.isDeskCurrentlyBooked {
//                Utilities.instance.dismissStatusNotification()
//            }
            
            
            self.checkBLEConnectivityIndicator()
            
            
        }
        
        SwiftEventBus.onMainThread(self, name: ViewEventListenerType.BaseViewDataStream.rawValue) {[weak self] result in
            let obj = result?.object
            
            /****** CoreOne Data  ******/
            
            if obj is SPCoreObject {
                let _core  = obj as? SPCoreObject
                self?.coreOne = _core
                self?.isRunSwitchStatus = _core?.RunSwitch
                self?.isSafetyStatus = _core?.SafetyStatus
                self?.isAuthenticated = _core?.UserAuthenticated
                
                self?.moveUpStatus = _core?.Movingupstatus ?? false
                self?.moveDownStatus =  _core?.Movingdownstatus ?? false
                
                self?.event.post(event: Event.Name("boxControlSensors"), object: _core)
                
            }
            
        }
        
        /*************************************** OLD INTERFACE ***************************************/
        
        self.event.addObserver(forEvent: Event.Name("UserProfileDeviceConnectivity"), callback: { event in
            //log.debug("UserProfileDeviceConnectivity")
            //check if we have profile available in cloud
            
            if Utilities.instance.isGuest {
                if self.SPDeviceConnected() {
//                    DispatchQueue.main.async {
//                        self.defaultGuestProfile(authenticateStat: self.isAuthenticated ?? false,
//                                                runSwitchStat: self.isRunSwitchStatus ?? false,
//                                                safetyStat: self.isSafetyStatus ?? false)
//                    }
                    
                }
            } else {
                
                let token = Utilities.instance.getToken()
                
                guard !token.isEmpty else {
                    return
                }
                
                if self.SPDeviceConnected() {
                   self.checkAndUpdateProfileSettings()
                }
            }
            
        })
        
        
    
    }
    
    /**
     Send a command to box.

    - Parameters: String command
    - Returns: none
     
    */
    
    func sendACommand(command: [UInt8], name: String) {
        
        print("send command PulseDataState.instance.isDeskCurrentlyBooked: \(PulseDataState.instance.isDeskCurrentlyBooked)")
        print("send command with name \(name)")
        
        guard !SPBluetoothManager.shared.desktopApphasPriority else {
            Utilities.instance.displayStatusNotification(title: "Desktop app active.", style: .warning)
            return
        }
        
        guard !PulseDataState.instance.isDeskCurrentlyBooked else {
            Utilities.instance.displayStatusNotification(title: "Desk is currently booked.", style: .warning)
            
            return
        }
        
        do {
            if LOGS.BUILDTYPE.boolValue == false {
                print("COMMAND NAME: \(name) | info: \(Utilities.instance.loginfo())")
            } else {
                print("COMMAND NAME: \(name) | info: \(Utilities.instance.loginfo())")
            }
            
            try SPBluetoothManager.shared.sendCommand(command: command)
        } catch let error as NSError {
            if LOGS.BUILDTYPE.boolValue == false {
                print("error sending  command: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                print("device state: \(SPBluetoothManager.shared.state) | info: \(Utilities.instance.loginfo())")
            } else {
                print("error sending  command: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                print("device state: \(SPBluetoothManager.shared.state) | info: \(Utilities.instance.loginfo())")
            }
        } catch {
            if LOGS.BUILDTYPE.boolValue == false {
                print("Unable to send command | info: \(Utilities.instance.loginfo())")
            } else {
                print("Unable to send command | info: \(Utilities.instance.loginfo())")
            }
        }
    }
    
    /**
     Request Pulse data from the box.

    - Parameters: PulseDataRequest type
    - Returns: none
     
    */
    
    func requestPulseData(type: PulseDataRequest) {
        
        if let peripheral = SPBluetoothManager.shared.state.peripheral {
            if peripheral.state == .connected {
               
                switch type {
                    case .All:
                        self.sendACommand(command: SPRequestParameters.All, name: type.stringRepresentation)
                        SwiftEventBus.postToMainThread(ViewEventListenerType.HomeDataStream.rawValue, sender: ["refreshProgress":false])
                    case .Pairing:
                        //self.sendACommand(command: SPRequestParameters.BLEHeartbeat, name: type.stringRepresentation)
                
                        DispatchQueue.main.async {
                            let state = UIApplication.shared.applicationState
                            if state == .active {
                                self.sendACommand(command: SPRequestParameters.BLEHeartbeatForeground, name: type.stringRepresentation)
                                print("requestPulseData heartbeat : \(SPRequestParameters.BLEHeartbeatForeground) | foreground | info: \(Utilities.instance.loginfo())")
                            }
                            else if state == .background {
                                self.sendACommand(command: SPRequestParameters.BLEHeartbeatBackground, name: type.stringRepresentation)
                                print("requestPulseData heartbeat : \(SPRequestParameters.BLEHeartbeatBackground) | background | info: \(Utilities.instance.loginfo())")
                            }
                        }
                
                    case .Report:
                        self.sendACommand(command: SPRequestParameters.Report, name: type.stringRepresentation)
                    case .Info:
                        self.sendACommand(command: SPRequestParameters.Information, name: type.stringRepresentation)
                    case .Profile:
                        self.sendACommand(command: SPRequestParameters.Profile, name: type.stringRepresentation)
                        SwiftEventBus.postToMainThread(ViewEventListenerType.HomeDataStream.rawValue, sender: ["refreshProgress":false])
                    case .CustomAll:
                        self.sendACommand(command: SPRequestParameters.All, name: type.stringRepresentation)
                    case .CustomProfile:
                        self.sendACommand(command: SPRequestParameters.Profile, name: type.stringRepresentation)
                    case .LegacyDetection:
                        self.sendACommand(command: SPRequestParameters.LegacyDetection, name: type.stringRepresentation)
                    case .AutoPresence:
                        self.sendACommand(command: SPRequestParameters.AutomaticDetection, name: type.stringRepresentation)
                    case .NeedPresence:
                        self.sendACommand(command: SPRequestParameters.CaptureAutomaticDetection, name: type.stringRepresentation)
                    case .PushCredentials:
                        self.sendACommand(command: SPRequestParameters.GetAESKey, name: type.stringRepresentation)
                }
            }
        }
    
    }
    
    /**
     Show safety status alert.

    - Parameters: none
    - Returns: none
     
    */
    
    func showSafetyStatusAlert(status: Bool) {
        
        guard status else {
            return
        }
        
        self.showAlertWithAction(title: "home.safety_title".localize(), message: "home.safety_message".localize(), buttonTitle:"buttons.ok".localize()) {
            let command = self.SPCommand.GetAknowledgeSafetyCommand()
            self.sendACommand(command: command, name: "SPCommand.GetAknowledgeSafetyCommand")
        }
    }
    
    func stopCommand() {
        let command = SPCommand.GetStopCommand()
        self.sendACommand(command: command, name: "SPCommand.GetStopCommand")
    }
    
    func sitCommand() {
        let command = SPCommand.GetMoveSittingCommand()
        self.sendACommand(command: command, name: "SPCommand.GetMoveSittingCommand")
    }
    
    func standCommand() {
        let command = SPCommand.GetMoveStandingCommand()
        self.sendACommand(command: command, name: "SPCommand.GetMoveStandingCommand")
    }
    
    /**
     Default Profile Settings a command to box.

    - Parameters: none
    - Returns: none
     
    */
    
    func synchronizeUserProfileSettings(defaultProfile: Bool, profile: ProfileSettings) {
        
       if SPDeviceConnected() {
            if LOGS.BUILDTYPE.boolValue == false {
                print("defaultProfile | true : func synchronizeUserProfileSettings(defaultProfile: Bool, profile: ProfileSettings) | info: \(Utilities.instance.loginfo())")
            } else {
                print("defaultProfile | true : func synchronizeUserProfileSettings(defaultProfile: Bool, profile: ProfileSettings) | info: \(Utilities.instance.loginfo())")
            }
        
        
            if defaultProfile {
                let setProfile = Constants.defaultProfileSettingsMovement
                let setSit = SPCommand.GetSetDownCommand(value: Double(Constants.defaultSittingPosition))
                let setStand = SPCommand.GetSetTopCommand(value: Double(Constants.defaultStandingPosition))
                
                let command = SPCommand.GenerateVerticalProfile(movements: setProfile)
                Threads.performTaskAfterDealy(1.0) {
                    self.sendACommand(command: command, name: "SPCommand.GenerateVerticalProfile")
                }
                
                Threads.performTaskAfterDealy(1.0) {
                    self.sendACommand(command: setSit, name: "SPCommand.GetSetDownCommand")
                    self.sendACommand(command: setStand, name: "SPCommand.GetSetTopCommand")
                }
                
                Utilities.instance.saveDefaultValueForKey(value: false, key: "should_syncronize")
                
            } else {
                
                if LOGS.BUILDTYPE.boolValue == false {
                    print("defaultProfile | false : func synchronizeUserProfileSettings(defaultProfile: Bool, profile: ProfileSettings) | info: \(Utilities.instance.loginfo())")
                } else {
                    print("defaultProfile | false : func synchronizeUserProfileSettings(defaultProfile: Bool, profile: ProfileSettings) | info: \(Utilities.instance.loginfo())")
                }
                
               let setSit = SPCommand.GetSetDownCommand(value: Double(Constants.defaultSittingPosition))
               let setStand = SPCommand.GetSetTopCommand(value: Double(Constants.defaultStandingPosition))
                
                let setProfile = SPCommand.CreateVerticalProfile(settings: profile)
                self.sendACommand(command: setProfile, name: "SPCommand.CreateVerticalProfile")
                
                Threads.performTaskAfterDealy(1.0) {
                    self.sendACommand(command: setSit, name: "SPCommand.GetSetDownCommand")
                    self.sendACommand(command: setStand, name: "SPCommand.GetSetTopCommand")
                }
                
              Utilities.instance.saveDefaultValueForKey(value: false, key: "should_syncronize")
            }
             
         } else {
            Utilities.instance.saveDefaultValueForKey(value: true, key: "should_syncronize")
        }
    }
    
    func resetBoxAuthentication(authenticate: Bool, run_switch: Bool, safety: Bool) {
        if authenticate {
            let authenticatedOff = SPCommand.GetUserAuthenticatedOffCommand()
            let authenticatedOn = SPCommand.GetUserAuthenticatedOnCommand()
            //self.sendACommand(command: authenticatedOff, name: "SPCommand.GetUserAuthenticatedOffCommand")
            //self.sendACommand(command: authenticatedOn, name: "SPCommand.GetUserAuthenticatedOnCommand")
//            Threads.performTaskAfterDealy(1.0) {
//                self.sendACommand(command: authenticatedOn, name: "SPCommand.GetUserAuthenticatedOnCommand")
//            }

        } else {
            let authenticatedOn = SPCommand.GetUserAuthenticatedOnCommand()
            //self.sendACommand(command: authenticatedOn, name: "SPCommand.GetUserAuthenticatedOnCommand")
        }
        
//        let authenticatedOn = SPCommand.GetUserAuthenticatedOnCommand()
//        self.sendACommand(command: authenticatedOn, name: "SPCommand.GetUserAuthenticatedOnCommand")
//
        if (run_switch == true && safety == false) {
            Threads.performTaskAfterDealy(1.0) {
                let moveSit = self.SPCommand.GetMoveSittingCommand()
                //self.sendACommand(command: moveSit, name:"SPCommand.GetMoveSittingCommand")
            }
        }
        
        if let peripheral = SPBluetoothManager.shared.state.peripheral {
            if peripheral.spDesiredCharacteristic != nil {
                //SPBluetoothManager.shared.sendHeartBeat(peripheral, peripheral.spDesiredCharacteristic!)
            }
        }
    }
    
    func openSettingsApp() {
        let url = URL(string:UIApplication.openSettingsURLString)
        if UIApplication.shared.canOpenURL(url!){
            // can open succeeded.. opening the url
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
    func openSupportPage() {
        if let url = URL(string: Constants.supportUrl) {
            UIApplication.shared.open(url)
        }
    }
    
    func AppPermissionRequest() {
    
        
        let locationPermission = SPPermission.locationWhenInUse.isAuthorized
        let notificationPermission = SPPermission.notification.isAuthorized
        
        var permissions:[SPPermission] = [SPPermission]()
        
        if locationPermission == false {
            permissions.append(SPPermission.locationWhenInUse)
        }
        
        if notificationPermission == false {
            permissions.append(SPPermission.notification)
        }
        
        guard permissions.count > 0 else {
            return
        }
        
        let controller = SPPermissions.list(permissions)
        controller.footerText = "Permissions are necessary for the application to work and perform correctly."
        controller.dataSource = self
        controller.delegate = self
        //controller.bounceAnimationEnabled = false
        controller.present(on: self)
        
    }
    
    @objc func allowLocationService() {}
    
    func savePredefineLocation() {
        
        guard Utilities.instance.typeOfUserLogged() != .None else {
            return
        }
        /**
         Predefine location
         ----------------------------------------
         */
        let _user_email = Utilities.instance.getLoggedEmail()
        let dataHelper = SPRealmHelper()
        let clampedRadius = min(100.0, LocationService.shared.manager.maximumRegionMonitoringDistance)
        let geoLocationEntry = GeoLocator(coordinate: Location(latitude: 46.07883467343269, longitude: -64.82904444454687),
                                          radius: clampedRadius,
                                          identifier: "SmartpodsOfficeIn",
                                          eventType: EventType.onEntry)
        let geoLocationExit = GeoLocator(coordinate: Location(latitude: 46.094388504697676, longitude: -64.80141505779832),
                                          radius: clampedRadius,
                                          identifier: "SmartpodsOfficeOut",
                                          eventType: EventType.onExit)
        _ = dataHelper.saveFacilityLocation(geoLocationEntry, _user_email)
        _ = dataHelper.saveFacilityLocation(geoLocationExit, _user_email)
        
        

   
        
        
        
        /**
         ----------------------------------------
         */
        
    }
    
    func guestPredefinedData() {
        let viewModel = UserViewModel()
        
        let json = readJSONFromFile(fileName: "Guest")
        let rawJson = json as? [String: Any] ?? [String: Any]()
        let _user = rawJson["User"] as? [String: Any] ?? [String: Any]()
        let _user_app_state = rawJson["UserAppState"] as? [String: Any] ?? [String: Any]()
        let _user_profile = rawJson["Settings"] as? [String: Any] ?? [String: Any]()
        
        viewModel.guestUserAccount(email: Utilities.instance.getLoggedEmail(),
                                  data: _user)
        
        viewModel.guestAppState(email: Utilities.instance.getLoggedEmail(),
                                data: _user_app_state)
        
        viewModel.guestDefaultProfile(email: Utilities.instance.getLoggedEmail(),
                                data: _user_profile)
    }
}

extension BaseController: BoxMainControlsDelegate {
    func stopAction() {
        if self.SPDeviceConnected() {
            Utilities.instance.boxControlButtonTag = 0
            self.stopCommand()
        }
    }
    
    func sitAction() {
        if self.SPDeviceConnected() {
            Utilities.instance.boxControlButtonTag = 1
            self.sitCommand()
        }
    }
    
    func standAction() {
        if self.SPDeviceConnected() {
            Utilities.instance.boxControlButtonTag = 2
            self.standCommand()
        }
    }
    
    func closePanel() {
        Utilities.instance.boxControlButtonTag = 0
        self.showBoxControl(show: false)
    }
    
    
}

extension BaseController: PairingControllerDelegate {
    func showDeviceList() {
        
        guard Utilities.instance.typeOfUserLogged() != .None else {
            return
        }
        
        let dataHelper = SPRealmHelper()
        let email = Utilities.instance.getLoggedEmail()
       
        do {
            let pulse = try dataHelper.getPulseDevice(email)

            guard pulse.State != PulseState.ResetBond.rawValue else {
                SPBluetoothManager.shared.requestPairSSID = false
                SPBluetoothManager.shared.defautlPairSSID = false
                SPBluetoothManager.shared.heartBeatSentCount = 0
                self.showAlertWithAction(title: "generic.error_title".localize(), message: "generic.error_code_14".localize(), buttonTitle: "common.ok".localize()) {
                    let device = ["State": PulseState.Disconnected.rawValue] as [String : Any]
                    self.PulseDeviceStateUpdate(params: device)
                    self.openSettingsApp()
                }
                return
            }
            
            let deviceList = DeviceListViewController.instantiateFromStoryboard(storyboard: "Settings") as! DeviceListViewController
            deviceList.delegate = self
            presentPanModal(deviceList)
        }catch {
            if LOGS.BUILDTYPE.boolValue == false {
                print("Realm getPulseDevice error | info: \(Utilities.instance.loginfo())")
            } else {
                print("Realm getPulseDevice error | info: \(Utilities.instance.loginfo())")
            }
        }
    }
}

extension BaseController: SPBluetoothManagerConnectivityDelegate {
    func deviceNotInRange() {
        showAlert(title: "Error", message: "Not in range")
        
    }
    
    func noticeMessages(type: BLETypeNotice) {
        
        if type == .BLuetoothNotPowerOn {
            /**
                let url = URL(string:UIApplication.openSettingsURLString)
                if UIApplication.shared.canOpenURL(url!){
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
             */
            
            self.showAlert(title: "generic.notice".localize(),
                           message: "generic.bluetooth_off".localize()) {
                            self.dismiss(animated: true, completion: nil)
            }
            
        }
        
        if type == .AdapterError {
            self.statusBarErrorNotification.titleLabel?.text = "generic.ble_adapter_error".localize()
            self.statusBarErrorNotification.show()
        }
        
    }
    
    @objc func shouldSetDeviceConnected(connected: Bool) {
    }
    
    @objc func resumeBleConnectivity() {
        checkAndUpdateProfileSettings()
        
        if SPDeviceConnected() {
            //let authenticatedOn = SPCommand.GetUserAuthenticatedOnCommand()
            //self.sendACommand(command: authenticatedOn, name: "SPCommand.GetUserAuthenticatedOnCommand")
        }
    }
}

extension BaseController: DropdownMenuDelegate {
    func dropdownMenu(_ dropdownMenu: DropdownMenu, didSelectRowAt indexPath: IndexPath) {
        selectedMenuIndexPath = indexPath
        
        if indexPath.row != items.count - 1 {
            self.selectedMenu = indexPath.row
        }
        
        if Utilities.instance.isGuest {
            switch indexPath.row {
                case 0:
                    self.openSupportPage()
            default: break
            }
        } else {
            switch indexPath.row {
                case 1:
                    self.openSupportPage()
                case 2:
                    self.logoutUser(useGuest:false)
            default: break
            }
        }
        
        
        
    }
    
}

extension BaseController: DropUpMenuDelegate {
    func dropUpMenu(_ dropUpMenu: DropUpMenu, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func dropUpMenuCancel(_ dropUpMenu: DropUpMenu) {
        
    }
}


extension BaseController: DeviceListViewControllerDelegate {
    func toggleBleIndicator() {
        checkBLEConnectivityIndicator()
    }
}

extension BaseController: SPPermissionsDataSource, SPPermissionsDelegate {
    
    /**
     Configure permission cell here.
     You can return permission if want use default values.
     
     - parameter cell: Cell for configure. You can change all data.
     - parameter permission: Configure cell for it permission.
     */
    func configure(_ cell: SPPermissionTableViewCell, for permission: SPPermission) -> SPPermissionTableViewCell {
        
        if permission == .bluetooth {
            cell.permissionTitleLabel.text = "Bluetooth"
            cell.permissionDescriptionLabel.text = "We use bluetooth to connect to the Smartpods hardware device."
            cell.button.allowTitle = "Allow"
            cell.button.allowedTitle = "Allowed"

            // Colors
            cell.iconView.color = .systemBlue
            cell.button.allowedBackgroundColor = .systemBlue
            cell.button.allowTitleColor = .systemBlue
        }
       
        if permission == .notification {
            cell.permissionTitleLabel.text = "Notification"
            cell.permissionDescriptionLabel.text = "We use local notification to enable user notifications."
            cell.button.allowTitle = "Allow"
            cell.button.allowedTitle = "Allowed"

            // Colors
            cell.iconView.color = .systemBlue
            cell.button.allowedBackgroundColor = .systemBlue
            cell.button.allowTitleColor = .systemBlue
        }
        
        if permission == .locationWhenInUse {
            cell.permissionTitleLabel.text = "Location"
            cell.permissionDescriptionLabel.text = "We requires constant access to your phone’s location to notify you when you enter or leave a geofence."
            cell.button.allowTitle = "Allow"
            cell.button.allowedTitle = "Allowed"

            // Colors
            cell.iconView.color = .systemBlue
            cell.button.allowedBackgroundColor = .systemBlue
            cell.button.allowTitleColor = .systemBlue
        }
    
        return cell
    }
    
    /**
     Call when controller closed.
     
     - parameter ids: Permissions ids, which using this controller.
     */
    func didHide(permissions ids: [Int]) {
        let permissions = ids.map { SPPermission(rawValue: $0)! }
        //log.debug("Did hide with permissions: \( permissions.map { $0.name })")
    }
    
    /**
    Call when permission allowed.
    Also call if you try request allowed permission.
    
    - parameter permission: Permission which allowed.
    */
    func didAllow(permission: SPPermission) {
        //log.debug("Did allow: \(permission.name)")
        Utilities.instance.permissionViewShown = true
        
        if permission.name == "Location When Use" {
            self.allowLocationService()
            self.savePredefineLocation()
        }
    }
    
    /**
    Call when permission denied.
    Also call if you try request denied permission.
    
    - parameter permission: Permission which denied.
    */
    func didDenied(permission: SPPermission) {
        Utilities.instance.permissionViewShown = true
        //log.debug("Did denied: \(permission.name)")
    }
    
    /**
     Alert if permission denied. For disable alert return `nil`.
     If this method not implement, alert will be show with default titles.
     
     - parameter permission: Denied alert data for this permission.
     */
    func deniedData(for permission: SPPermission) -> SPPermissionDeniedAlertData? {
        if permission == .bluetooth {
            let data = SPPermissionDeniedAlertData()
            data.alertOpenSettingsDeniedPermissionTitle = "Permission denied"
            data.alertOpenSettingsDeniedPermissionDescription = "Please, go to Settings and allow permission."
            data.alertOpenSettingsDeniedPermissionButtonTitle = "Settings"
            data.alertOpenSettingsDeniedPermissionCancelTitle = "Cancel"
            return data
        } else {
            // If returned nil, alert will not show.
            //log.debug("Alert for \(permission.name) not show, becouse in datasource returned nil for configure data. If you need alert, configure this.")
            self.showAlert(title: "Notice", message: "Permission '\(permission.name)' was denied. Please enable it in the app settings.")
            return nil
        }
    }
}

extension BaseController: PulseDataStateDelegate {
    func notificationAlertMessages(title: String, message: String) {
        showAlert(title: "generic.notice".localize(), message:"generic.desk_adjusted".localize())
    }
    
    
}
