//
//  MainController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-22.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import FontAwesome_swift
import RealmSwift

protocol MainClassProtocol: class {
    func parentNavigateChildView(parent: Int, child: Int, object: Any?)
}

class MainController: BaseController {
    //STORYBOARD OUTLETS
    @IBOutlet weak var content: UIView?
    
    //CLASS VARIABLES
    var tabController = UITabBarController()
    var userViewModel: UserViewModel?
    var profileSettingsViewModel: ProfileSettingsViewModel?
    let baseViewModel = BaseViewModel()
    
    var home = HomeController.instantiateFromStoryboard(storyboard: "Home") as! HomeController
    var heightSettings = HeightSettingsController.instantiateFromStoryboard(storyboard:"Desk") as! HeightSettingsController
    var challenges = DailyChallengesController.instantiateFromStoryboard(storyboard: "Challenges") as! DailyChallengesController
    var statistics = StatisticsController.instantiateFromStoryboard(storyboard:"Statistics") as! StatisticsController
    var settings = SettingsController.instantiateFromStoryboard(storyboard: "Settings") as! SettingsController

    var homeNav = UINavigationController()
    var heightSettingsNav = UINavigationController()
    var challengesNav = UINavigationController()
    var statisticsNav = UINavigationController()
    var settingsNav = UINavigationController()
    
    var controllers: [UINavigationController] = [UINavigationController]()
    weak var mainProtocol: MainClassProtocol?
    var data: Any?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //SPBluetoothManager.shared.event = self.event
        self.mainProtocol = self
         // create navigation bar
        customizeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        creatNavigationHeader()
        //log.debug("REALM CONFIGURATION DB FILE: \(Realm.Configuration.defaultConfiguration.fileURL)")
        print("VALID SESSION: \(Utilities.instance.isValidSessionToken())")
    }
    
    override func customizeUI() {
        
        var icons = [UIImage]()
        icons.append(UIImage(named: "home") ?? UIImage())
        icons.append(UIImage(named: "height_settings") ?? UIImage())
        icons.append(UIImage(named: "statistics") ?? UIImage())
        icons.append(UIImage(named: "challenges") ?? UIImage())
        icons.append(UIImage(named: "settings") ?? UIImage())
        
        
        var sIcons = [UIImage]()
        sIcons.append(UIImage(named: "home_click") ?? UIImage())
        sIcons.append(UIImage(named: "height_settings_click") ?? UIImage())
        sIcons.append(UIImage(named: "statistics_click") ?? UIImage())
        sIcons.append(UIImage(named: "challenges_click") ?? UIImage())
        sIcons.append(UIImage(named: "settings_click") ?? UIImage())
        
        home.tabBarItem = UITabBarItem(title: "", image: icons[0], selectedImage: sIcons[0])
        heightSettings.tabBarItem = UITabBarItem(title: "", image: icons[1], selectedImage: sIcons[1])
        statistics.tabBarItem = UITabBarItem(title: "", image: icons[2], selectedImage: sIcons[2])
        challenges.tabBarItem = UITabBarItem(title: "", image: icons[3], selectedImage: sIcons[3])
        settings.tabBarItem = UITabBarItem(title: "", image: icons[4], selectedImage: sIcons[4])
        
        home.mainProtocol = self.mainProtocol
        heightSettings.mainProtocol = self.mainProtocol
        
        self.baseViewModel.apiCallback = { [weak self] (_ response : Any, _ status: Int) in
            if status == 6 {
                self?.showAlertWithAction(title: "generic.notice".localize(),
                                          message: "generic.invalid_session".localize(),
                                          buttonTitle: "common.ok".localize(), buttonAction: {
                                            self?.logoutUser(useGuest: false)
                                          })
            }
        }
        
        if let _data = data {
           home._data = _data
        }
        
        
        homeNav = UINavigationController(rootViewController: home)
        heightSettingsNav = UINavigationController(rootViewController: heightSettings)
        challengesNav = UINavigationController(rootViewController: challenges)
        statisticsNav = UINavigationController(rootViewController: statistics)
        settingsNav = UINavigationController(rootViewController: settings)
        
        homeNav.isNavigationBarHidden = true
        heightSettingsNav.isNavigationBarHidden = true
        challengesNav.isNavigationBarHidden = true
        statisticsNav.isNavigationBarHidden = true
        settingsNav.isNavigationBarHidden = true
        
        settings.settingsDelegate = self
        home.homeDelegate = self
        heightSettings.heightSettingsDelegate = self
        
         
        if Utilities.instance.IS_FREE_VERSION {
            homeNav.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width / 3.5, bottom: 0, right: 0)
            settingsNav.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width / 3.5)
            self.tabController.viewControllers = [homeNav, settingsNav]
        } else {
            if Utilities.instance.isGuest {
               self.tabController.viewControllers = [homeNav, heightSettingsNav,settingsNav]
            } else {
               self.tabController.viewControllers = [homeNav, heightSettingsNav,statisticsNav,settingsNav]
            }
        }
        
        self.tabController.selectedIndex = 0
        
        self.tabController.delegate = self
        self.tabController.tabBar.isHidden = false
        self.tabController.view.frame = self.content?.frame ?? .zero
        self.content?.addSubview(self.tabController.view)
        
        self.tabController.tabBar.itemPositioning = .centered
        
        if #available(iOS 13.0, *) {
            let appearance = self.tabController.tabBar.standardAppearance.copy()
            appearance.configureWithTransparentBackground()
            self.tabController.tabBar.standardAppearance = appearance
        } else {
            self.tabController.tabBar.backgroundColor = UIColor.white
            self.tabController.tabBar.layer.borderColor = UIColor.white.cgColor
            UITabBar.appearance().shadowImage = UIImage()
            UITabBar.appearance().backgroundColor = .white
            
            self.tabController.tabBar.clipsToBounds = false
        }
        
//        if #available(iOS 13.0, *) {
//           LocationService.shared.startUpdatingLocation()
//       } else {
//           self.app_delegate.allowLocationService()
//           self.app_delegate.allowLocalAndPushNotification()
//           LocationService.shared.startUpdatingLocation()
//       }
    }
    
    override func bindViewModelAndCallbacks() {
        self.userViewModel = UserViewModel()
        
        
    }
    
//    @IBAction override func onBtnShowControlMenu(sender: UIButton) {
//       //showBoxControl(show: true)
//    }
    
    func creatNavigationHeader() {
        //userViewModel?.checkDatabaseTable()
        //profileSettingsViewModel?.checkDatabaseTable()
        
        guard Utilities.instance.typeOfUserLogged() != .None else {
            return
        }
        
        let email = Utilities.instance.getLoggedEmail()
        createCustomNavigationBar(title: "welcome.title".localize(), user: email, cloud: true, back: false, ble: true)
    }
    
    func requestProfileData() {
         //if (SPBluetoothManager.shared.state.peripheral?.state != nil) || (SPBluetoothManager.shared.state.peripheral?.state == .connected){
            
            if let peripheral = SPBluetoothManager.shared.state.peripheral {
                if peripheral.state == .connected {
                    self.requestPulseData(type: .All)
                }
 
        }
    }
    
}

extension MainController: UITabBarControllerDelegate, UITabBarDelegate {
    // UITabBarDelegate
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("Selected item")
    }

    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("main tab bar Selected item : ", tabBarController.selectedIndex == 0)
        
        if tabBarController.selectedIndex == 0 {
            //requestProfileData()
        }
    }
}

extension MainController: HomeControllerDelegate {
    func showDeskModeScreen() {
        
        if Utilities.instance.isGuest {
            self.tabController.selectedIndex = 2
            settings.tabController.selectedIndex = 0
        } else {
            self.tabController.selectedIndex = 3
            settings.tabController.selectedIndex = 0
        }

    }
    
    
}

extension MainController: SettingsControllerDelegate, HeightSettingsControllerDelegate {
    func redirectToMainScreen() {
        //self.requestPulseData(type: .Profile)
        self.tabController.selectedIndex = 0
        self.home.tabController.selectedIndex = 0
        self.home.setSelectedTabMenu(index: 0)
    }
}

extension MainController: MainClassProtocol {
    func parentNavigateChildView(parent: Int, child: Int, object: Any?) {
        self.tabController.selectedIndex = parent
        switch parent {
        case 0:
            self.home.homeSelectedView(index: child, object: object)
        case 1:
            Threads.performTaskAfterDealy(0.5) {
                //self.heightSettings.tabController.selectedIndex = child
                self.heightSettings.onBtnActions(sender: self.heightSettings.btnActivityProfile ?? UIButton())
            }
        case 2:
            self.statistics.tabController.selectedIndex = child
        case 3:
            self.settings.tabController.selectedIndex = child
        default:
            break
        }
    }
}

//extension MainController: DrawerMenuControllerDelegate {
//    func contactSupport() {
//        self.navigationDrawerController?.closeRightView()
//    }
//}

