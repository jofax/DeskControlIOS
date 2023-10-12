//
//  LoginController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-03.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Localize
import Material
import SwiftEventBus
import CoreLocation
import AppTrackingTransparency

class LoginController: BaseController {
    
    //STORYBOARD OUTLETS

    @IBOutlet weak var txtUsername: TextField?
    @IBOutlet weak var txtPassword: TextField?
    @IBOutlet weak var btnLogin: UIButton?
    @IBOutlet weak var btnRegister: UIButton?
    @IBOutlet weak var btnGuest: UIButton?
    @IBOutlet weak var btnForgotPassword: UIButton?
    @IBOutlet weak var lblLoginTitle: UILabel?
    @IBOutlet weak var lblPassword: UILabel?
    @IBOutlet weak var imgLogo: UIView?
    
    
    //CLASS VARIABLES
    var authenticated: Bool?
    var safetyStatus: Bool?
    var runSwitchStatus: Bool?
    var tapCount : Int = 0
    private var viewModel: LoginViewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblLoginTitle?.adjustContentFontSize()
        lblPassword?.adjustContentFontSize()
        
        customizeUI()
        
        btnLogin?.titleLabel?.adjustContentFontSize()
        btnRegister?.titleLabel?.adjustContentFontSize()
        btnForgotPassword?.titleLabel?.adjustContentFontSize()
        btnGuest?.titleLabel?.adjustContentFontSize()
        
        txtUsername?.adjustContentFontSize()
        txtPassword?.adjustContentFontSize()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        imgLogo?.addGestureRecognizer(tap)
        
        requestTrackingPermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createCustomNavigationBar(title: "", user: "", cloud: false, back: false, ble: false)
        populatePreviousLoggedUser()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        tapCount += 1
        
        if tapCount == 5 {
            tapCount = 0
            
            //let command = SPCommand.DisableHeartBeat()
            //self.sendACommand(command: command, name: "SPCommand.DisableHeartBeat")
        }
    }
    
    func requestTrackingPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .notDetermined:
                    break
                case .restricted:
                    break
                case .denied:
                    break
                case .authorized:
                    print("authorized tracking")
                @unknown default:
                    break
                }
            }
        } else {}
    }
    
    override func customizeUI() {
        
        lblLoginTitle?.text = "welcome.login".localize()
        lblPassword?.text = "welcome.password".localize()
        txtUsername?.placeholder = "welcome.email".localize()
        txtPassword?.placeholder = "welcome.password".localize()
        btnLogin?.setTitle("welcome.login".localize(), for: .normal)
        btnRegister?.setTitle("welcome.register".localize(), for: .normal)
        btnForgotPassword?.setTitle("welcome.forgot".localize(), for: .normal)
        btnGuest?.setTitle("welcome.guest".localize(), for: .normal)
        
        
        btnLogin?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnLogin?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        
        btnRegister?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnRegister?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        
        btnRegister?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnRegister?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        
        btnGuest?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnGuest?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        
        btnForgotPassword?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnForgotPassword?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
 
    }
    
    override func bindViewModelAndCallbacks() {
        
        viewModel.alertMessage = { [weak self](title: String, message: String, tag: Int) in
        
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
        
        viewModel.enableState = {(enable: Bool) in
            
        }
        
        viewModel.showIndicator = { [weak self] (show: Bool) in
            self?.showActivityIndicator(show: show)
        }
        
        viewModel.synchronizeConfigurations = { [weak self] (defaultProfile: Bool, object: Any) in
            let _profile = object as? ProfileSettings
            let SPCommand = PulseCommands()
            
            if _profile?.ProfileSettingType != -1 {
                self?.synchronizeUserProfileSettings(defaultProfile: defaultProfile, profile: _profile ?? ProfileSettings(params: [String : Any]()))
            } else {
                //push profile
                
                self?.viewModel.userProfileSettings.getProfileSettings(completion: { (profile) in
                    if profile.ProfileSettingType != -1 {
                        let userProfile = SPCommand.CreateVerticalProfile(settings: profile)
                        let setSit = SPCommand.GetSetDownCommand(value: Double(profile.SittingPosition))
                        let setStand = SPCommand.GetSetTopCommand(value: Double(profile.StandingPosition))

                        SPBluetoothManager.shared.pushProfileTotheBox(profile: userProfile, sit: setSit, stand: setStand)
                        
                    } else {
                        let _email = self?.txtUsername?.text ?? ""
                        self?.viewModel.userProfileSettings.createDefaultProfileSettings(pushToBox: true, emailAdress: _email)
                    }
                })
                
            }
            
        }
        
        viewModel.loginResponse = { (object: Any, user: Any) in
            let response = object as? Login
            
            switch response?.ResultCode {
                case 0:
                    Utilities.instance.isGuest = false
                    BaseController.mainController(nil)
                case 1,8:
                    let _email = self.txtUsername?.text ?? ""
                    let _password = self.txtPassword?.text ?? ""
                    let controller = ActivateController.instantiateFromStoryboard(storyboard: "Login") as! ActivateController
                    controller.email = _email
                    controller.userPassword = _password
                    self.navigationController?.pushViewController(controller, animated: true)
                case 2:
                    self.displayNotificationMessage(title: "generic.error_title".localize(), subTitle: "login.account_locked".localize(), style: .info)
                case 3:
                    self.displayNotificationMessage(title: "generic.error_title".localize(), subTitle: "generic.account_verification_failed".localize(), style: .danger)
                case 4:
                    self.displayNotificationMessage(title: "generic.notice".localize(), subTitle: "generic.invalid_org_or_desk".localize(), style: .danger)
                case 5:
                    self.showAlert(title: "generic.notice".localize(),
                                   message: "generic.desk_not_registered".localize(),
                                   positiveText: "common.yes".localize(),
                                   negativeText: "common.no".localize(),
                                   success: {
                                    self.checkBLEConnectivityIndicator()
                                    self.logoutUser(useGuest: true)
                                    
                                    },
                                   cancel: {
                                    SPBluetoothManager.shared.disconnect(forget: false)
                    })
            
                default:
                    self.displayNotificationMessage(title: "generic.error_title".localize(), subTitle: "generic.other_error".localize(), style: .danger)
                    print("loginResponse error | info: \(Utilities.instance.loginfo())")
            }
        }
        
        viewModel.loginResponseWithNoOrgCode = { (object: Any, user: String) in
            let deviceList = DeviceListViewController.instantiateFromStoryboard(storyboard: "Settings") as! DeviceListViewController
            deviceList.delegate = self
            self.navigationController?.pushViewController(deviceList, animated: true)
        }

    }
    
    /**
     Button actions.

    - Parameters: Button sender
    - Returns: none.
    */
    
    @IBAction func onBtnActions(sender: UIButton) {
        textFieldDismissKeyboard(sender: self.txtUsername ?? UITextField())
        textFieldDismissKeyboard(sender: self.txtPassword ?? UITextField())
        
        switch sender.tag {
        case 0:
            let _email = txtUsername?.text ?? ""
            let _password = txtPassword?.text ?? ""
            viewModel.intializeUserLogin(username: _email,
                                          password: _password,
                                          closure: { (object: Any, user: User) in
                                            
                                            
                
            })
            break
        case 1:
            viewModel.cancelCurrentRequest()
            clearTextField(sender: self.txtUsername ?? UITextField())
            clearTextField(sender: self.txtPassword ?? UITextField())
            
            let controller = RegisterController.instantiateFromStoryboard(storyboard: "Login", name: "RegisterController") as! RegisterController
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case 2:
            viewModel.cancelCurrentRequest()
            
            clearTextField(sender: self.txtUsername ?? UITextField())
            clearTextField(sender: self.txtPassword ?? UITextField())
            
            let controller = ForgotPasswordController.instantiateFromStoryboard(storyboard: "Login", name: "ForgotPasswordController") as! ForgotPasswordController
            self.navigationController?.pushViewController(controller, animated: true)
            break
        case 3:
            loggedAsGuest()
        default:
            break
        }
    }
    
    func loggedAsGuest() {
        Utilities.instance.isGuest = true
        Utilities.instance.saveDefaultValueForKey(value: CURRENT_LOGGED_USER.Guest.rawValue, key: Constants.current_logged_user_type)
        Utilities.instance.saveDefaultValueForKey(value: "guest", key: Constants.email)
        
        guestPredefinedData()
        
        guard SPRealmHelper().profileExists(Utilities.instance.getLoggedEmail()) == false else {
            if SPDeviceConnected() {
                _  = ProfileSettingsViewModel().getLocalUserProfileInformation(email: Utilities.instance.getLoggedEmail()) { (profile) in
                    let userProfile = self.SPCommand.CreateVerticalProfile(settings: profile)
                    let setSit = self.SPCommand.GetSetDownCommand(value: Double(profile.SittingPosition))
                    let setStand = self.SPCommand.GetSetTopCommand(value: Double(profile.StandingPosition))
                    SPBluetoothManager.shared.pushProfileTotheBox(profile: userProfile, sit: setSit, stand: setStand)
                }
            }
           
            BaseController.mainController(nil)
            return
        }
        
        self.defaultGuestProfile(authenticateStat: self.authenticated ?? false,
                                 runSwitchStat: self.runSwitchStatus ?? false,
                                 safetyStat: self.safetyStatus ?? false)
    }
    
    func populatePreviousLoggedUser() {
        let email = Utilities.instance.getLoggedEmail()
        
        guard (!email.isEmpty && email != "guest") else {
            return
        }
        
        txtUsername?.text = email
    }
}
