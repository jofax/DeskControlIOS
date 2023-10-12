//
//  TestController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-16.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import FontAwesome_swift

class TestController: BaseController {
    //STORYBOARD OUTLETS
       
       @IBOutlet weak var heartViewIndicator: AnimatedHeartView?
       @IBOutlet weak var dailyView: UIView?
       @IBOutlet weak var viewTotal: UIView?
       
       @IBOutlet weak var btnBankStars: UIButton?
       @IBOutlet weak var lblDailyTitle: UILabel?
       @IBOutlet weak var lblDaily: UILabel?
       @IBOutlet weak var lblTotalTitle: UILabel?
       @IBOutlet weak var lblTotal: UILabel?
       @IBOutlet weak var btnStars: UIButton?
       @IBOutlet weak var btnStarCounts: UIButton?
       //CLASS VARIABLES

       
       override func viewDidLoad() {
           super.viewDidLoad()
           createCustomNavigationBar(title: "welcome.title".localize(), user: "User", wifi: true, cloud: true)
           customizeUI()
           // Do any additional setup after loading the view.
       }
       
       override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           
       }
       
       override func customizeUI() {
           
           btnBankStars?.setTitle("home.bank_stars".localize(), for: .normal)
           lblDailyTitle?.text = "home.daily_title".localize()
           lblTotalTitle?.text = "home.total_title".localize()
           
           btnStars?.setImage(UIImage.fontAwesomeIcon(name: .star,
                                                     style: .solid,
                                                     textColor: UIColor(hexString: Constants.smartpods_gray),
                                                     size: CGSize(width: 50, height: 50)), for: .normal)
           
           heartViewIndicator?.progress = 0.5
           heartViewIndicator?.heartAmplitude = 20.0
           heartViewIndicator?.isShowProgressText = false
           heartViewIndicator?.isAnimated = true
           
           dailyView?.roundCorners([.layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 30)
           viewTotal?.roundCorners([.layerMinXMinYCorner, .layerMinXMaxYCorner], radius: 30)
           
           
           heartViewIndicator?.heavyHeartColor = .white
           heartViewIndicator?.lightHeartColor = .lightGray
           heartViewIndicator?.fillHeartColor = UIColor.init(hexString: Constants.smartpods_blue)
           
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showHeartStatsDetails(_:)))
           tapGesture.numberOfTapsRequired = 1
           heartViewIndicator?.addGestureRecognizer(tapGesture)
       }
       
       @objc func showHeartStatsDetails(_ sender: UITapGestureRecognizer) {
           let controller: HeartStatDetailsController = HeartStatDetailsController.instantiateFromStoryboard() as! HeartStatDetailsController
           self.navigationController?.pushViewController(controller, animated: true)
       }
}
