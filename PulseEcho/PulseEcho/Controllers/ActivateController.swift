//
//  ActivateController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-13.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Material
import SwiftEventBus

class ActivateController: BaseController {
    
    //STORYBOARD OUTLETS
    
    @IBOutlet weak var lblActivateTitle: UILabel?
    @IBOutlet weak var txtCode: TextField?
    @IBOutlet weak var btnSubmit: UIButton?
    @IBOutlet weak var btnBack: UIButton?
    @IBOutlet weak var btnResendActivation: UIButton?
    
    //CLASS VARIABLES
    var viewModel: LoginViewModel?
    var email: String?
    var authenticated: Bool?
    var safetyStatus: Bool?
    var runSwitchStatus: Bool?
    var userPassword: String?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblActivateTitle?.adjustContentFontSize()
        btnSubmit?.titleLabel?.adjustContentFontSize()
        btnBack?.titleLabel?.adjustContentFontSize()
        txtCode?.adjustContentFontSize()
        createCustomNavigationBar(title: "welcome.activate".localize(), user: "", cloud: false, back: false, ble: false)
        customizeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
 
    }
    
    override func customizeUI() {
        
        lblActivateTitle?.text = "welcome.activate".localize()
        txtCode?.placeholder = "welcome.activate_placeholder".localize()
        btnSubmit?.setTitle("welcome.submit".localize(), for: .normal)
        btnBack?.setTitle("common.back".localize(), for: .normal)
        
        btnSubmit?.titleLabel?.adjustContentFontSize()
        btnBack?.titleLabel?.adjustContentFontSize()
        btnResendActivation?.titleLabel?.adjustContentFontSize()
        
        btnSubmit?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnSubmit?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        
        btnBack?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnBack?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        
        btnResendActivation?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnResendActivation?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        
        
        SwiftEventBus.onMainThread(self, name: ViewEventListenerType.ActivateDataStream.rawValue) { [weak self] result in
                let obj = result?.object
            
                /********** CoreOne Data **********/
                if obj is SPCoreObject {
                    let _core = obj as? SPCoreObject
                    self?.runSwitchStatus = _core?.RunSwitch
                    self?.safetyStatus = _core?.SafetyStatus
                    self?.authenticated = _core?.UserAuthenticated
                }
        }
        
        /*********************** OLD INTERFACE ***********************/
        
        SwiftEventBus.onMainThread(self, name: "coreDataObjectEvent") { [weak self] result in
                if let obj = result?.object {
                    if obj is SPCoreObject {
                        let _core = obj as? SPCoreObject
                        self?.runSwitchStatus = _core?.RunSwitch
                        self?.safetyStatus = _core?.SafetyStatus
                        self?.authenticated = _core?.UserAuthenticated
                    }
            }
        }
        
    }
    
    override func bindViewModelAndCallbacks() {
        self.viewModel = LoginViewModel()
        
        viewModel?.alertMessage = { [weak self](title: String, message: String, tag: Int) in
            self?.displayStatusNotification(title: message, style: .danger)
        }

        viewModel?.showIndicator = { [weak self] (show: Bool) in
            self?.showActivityIndicator(show: show)
        }
        
        viewModel?.successResponse = { (object: Any) in
            //check result code if account is verified
           Utilities.instance.isGuest = false
           SPBluetoothManager.shared.startReceivingData = true
            
            //self.checkBoxUserAuthenticated()
        }
        
        viewModel?.loginResponse = { (object: Any, user: Any) in
            let response = object as? Login
            let _user = user as? User
            
            self.user = _user
            
            switch response?.ResultCode {
                case 0:
                
                   Utilities.instance.isGuest = false
                     let connected = Utilities.instance.isBLEBoxConnected()
                    
                    if _user?.Email.isEmpty ?? false && connected == false {
                        self.showAlertWithAction(title: "generic.notice".localize(),
                                                 message: "login.no_user".localize(),
                                                 buttonTitle: "common.ok".localize()) {
                                        self.navigationController?.popToRootViewController(animated: true)
                        }
                    } else {
                        if connected {
                            SPBluetoothManager.shared.startReceivingData = true
                            
                        }
                        
                        if _user?.Email.isEmpty ?? false == false {
                            self.checkBoxUserAuthenticated()
                        } else {
                            self.showAlertWithAction(title: "generic.notice".localize(),
                                                                            message: "login.no_user".localize(),
                                                                            buttonTitle: "common.ok".localize()) {
                                                                   self.navigationController?.popToRootViewController(animated: true)
                        }
                      }
                    }
                
                case 1:
                    self.showAlertWithAction(title: "generic.notice".localize(),
                                            message: "login.no_user".localize(),
                                            buttonTitle: "common.ok".localize()) {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                    
                    self.showAlert(title: "generic.notice".localize(),
                                   message: "login.no_user".localize(),
                                   positiveText: "common.ok".localize(),
                                   negativeText: "common.support".localize()) {
                        self.navigationController?.popToRootViewController(animated: true)
                    } cancel: {
                        self.navigationController?.popToRootViewController(animated: true)
                        self.openSupportPage()
                    }


                case 2:
                    self.displayNotificationMessage(title: "generic.error_title".localize(), subTitle: response?.Message ?? "login.account_locked".localize(), style: .info)
                case 3:
                    self.displayNotificationMessage(title: "generic.error_title".localize(), subTitle: "generic.account_verification_failed".localize(), style: .danger)
               case 4:
                    self.displayNotificationMessage(title: "generic.notice".localize(), subTitle: "generic.invalid_org_or_desk".localize(), style: .danger)
                case 5:
                    self.displayNotificationMessage(title: "generic.notice".localize(), subTitle: "generic.desk_not_registered".localize(), style: .danger)
                default:
                    self.displayNotificationMessage(title: "generic.error_title".localize(), subTitle: "generic.other_error".localize(), style: .danger)
            }
        }
        
        viewModel?.loginResponseWithNoOrgCode = { (object: Any, user: String) in
            let response = object as? Login
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
        
        textFieldDismissKeyboard(sender: self.txtCode ?? UITextField())
        
        switch sender.tag {
        case 0:
            let _activation_code = txtCode?.text ?? ""
            viewModel?.initializeActivateUser(email: email ?? "", code: _activation_code, password: userPassword ?? "", closure: { (object: Any, user: User) in
                
            })
            break
        case 1:
            self.navigationController?.popToRootViewController(animated: false)
            break
            
        case 2:
            viewModel?.resendActivationCode(email ?? "", completion: { (object) in
                if object is GenericResponse {
                    let response = object as! GenericResponse
                    
                    if response.Success {
                        self.displayNotificationMessage(title: "success.title".localize(), subTitle: "login.activate_resend_code".localize(), style: .success)
                    } else {
                        self.displayNotificationMessage(title: "generic.error_title".localize(), subTitle: response.Message, style: .danger)
                    }
                }
            })
        default:
            break
        }
    }
    
    func checkBoxUserAuthenticated() {
            
            if SPDeviceConnected() {
                if self.authenticated ?? false {
                    self.resetBoxAuthentication(authenticate: self.authenticated ?? false, run_switch: self.runSwitchStatus ?? false, safety: self.safetyStatus ?? false)
                    BaseController.mainController(nil)
                }
            } else {
                BaseController.mainController(nil)
            }
            
        }

}
