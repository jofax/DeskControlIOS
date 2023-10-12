//
//  StatisticsController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-23.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class StatisticsController: BaseController {

    //STORYBOARD OUTLETS
    
    @IBOutlet weak var content: UIView?
    @IBOutlet weak var tabMenu: UIView?
    @IBOutlet weak var btnDeskStats: UIButton?
    @IBOutlet weak var btnInjuryMap: UIButton?
    @IBOutlet weak var btnUserStats: UIButton?
    
    //CLASS VARIABLES
    var tabController = UITabBarController()
    var deskStats =  UserDeskStatisticsController.instantiateFromStoryboard(storyboard: "Statistics") as! UserDeskStatisticsController
    
    var deskStatsNav = UINavigationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
//        checkToggleBoxMenuSlider()
//        self.boxControl.updateSelectedTag(tag: Utilities.instance.boxControlButtonTag)
    }

    override func customizeUI() {
        deskStatsNav = UINavigationController(rootViewController: deskStats)
        
        self.tabController.viewControllers = [deskStatsNav]
        self.tabController.selectedIndex = 0
        self.tabController.tabBar.isHidden = true
        self.tabController.view.frame = self.content?.frame ?? .zero
        self.content?.addSubview(self.tabController.view)
        
        
        
        btnDeskStats?.isSelected = true
    }
    
      /**
       Button actions.

      - Parameters: Button sender
      - Returns: none
       
      */
      
      @IBAction func onBtnActions(sender: UIButton) {
          setButtonTabSelected(sender: [btnDeskStats ?? UIButton(),
                                        btnInjuryMap ?? UIButton(),
                                        btnUserStats ?? UIButton()])
          sender.isSelected = !sender.isSelected
          self.tabController.selectedIndex = sender.tag
          
          switch sender.tag {
              case 1:
              break
              case 2:
              break
              case 3:
              break
          default:
              break
          }
      }

}

extension StatisticsController: UITabBarControllerDelegate {
    
}
