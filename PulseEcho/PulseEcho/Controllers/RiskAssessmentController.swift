//
//  RiskAssessmentController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-04-13.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
class RiskAssessmentController: BaseController {
    
    //STORYBOARD OUTLETS
    @IBOutlet weak var navigationView: MainTopNavigation?
    @IBOutlet weak var btnLow: UIButton?
    @IBOutlet weak var btnMedium: UIButton?
    @IBOutlet weak var btnHigh: UIButton?
    @IBOutlet weak var viewContent: UIView?
    @IBOutlet weak var btnModify: UIButton?
    @IBOutlet weak var btnActivityProfile: UIButton?
    @IBOutlet weak var btnDeskMode: UIButton?
    @IBOutlet weak var btnUserProfile: UIButton?
    @IBOutlet weak var btnSurvey: UIButton?
    @IBOutlet weak var stackViewScroll: ScrollViewStack?
    @IBOutlet weak var viewRiskContent: UIView?
    
    //CLASS VARIABLES
    weak var homeProtocol: HomeActionsProtocol?
    
    var viewModel: UserRiskManagementViewModel?
    var riskAssessment: UserRiskManagement? {
        didSet {
            updateUI()
        }
    }
    lazy var riskAssessmentContent: RiskAssessmentContentView = {
           let _riskContent: RiskAssessmentContentView = RiskAssessmentContentView.fromNib()
           return _riskContent
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let email = Utilities.instance.getUserEmail()
        createCustomNavigationBar(title: "risk_assessment.title".localize(), user: email, cloud: true, back: true, ble: true)
        customizeUI()
        updateUI()
        riskAssessmentContent.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.stackViewScroll?.flashScrollIndicators()
        
    }
    
    override func customizeUI() {
        navigationView?.delegate = self
        btnLow?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnLow?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        btnLow?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .selected)
        
        btnMedium?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnMedium?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_yellow), forState: .highlighted)
        btnMedium?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_yellow), forState: .selected)
        
        btnHigh?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnHigh?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_red), forState: .highlighted)
        btnHigh?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_red), forState: .selected)
        
        self.stackViewScroll?.showsVerticalScrollIndicator = true
        self.stackViewScroll?.indicatorStyle = .black
        
        self.stackViewScroll?.contentOffset = CGPoint(x: 0,y: 0)
        self.stackViewScroll?.insertView(view: riskAssessmentContent)
        self.view.sendSubviewToBack(self.stackViewScroll ?? UIView())
    }
    
    override func bindViewModelAndCallbacks() {
        viewModel = UserRiskManagementViewModel()

        viewModel?.alertMessage = { [weak self](title: String, message: String, tag: Int) in
            self?.displayStatusNotification(title: message, style: .danger)
        }

        viewModel?.showIndicator = { [weak self] (show: Bool) in
            self?.showActivityIndicator(show: show)
        }
    }
    
    @IBAction func onBtnActions(sender: UIButton) {
        setButtonTabSelected(sender: [btnLow ?? UIButton(), btnMedium ?? UIButton(), btnHigh ?? UIButton()])
        sender.isSelected = !sender.isSelected
        
        switch sender.tag {
            case 0:
                setContentBorder(color: Constants.smartpods_green)
                self.riskAssessmentContent.riskAssessment = riskAssessment
                
                if sender.tag == riskAssessment?.Level {
                    self.riskAssessmentContent.level = riskAssessment?.Level ?? 0
                    self.riskAssessmentContent.updateUI()
                } else {
                    self.riskAssessmentContent.setSelectedRiskAssessment(level: 0)
                }
                
            case 1:
                setContentBorder(color: Constants.smartpods_yellow)
                self.riskAssessmentContent.riskAssessment = riskAssessment
                //self.riskAssessmentContent.updateUI()
            
                if sender.tag == riskAssessment?.Level {
                    self.riskAssessmentContent.level = riskAssessment?.Level ?? 1
                    self.riskAssessmentContent.updateUI()
                } else {
                    self.riskAssessmentContent.setSelectedRiskAssessment(level: 1)
                }
            
            case 2:
                setContentBorder(color: Constants.smartpods_red)
                self.riskAssessmentContent.riskAssessment = riskAssessment
                //self.riskAssessmentContent.updateUI()
            
                if sender.tag == riskAssessment?.Level {
                    self.riskAssessmentContent.level = riskAssessment?.Level ?? 2
                    self.riskAssessmentContent.updateUI()
                } else {
                    self.riskAssessmentContent.setSelectedRiskAssessment(level: 2)
                }
            
            case 10:
                break
            case 11:
                self.homeProtocol?.goToActivityProfile()
            case 12:
                self.homeProtocol?.goToDeskMode()
            case 13:
                self.navigationController?.popToRootViewController(animated: false)
                self.homeProtocol?.goToUserProfile()
            case 14:
                self.navigationController?.popToRootViewController(animated: false)
                self.homeProtocol?.goToSurvey()
            default: break
        }
    }
    
    func setContentBorder(color: String) {
        viewContent?.borderWidth = 1.0
        viewContent?.borderColor = UIColor(hexString: color)
    }
    
    
    func updateUI() {
        
        if !isViewLoaded {
            return
        }
        
        guard riskAssessment != nil else {
            return
        }
        
        switch riskAssessment?.Level {
            case 0:
            self.onBtnActions(sender: btnLow ?? UIButton())
            case 1:
            self.onBtnActions(sender: btnMedium ?? UIButton())
            case 2:
            self.onBtnActions(sender: btnHigh ?? UIButton())
        default:
            break
        }
        
    }
}


extension RiskAssessmentController: MainTopNavigationDelegate {
    func backToPreviewsView() {
        self.navigationController?.popViewController(animated: false)
    }
    
    func backToHomeView() {
        self.navigationController?.popViewController(animated: false)
    }
}

extension RiskAssessmentController: RiskAssessmentContentViewDelegate {
    func goToActivityProfile() {
        self.homeProtocol?.goToActivityProfile()
    }
    
    func goToDeskMode() {
        self.homeProtocol?.goToDeskMode()
    }
    
    func goToUserProfile() {
        self.navigationController?.popToRootViewController(animated: false)
        self.homeProtocol?.goToUserProfile()
    }
    
    func goToSurvey() {
        self.navigationController?.popToRootViewController(animated: false)
        self.homeProtocol?.goToSurvey()
    }
    
    
}
