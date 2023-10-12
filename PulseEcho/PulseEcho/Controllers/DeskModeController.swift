//
//  DeskModeController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-26.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import SwiftEventBus

protocol DeskModeControllerDelegate {
    func deskSettingsRedirectToHome()
}

class DeskModeController: BaseController {

    //STORYBOARD OUTLETS
    @IBOutlet weak var lblDeskModeTitle: UILabel?
    @IBOutlet weak var txtDeskModeDesc: UITextView?
    @IBOutlet weak var btnAutomatic: UIButton?
    @IBOutlet weak var btnInteractive: UIButton?
    @IBOutlet weak var btnManual: UIButton?
    @IBOutlet weak var btnSave: UIButton?
    
    //CLASS VARIABLES
    var deskModeDelegate: DeskModeControllerDelegate?
    var coreOneObject: SPCoreObject?
    var runSwitchStatus: Bool?
    var semiAutomatic: Bool?
    
    var selectedMode: String = ""
    var selectedTag: Int = 0
    var userProfileSettings = ProfileSettings(params: [String : Any]())
    var viewModel: ProfileSettingsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerEventObserver()
        let email = Utilities.instance.getUserEmail()
        SPBluetoothManager.shared.event = self.event
        createCustomNavigationBar(title: "desk_mode.title".localize(), user: email, cloud: true, back: false, ble: true)
        self.selectedMode = Utilities.instance.getObjectFromUserDefaults(key: "desk_mode") as? String ?? "Manual"
       
        customizeUI()
        
        // Do any additional setup after loading the view
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         self.selectedMode = Utilities.instance.getObjectFromUserDefaults(key: "desk_mode") as? String ?? "Manual"
         modeDescription(mode: selectedMode)
        
        if !Utilities.instance.isGuest {
            getProfileSettings()
        } else {
            getLocalProfileSettings()
        }
    }
    
    override func customizeUI() {
        self.viewModel = ProfileSettingsViewModel()
        
        viewModel?.forceLogout = { [weak self] () in
            self?.logoutUser(useGuest: false)
        }
        
        lblDeskModeTitle?.adjustContentFontSize()
        
        btnAutomatic?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnAutomatic?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        btnAutomatic?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .selected)
        
        btnInteractive?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnInteractive?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        btnInteractive?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .selected)
        
        btnManual?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnManual?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        btnManual?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .selected)
        
        btnSave?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnSave?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        btnSave?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .selected)
        
        lblDeskModeTitle?.adjustContentFontSize()
        btnAutomatic?.titleLabel?.adjustContentFontSize()
        btnInteractive?.titleLabel?.adjustContentFontSize()
        btnManual?.titleLabel?.adjustContentFontSize()
        txtDeskModeDesc?.adjustContentFontSize()
        
//        lblDeskModeTitle?.text = "desk_mode.auto_title".localize()
//        txtDeskModeDesc?.text = "desk_mode.auto_desc".localize()
        
        
        SwiftEventBus.onMainThread(self, name: ViewEventListenerType.DeskModeDataStream.rawValue) { [weak self]result in
            let obj = result?.object
            
             /**** CoreOne Data ****/
            if obj is SPCoreObject {
                let _core = obj as? SPCoreObject
                self?.coreOneObject = _core
                self?.runSwitchStatus = _core?.RunSwitch
                self?.semiAutomatic = _core?.UseInteractiveMode
                //print("run switch:", self?.runSwitchStatus)
            }
            
        }
        
        setDeskModeSelected(withCommand: false, mode: self.selectedMode)
        
    }
    
    @IBAction func onBtnAction(sender: UIButton) {
        if SPDeviceConnected() {
            setButtonTabSelected(sender: [btnAutomatic ?? UIButton(), btnInteractive ?? UIButton(), btnManual ?? UIButton()])
                   sender.isSelected = !sender.isSelected
                 print("sender.tag : ", sender.tag)
                   switch sender.tag {
                       case 0:
                               self.selectedMode = "Automatic"
                               modeDescription(mode: self.selectedMode)
                       case 1:
                               self.selectedMode = "Interactive"
                               modeDescription(mode: self.selectedMode)
                       case 2:
                               self.selectedMode = "Manual"
                               modeDescription(mode: self.selectedMode)
                   default:
                       break
                   }
        }
        
    }
    
    func getProfileSettings() {
        let reachable = reachability?.isReachable ?? false
        if  reachable{
           refreshProfileSettings()
        } else {
          requestProfileObject()
        }
    }
    
    func getLocalProfileSettings() {
        viewModel?.getLocalUserProfileInformation(email: Utilities.instance.getLoggedEmail() ,completion: { [weak self] object in
            self?.userProfileSettings = object
        })
    }
    
    func refreshProfileSettings() {
        viewModel?.getProfileSettings(completion: { [weak self] object in
            // refresh data
            self?.userProfileSettings = object
            //self?.requestProfileObject()
        })
        
        viewModel?.alertMessage = { [weak self](title: String, message: String, tag: Int) in
            
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
    }
    
    func requestProfileObject() {
        viewModel?.getLocalUserProfileInformation(email: Utilities.instance.getLoggedEmail(), completion: { [weak self] object in
            self?.userProfileSettings = object
        })
    }
    
    func modeDescription(mode: String) {
         setButtonTabSelected(sender: [btnAutomatic ?? UIButton(), btnInteractive ?? UIButton(), btnManual ?? UIButton()])
        if mode == "Automatic" {
            lblDeskModeTitle?.text = "desk_mode.auto_title".localize()
            txtDeskModeDesc?.text = "desk_mode.auto_desc".localize()
            btnAutomatic?.isSelected = true
        }
        
        if mode == "Interactive" {
            lblDeskModeTitle?.text = "desk_mode.interactive_title".localize()
            txtDeskModeDesc?.text = "desk_mode.interactive_desc".localize()
            btnInteractive?.isSelected = true
        }
        
        if mode == "Manual" {
            lblDeskModeTitle?.text = "desk_mode.manual_title".localize()
            txtDeskModeDesc?.text = "desk_mode.manual_desc".localize()
            btnManual?.isSelected = true
        }
        
    }
    
    @IBAction func onBtnSaveDeskMode(sender: UIButton) {
        if SPDeviceConnected() {
            print("SELECTED DESK MODE: ", self.selectedMode)
            Utilities.instance.saveDefaultValueForKey(value: self.selectedMode, key: "desk_mode")
            
            let defaults = UserDefaults.standard
            defaults.set(self.selectedMode, forKey: "desk_mode")
            if defaults.synchronize() {
                setDeskModeSelected(withCommand: true, mode: self.selectedMode)
            }
            
        } 

    }
    
    func setDeskModeSelected(withCommand: Bool, mode: String) {
        //let mode  = Utilities.instance.getObjectFromUserDefaults(key: "desk_mode") as? String ?? "Manual"
        print("setDeskModeSelected",mode)
        if mode == "Automatic" {
            btnAutomatic?.isSelected = true
            selectedTag = btnAutomatic?.tag ?? 0
            let _switch_on = SPCommand.GetDeskTurnOn()
            let _semi_auto = SPCommand.GetDisableSemiAutomaticMode()
            
            if withCommand {
                
                if self.runSwitchStatus == false {
                    self.sendACommand(command: _switch_on, name: "SPCommand.GetDeskTurnOn")
                    
                    Threads.performTaskAfterDealy(1.0, {
                        self.sendACommand(command: _semi_auto, name: "SPCommand.GetDisableSemiAutomaticMode")
                    })
                    
                     self.runSwitchStatus = true
                } else {
                    self.sendACommand(command: _semi_auto, name: "SPCommand.GetDisableSemiAutomaticMode")
                }
                Utilities.instance.isMovingProgress = true
                 updateProfileSettings(interactive: false)
                 deskModeDelegate?.deskSettingsRedirectToHome()
            }
            
        }
        
        if mode == "Interactive" {
            btnInteractive?.isSelected = true
            selectedTag = btnAutomatic?.tag ?? 1
             let _switch_on = SPCommand.GetDeskTurnOn()
             let _semi_auto = SPCommand.GetEnableSemiAutomaticMode()
                        
            if withCommand {

                if self.runSwitchStatus == false {
                    self.sendACommand(command: _semi_auto, name: "SPCommand.GetEnableSemiAutomaticMode")
                    
                    Threads.performTaskAfterDealy(1.0, {
                        self.sendACommand(command: _switch_on, name: "SPCommand.GetDeskTurnOn")
                    })
                    
                    self.runSwitchStatus = true
                } else {
                    self.sendACommand(command: _semi_auto, name: "SPCommand.GetEnableSemiAutomaticMode")
                }
                Utilities.instance.isMovingProgress = true
                updateProfileSettings(interactive: true)
                deskModeDelegate?.deskSettingsRedirectToHome()
            }
        }
        
        if mode == "Manual" {
            btnManual?.isSelected = true
            selectedTag = btnAutomatic?.tag ?? 2
            if withCommand {
                
                let _command = SPCommand.GetDeskTurnOff()
                self.sendACommand(command: _command, name: "SPCommand.GetDeskTurnOff")
                self.runSwitchStatus = false
                Utilities.instance.isMovingProgress = false
                updateProfileSettings(interactive: false)
                deskModeDelegate?.deskSettingsRedirectToHome()
            }

        }
        
    }
    
    func updateProfileSettings(interactive: Bool) {
        self.userProfileSettings = SPRealmHelper().updateUserProfileSettings( ["StandingTime1":self.userProfileSettings.StandingTime1,
                                                                             "StandingTime2":self.userProfileSettings.StandingTime2,
                                                                             "ProfileSettingType":self.userProfileSettings.ProfileSettingType,
                                                                             "SittingPosition":self.userProfileSettings.SittingPosition,
                                                                             "StandingPosition":self.userProfileSettings.StandingPosition,
                                                                             "IsInteractive": interactive],
                                                                              Utilities.instance.getLoggedEmail())
            
        
        
        guard !Utilities.instance.isGuest else {
            return
        }
        
        viewModel?.requestUpdateProfileSettings(self.userProfileSettings.generateProfileParameters()) { data in
            //let result = ProfileSettings(params: data)
            //self.viewModel?.updateRecordinTable(object: result)
        }
        
    }
}
