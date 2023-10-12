//
//  SettingsController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-23.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

protocol SettingsControllerDelegate {
    func redirectToMainScreen()
}

class SettingsController: BaseController {

    //STORYBOARD OUTLETS
    
    @IBOutlet weak var content: UIView?
    @IBOutlet weak var tabMenu: UIView?
    
    @IBOutlet weak var btnDesk: UIButton?
    @IBOutlet weak var btnControls: UIButton?
    @IBOutlet weak var btnBle: UIButton?
    @IBOutlet weak var btnCredentials: UIButton?
    @IBOutlet weak var btnVersion: UIButton?
    @IBOutlet weak var btnLogout: UIButton?
    
    
    //CLASS VARIABLES
    var settingsDelegate: SettingsControllerDelegate?
    
    var tabController = UITabBarController()
    var deskMode =  DeskModeController.instantiateFromStoryboard(storyboard: "Settings") as! DeskModeController
    var sensorControls =  SPControlBoxController.instantiateFromStoryboard(storyboard: "Settings") as! SPControlBoxController
    var deviceList = DeviceListViewController.instantiateFromStoryboard(storyboard: "Settings") as! DeviceListViewController
    var userCredential =  UserCredentialsController.instantiateFromStoryboard(storyboard: "Settings") as! UserCredentialsController
    var currentAppVersion = AppVersionController.instantiateFromStoryboard(storyboard: "Settings") as! AppVersionController
    var logout = LogoutController.instantiateFromStoryboard(storyboard: "Settings") as! LogoutController
    
    
    var deskNav = UINavigationController()
    var sensorNav = UINavigationController()
    var credentialkNav = UINavigationController()
    var deviceNav = UINavigationController()
    var versionNav = UINavigationController()
    var logoutNav = UINavigationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabController.delegate = self
        customizeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cloudStatusIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        checkToggleBoxMenuSlider()
//        self.boxControl.updateSelectedTag(tag: Utilities.instance.boxControlButtonTag)
    }
    
    override func customizeUI() {
        deskNav = UINavigationController(rootViewController: deskMode)
        sensorNav = UINavigationController(rootViewController: sensorControls)
        deviceNav = UINavigationController(rootViewController: deviceList)
        credentialkNav = UINavigationController(rootViewController: userCredential)
        versionNav = UINavigationController(rootViewController: currentAppVersion)
        //logoutNav = UINavigationController(rootViewController: logout)
    
        deskMode.deskModeDelegate = self
        
        
        if Utilities.instance.IS_FREE_VERSION {

            
            btnDesk?.isHidden = true
            btnControls?.isHidden = true
            btnLogout?.isHidden = true
            
            btnCredentials?.tag = 0
            btnVersion?.tag = 1
            
            btnCredentials?.isSelected = true
            
            self.tabController.viewControllers = [credentialkNav, versionNav]
        } else {
            if Utilities.instance.isGuest {
                btnCredentials?.isHidden = true
                btnLogout?.isHidden = true
                
                btnDesk?.tag = 0
                btnControls?.tag = 1
                btnVersion?.tag = 2
                
                self.tabController.viewControllers = [deskNav, sensorNav, versionNav]
            } else {
                btnCredentials?.isHidden = false
                btnLogout?.isHidden = false
                
                btnDesk?.tag = 0
                btnControls?.tag = 1
                btnVersion?.tag = 3
                btnCredentials?.tag = 2
                btnLogout?.tag = 4
                
                self.tabController.viewControllers = [deskNav, sensorNav, credentialkNav, versionNav, logoutNav]
            }
        }
        
        
        
        
        self.tabController.selectedIndex = 0
        self.tabController.tabBar.isHidden = true
        self.tabController.view.frame = self.content?.frame ?? .zero
        self.content?.addSubview(self.tabController.view)
        
        
        
        btnDesk?.isSelected = true
        
    }

    /**
     Button actions.

    - Parameters: Button sender
    - Returns: none
     
    */
    
    @IBAction func onBtnActions(sender: UIButton) {
        setButtonTabSelected(sender: [btnDesk ?? UIButton(),
                                      btnControls ?? UIButton(),
                                      btnBle ?? UIButton(),
                                      btnCredentials ?? UIButton(),
                                      btnVersion ?? UIButton(),
                                      btnLogout ?? UIButton()])
        
        sender.isSelected = !sender.isSelected
        self.tabController.selectedIndex = sender.tag
        
        switch sender.tag {
            case 0:
            break
            case 1:
            break
            case 2:
            break
            case 3:
            break
            case 4:
            break
        default:
            break
        }
    }

}

extension SettingsController: UITabBarControllerDelegate {
    
}

extension SettingsController: DeskModeControllerDelegate {
    func deskSettingsRedirectToHome() {
        settingsDelegate?.redirectToMainScreen()
    }
    
    
}
