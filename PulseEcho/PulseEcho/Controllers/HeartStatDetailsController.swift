//
//  HeartStatisticsController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-15.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import PopupDialog

class HeartStatDetailsController: BaseController {

    //STORYBOARD OUTLETS
    @IBOutlet weak var viewNavigation: MainTopNavigation?
    @IBOutlet weak var lblHeartTitle: UILabel?
    @IBOutlet weak var btnLeftHeart: UIButton?
    @IBOutlet weak var btnRightHeart: UIButton?
    @IBOutlet weak var heartSummary: UILabel?
    @IBOutlet weak var lblPeak: UILabel?
    
    @IBOutlet weak var btnMedium: UIButton?
    @IBOutlet weak var lblRiskManagement: UILabel?
    @IBOutlet weak var btnProgressValue: UIButton?
    @IBOutlet weak var lblMonthly: UILabel?
    @IBOutlet weak var lblPeakValue: UILabel?
    @IBOutlet weak var lblAverageValue: UILabel?
    @IBOutlet weak var lblAverage: UILabel?
    
    @IBOutlet weak var lblLeftHeartValue: UILabel?
    @IBOutlet weak var lblRightHeartValue: UILabel?
    @IBOutlet weak var lblProgressValue: UILabel?
    
    //CLASS VARIABLES
    var viewModel: UserViewModel?
    var riskAssessmentViewModel: UserRiskManagementViewModel?
    var riskManagementLevel: Int = -1
    var riskAssessment: UserRiskManagement?
    weak var homeProtocol: HomeActionsProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let email = Utilities.instance.getUserEmail()
        createCustomNavigationBar(title: "welcome.title".localize(), user: email, cloud: true, back: true, ble: true)
        customizeUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUser()
        getRiskAssessment()
    }
    
    override func customizeUI() {
        viewModel = UserViewModel()
        riskAssessmentViewModel = UserRiskManagementViewModel()
        viewNavigation?.delegate = self
        lblHeartTitle?.text = "statistics.heart_accumulation".localize()
        lblHeartTitle?.adjustContentFontSize()
        btnMedium?.titleLabel?.adjustContentFontSize()
        heartSummary?.adjustContentFontSize()
        lblPeak?.adjustContentFontSize()
        lblRiskManagement?.adjustContentFontSize()
        btnProgressValue?.titleLabel?.adjustContentFontSize()
        lblProgressValue?.adjustContentFontSize()
        lblMonthly?.adjustContentFontSize()
        lblPeakValue?.adjustNumberFontSize()
        lblAverageValue?.adjustNumberFontSize()
        lblAverage?.adjustContentFontSize()
        lblLeftHeartValue?.adjustNumberFontSize()
        lblRightHeartValue?.adjustNumberFontSize()
        
        self.btnMedium?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_gray), forState: .normal)
       
    }
    
    func getRiskAssessment() {
        guard !Utilities.instance.isGuest else {
            return
        }
        
        btnMedium?.isEnabled = false
        
        let reachable = reachability?.isReachable ?? false
        if  reachable{
           requestClientUserRiskAssessment()
        }
    }
    
    func getUser() {
        
        guard !Utilities.instance.isGuest else {
            return
        }
        
        let reachable = reachability?.isReachable ?? false
        if  reachable{
           refreshProfile()
        } else {
          requestUserObject()
        }
    }
    
    func refreshProfile() {
        viewModel?.getUserInformation(completion: { [weak self] object in
           //update box
            // refresh data
            if object is User {
                self?.requestUserObject()
            }
        })
    }
    
    func requestUserObject() {
        viewModel?.getLocalUserInformation(completion: { [weak self] object in
            self?.lblRightHeartValue?.text = String(format: "%.0f", object.HeartsTotal)
            self?.lblLeftHeartValue?.text = String(format: "%.0f", object.HeartsToday)
            
            let average = object.AvgHoursFillHeart
            
            let hours = average.whole
            let minutes = average.fraction
            
            if average == 0.0 {
                 self?.lblAverageValue?.text = String(format: "%d hour", Int(hours))
            } else {
                 self?.lblAverageValue?.text = String(format: "%d hours and %d mins", Int(hours), Int(minutes * 10))
            }
        })
    }
    
    func requestClientUserRiskAssessment() {
        
        riskAssessmentViewModel?.alertMessage = { [weak self](title: String, message: String, tag: Int) in
             self?.displayStatusNotification(title: message, style: .danger)
         }

         riskAssessmentViewModel?.showIndicator = { [weak self] (show: Bool) in
             self?.showActivityIndicator(show: show)
         }
        
        riskAssessmentViewModel?.requestUserRiskAssessment({ [weak self] object in
            self?.btnMedium?.isEnabled = true
            self?.riskAssessment = object
            self?.riskManagementLevel = object.Level
            let _progress = String(format: "%.0f", abs(object.Progress))
            self?.lblProgressValue?.text = String(format: "%@ %%", _progress)
            
            let level = object.Level
            
            switch  level{
            case 0:
                self?.btnMedium?.setTitle("Low", for: .normal)
                self?.btnMedium?.setTitle("Low", for: .normal)
                self?.btnMedium?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .normal)
                self?.btnMedium?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
            case 1:
                self?.btnMedium?.titleLabel?.text = "Medium"
                self?.btnMedium?.setTitle("Medium", for: .normal)
                self?.btnMedium?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_yellow), forState: .normal)
                self?.btnMedium?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_yellow), forState: .highlighted)
            case 2:
                self?.btnMedium?.titleLabel?.text = "High"
                self?.btnMedium?.setTitle("High", for: .normal)
                self?.btnMedium?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_red), forState: .normal)
                self?.btnMedium?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_red), forState: .highlighted)
            default:
                break
            }
            
        })
    }
    
    override func bindViewModelAndCallbacks() {
        viewModel?.alertMessage = { [weak self](title: String, message: String, tag: Int) in
            self?.displayStatusNotification(title: message, style: .danger)
        }

        viewModel?.showIndicator = { [weak self] (show: Bool) in
            self?.showActivityIndicator(show: show)
        }
    }
    
    @IBAction func onBtnAction(sender: UIButton) {
        let controller = RiskAssessmentController.instantiateFromStoryboard(storyboard: "Home") as! RiskAssessmentController
        controller.riskAssessment = self.riskAssessment
        controller.homeProtocol = self.homeProtocol
        //controller.modalPresentationStyle = .fullScreen
        //present(controller, animated: true, completion: nil)
        self.navigationController?.pushViewController(controller, animated: false)
        
    }
}

extension HeartStatDetailsController: MainTopNavigationDelegate {
    func backToPreviewsView() {
        self.navigationController?.popViewController(animated: false)
    }
    
    func backToHomeView() {
        self.navigationController?.popViewController(animated: false)
    }
}

extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
    formatter.unitsStyle = style
    guard let formattedString = formatter.string(from: self) else { return "" }
    return formattedString
  }
}

extension FloatingPoint {
    var whole: Self { modf(self).0 }
    var fraction: Self { modf(self).1 }
}
