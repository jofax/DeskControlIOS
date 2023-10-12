//
//  HomeController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-03.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import FontAwesome_swift
import SwiftEventBus

protocol HomeControllerDelegate {
    func showDeskModeScreen()
}

protocol HomeActionsProtocol: class {
    func goToActivityProfile()
    func goToDeskMode()
    func goToUserProfile()
    func goToSurvey()
}

class HomeController: BaseController {

    //STORYBOARD OUTLETS
    
    @IBOutlet weak var btnHome: UIButton?
    @IBOutlet weak var btnProfile: UIButton?
    @IBOutlet weak var btnSurvery: UIButton!
    @IBOutlet weak var content: UIView?
    @IBOutlet weak var tabMenu: UIView?
    @IBOutlet weak var logoView: UIView?
    
    //CLASS VARIABLES
    
    var tabController = UITabBarController()
    var viewModel: HomeViewModel?
    var heartStats = HeartStatsController.instantiateFromStoryboard(storyboard: "Home") as! HeartStatsController
    var userProfile = UserProfileController.instantiateFromStoryboard(storyboard: "Home") as! UserProfileController
    var survey = SurveyController.instantiateFromStoryboard(storyboard: "Home") as! SurveyController
    var heartStatsNav = UINavigationController()
    var profileNav = UINavigationController()
    var surveyNav = UINavigationController()
    var homeDelegate: HomeControllerDelegate?
    var homeProtocol: HomeActionsProtocol?
    var mainProtocol: MainClassProtocol?
    var _data: Any?
    
    var surveryViewModel: SurveyViewModel?
    let badgeView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
    
    override func viewDidLoad() {
        super.viewDidLoad()
         // create navigation bar
        self.homeProtocol = self
        self.tabController.delegate = self
        
        customizeUI()
        self.tabController.selectedIndex = 0
        
        requestPulseData(type: .All)
        
        
//        logoView?.addShadow(to: [.bottom], radius: 5.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("guest: ", Utilities.instance.isGuest)
        cloudStatusIndicator()
        checkBLEConnectivityIndicator()
        //checkToggleBoxMenuSlider()
        surveyBadge()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        checkToggleBoxMenuSlider()
//        self.boxControl.updateSelectedTag(tag: Utilities.instance.boxControlButtonTag)
        cloudStatusIndicator()
        checkBLEConnectivityIndicator()
    }

    
    override func customizeUI() {
        heartStats.heartStatsDelegate = self
        heartStats.homeProtocol = self.homeProtocol
        
        if let _object = _data {
            if _object is User {
                let user = _object as! User
                let department = user.DepartmentID
                
                if department == 0 && !user.Email.isEmpty {
                    heartStats.hasDepartment = false
                }
            }
        }
        
        heartStatsNav = UINavigationController(rootViewController: heartStats)
        profileNav = UINavigationController(rootViewController: userProfile)
        surveyNav = UINavigationController(rootViewController: survey)
        
        
        if Utilities.instance.isGuest {
            btnProfile?.isHidden = true
            btnHome?.tag = 0
//            btnSurvery?.tag = 1
//            self.tabController.viewControllers = [heartStatsNav, surveyNav]
            btnSurvery?.tag = 1
            btnSurvery?.isHidden = true
            self.tabController.viewControllers = [heartStatsNav]
        } else {
            btnProfile?.isHidden = false
            btnHome?.tag = 0
            btnProfile?.tag = 1
            btnSurvery?.tag = 2
            self.tabController.viewControllers = [heartStatsNav, profileNav, surveyNav]
        }
        
        self.tabController.selectedIndex = 0
        self.tabController.tabBar.isHidden = true
        self.tabController.view.frame = self.content?.frame ?? .zero
        self.content?.addSubview(self.tabController.view)
        
        
        btnHome?.isSelected = true
        
        //safety enabled
        
//        let command = SPCommand.GetEnableSafetyCommand()
//        self.sendACommand(command: command, name: "SPCommand.GetEnableSafetyCommand")
        
    }
    
    override func bindViewModelAndCallbacks() {
        
        self.surveryViewModel =  SurveyViewModel(type: .isSurvey)
        
        surveryViewModel?.badgeView =  { [weak self] () in
            self?.surveyBadge()
        }
    }
    
    /**
     Button actions.

    - Parameters: Button sender
    - Returns: none
     
    */
    
    @IBAction func onBtnActions(sender: UIButton) {
        setButtonTabSelected(sender: [btnHome ?? UIButton(), btnProfile ?? UIButton(), btnSurvery ?? UIButton()])
        
        sender.isSelected = !sender.isSelected
        self.tabController.selectedIndex = sender.tag
        
        switch sender.tag {
            case 0:
                //self.addSurveyNotificationBadge(add: !(self.surveryViewModel?.hasSurvey ?? false))
                self.surveyBadge()
            case 1:
                //self.addSurveyNotificationBadge(add: !(self.surveryViewModel?.hasSurvey ?? false))
                self.surveyBadge()
            case 2:
                self.addSurveyNotificationBadge(add: false)
            break
        default:
            break
        }
    }
    
    func setSelectedTabMenu(index: Int) {
        setButtonTabSelected(sender: [btnHome ?? UIButton(), btnProfile ?? UIButton(), btnSurvery ?? UIButton()])
        //btnHome?.isSelected = true
        switch index {
        case 0:
            btnHome?.isSelected = true
            self.heartStats.refreshHeartProgress()
        case 1:
            btnProfile?.isSelected = true
        case 2:
            btnSurvery?.isSelected = true
        default:break
        }
    }
    
    func homeSelectedView(index: Int, object: Any?) {
        self.tabController.selectedIndex = index
        self.setSelectedTabMenu(index: index)
        
        if index == 0 {
            self.heartStats.refreshHeartProgress()
        }
        
        if index == 2 {
            self.survey._data = object
        }
    }
    
    func surveyBadge() {
        
//        guard Utilities.instance.newSurveyAvailable else {
//            return
//        }

        guard (Utilities.instance.typeOfUserLogged() != .None || Utilities.instance.typeOfUserLogged() != .Guest) else {
            return
        }
        
        self.app_delegate.getSurvey { (response) in
            print("selected tab index: ", self.tabController.selectedIndex)
             if response is Survey {
                if self.surveryViewModel?.hasSurvey != nil && self.tabController.selectedIndex != 2 {
                    self.addSurveyNotificationBadge(add: true)
                } else {
                    self.addSurveyNotificationBadge(add: false)
                }
            }
        }
        
    }
    
    func addSurveyNotificationBadge(add: Bool) {
        var badgeAppearance = BadgeAppearance()
        badgeAppearance.backgroundColor = UIColor.red //default is red
        badgeAppearance.textColor = UIColor.white // default is white
        badgeAppearance.textAlignment = .center //default is center
        badgeAppearance.distanceFromCenterX = (self.btnSurvery?.boundsCenter.x ?? 0) + 10 // 15 //default is 0
        badgeAppearance.distanceFromCenterY = 3 // -10 //default is 0
        badgeAppearance.allowShadow = false
        badgeAppearance.borderColor = .clear
        badgeAppearance.borderWidth = 0
        
        self.badgeView.tag = Constants.surveyBadgeTag
        self.badgeView.badge(text: "", appearance: badgeAppearance)
        
        if add {
            var allViews = [UIView]()
            for view in self.btnSurvery.subviews {
                if view.tag == Constants.surveyBadgeTag {
                    allViews.append(view)
                    break
                }
            }
            
            if allViews.count == 0 {
                self.btnSurvery?.addSubview(self.badgeView)
            }
            
        } else {
            for view in self.btnSurvery.subviews {
                if view.tag == Constants.surveyBadgeTag {
                    view.removeFromSuperview()
                    break
                }
            }
        }
        
    }
}

extension HomeController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("viewController selected: ", viewController)
        
        if tabController.selectedIndex == 0 {
            
        }
    }

}

/**
 Heart stats delegate methods.
*/

extension HomeController: HeartStatsControllerDelegate {
    func redirectToDeskModeChange() {
        homeDelegate?.showDeskModeScreen()
    }
}

extension HomeController: HomeActionsProtocol {
    func goToActivityProfile() {
        self.mainProtocol?.parentNavigateChildView(parent: 1, child:1, object: nil)
    }
    
    
    func goToDeskMode() {
        self.mainProtocol?.parentNavigateChildView(parent: 3, child:0, object: nil)
    }
    
    func goToUserProfile() {
        self.mainProtocol?.parentNavigateChildView(parent: 0, child:1, object: nil)
    }
    
    func goToSurvey() {
        self.mainProtocol?.parentNavigateChildView(parent: 0, child:2, object: nil)
    }
}
