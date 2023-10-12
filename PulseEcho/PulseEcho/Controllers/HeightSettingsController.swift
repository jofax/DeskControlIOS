//
//  HeightSettingsController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-22.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

protocol HeightSettingsControllerDelegate {
    func redirectToMainScreen()
}

class HeightSettingsController: BaseController {

    //STORYBOARD OUTLETS
    
    @IBOutlet weak var content: UIView?
    @IBOutlet weak var tabMenu: UIView?
    @IBOutlet weak var btnHeightSettings: UIButton?
    @IBOutlet weak var btnActivityProfile: UIButton?
    
    //CLASS VARIABLES
    var heightSettingsDelegate: HeightSettingsControllerDelegate?
    var tabController = UITabBarController()
    var deskHeight = DeskController.instantiateFromStoryboard(storyboard: "Desk") as! DeskController
    var activityProfile = ActivityProfileController.instantiateFromStoryboard(storyboard: "Desk") as! ActivityProfileController
    var deskHeightNav = UINavigationController()
    var activityProfileNav = UINavigationController()
    
    var mainProtocol: MainClassProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPBluetoothManager.shared.event = self.event
        SPBluetoothManager.shared.delegate = self
        self.tabController.delegate = self
        customizeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cloudStatusIndicator()
        //checkToggleBoxMenuSlider()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //checkToggleBoxMenuSlider()
        //self.boxControl.updateSelectedTag(tag: Utilities.instance.boxControlButtonTag)
    }
    
    override func customizeUI() {
        
        deskHeightNav = UINavigationController(rootViewController: deskHeight)
        activityProfileNav = UINavigationController(rootViewController: activityProfile)
        
        
        activityProfile.activityProfileDelegate = self
        
        self.tabController.viewControllers = [deskHeightNav, activityProfileNav]
        self.tabController.selectedIndex = 0
        self.tabController.tabBar.isHidden = true
        self.tabController.view.frame = self.content?.frame ?? .zero
        self.content?.addSubview(self.tabController.view)
        
        btnHeightSettings?.isSelected = true
        
    }
  
    /**
     Button actions.

    - Parameters: Button sender
    - Returns: none
     
    */
    
    @IBAction func onBtnActions(sender: UIButton) {
        setButtonTabSelected(sender: [btnHeightSettings ?? UIButton(), btnActivityProfile ?? UIButton()])
        sender.isSelected = !sender.isSelected
        self.tabController.selectedIndex = sender.tag
        
        switch sender.tag {
            case 0:
            break
            case 1:
            break
            case 2:
            break
        default:
            break
        }
    }
    
//    func setSelectedTabMenu(index: Int) {
//        setButtonTabSelected(sender: [btnHeightSettings ?? UIButton(), btnActivityProfile ?? UIButton()])
//        btnHome?.isSelected = true
//    }
}

extension HeightSettingsController: UITabBarControllerDelegate {
    
}

extension HeightSettingsController: ActivityProfileControllerDelegate {
    func activityProfileRedirectToHome() {
        //self.requestPulseData(type: .Profile)
        heightSettingsDelegate?.redirectToMainScreen()
    }
    
    
}

extension HeightSettingsController: SPBluetoothManagerDelegate {
    
    func updateInterface() {
        print("HeartStatsController : updateInterface")
    }
    
    func updateDeviceConnectivity(connect: Bool) {

    }
    
    func unableToPairWithBox() {
        
    }
    
    func connectivityState(title: String, message: String, code: Int) {
        self.showAlert(title: title, message: message)
    }
    
    func deviceConnected() {
        if let peripheral = SPBluetoothManager.shared.state.peripheral {
            if LOGS.BUILDTYPE.boolValue == false {
                print("device connected peripheral: \(peripheral.state) | info: \(Utilities.instance.loginfo())")
            } else {
                print("device connected peripheral: \(peripheral.state) | info: \(Utilities.instance.loginfo())")
            }
            if peripheral.state == .connected {
                deskHeight.getProfileSettings()
            }
        } else {
            if LOGS.BUILDTYPE.boolValue == false {
                print("INVALID PERIPHERAL | info: \(Utilities.instance.loginfo())")
            } else {
                print("INVALID PERIPHERAL | info: \(Utilities.instance.loginfo())")
            }
        }
    }

}
