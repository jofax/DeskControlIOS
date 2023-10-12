//
//  RiskAssessmentContentView.swift
//  PulseEcho
//
//  Created by Joseph on 2020-04-15.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import FontAwesome_swift

protocol RiskAssessmentContentViewDelegate: class {
    func goToActivityProfile()
    func goToDeskMode()
    func goToUserProfile()
    func goToSurvey()
}

class RiskAssessmentContentView: UIView {

    @IBOutlet weak var txtContent: UITextView?
    @IBOutlet weak var lblRecommendation: UILabel?
    @IBOutlet weak var lblStatus: UILabel?
    @IBOutlet weak var lblActivity: UILabel?
    @IBOutlet weak var lblActivityContent: UILabel?
    @IBOutlet weak var btnActivity: UIButton?
    @IBOutlet weak var lblDeskMode: UILabel?
    @IBOutlet weak var lblDeskModeContent: UILabel?
    @IBOutlet weak var btnDeskMode: UIButton?
    @IBOutlet weak var lblUserProfile: UILabel?
    @IBOutlet weak var lblUserProfileContent: UILabel?
    @IBOutlet weak var btnUserProfile: UIButton?
    @IBOutlet weak var lblSurvey: UILabel?
    @IBOutlet weak var lblSurveyContent: UILabel?
    @IBOutlet weak var btnSurvey: UIButton?
    
    @IBOutlet weak var btnActivityAction: UIButton?
    @IBOutlet weak var btnDeskModeAction: UIButton?
    @IBOutlet weak var btnUserProfileAction: UIButton?
    @IBOutlet weak var btnSurveyAction: UIButton?
    
    var delegate: RiskAssessmentContentViewDelegate?
    
    var riskAssessment: UserRiskManagement? {
        didSet {
            updateUI()
        }
    }
    
    var level: Int = 0
    
    /**
     Static variable nib for identifying the view
     - Returns: Nib file
     */
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    /**
     Static variable string for the view identifier
     - Returns: String filename
     */
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        txtContent?.textContainerInset = UIEdgeInsets.zero
        txtContent?.textContainer.lineFragmentPadding = 0
        
        txtContent?.adjustContentFontSize()
        lblRecommendation?.adjustContentFontSize()
        lblStatus?.adjustContentFontSize()
        lblActivity?.adjustContentFontSize()
        lblActivityContent?.adjustContentFontSize()
        btnActivity?.titleLabel?.adjustContentFontSize()
        lblDeskMode?.adjustContentFontSize()
        lblDeskModeContent?.adjustContentFontSize()
        btnDeskMode?.titleLabel?.adjustContentFontSize()
        lblUserProfile?.adjustContentFontSize()
        lblUserProfileContent?.adjustContentFontSize()
        btnUserProfile?.titleLabel?.adjustContentFontSize()
        lblSurvey?.adjustContentFontSize()
        lblSurveyContent?.adjustContentFontSize()
        btnSurvey?.titleLabel?.adjustContentFontSize()
        
        //lblActivity?.fitTextToBounds()
        
    }

    func updateUI() {
        guard riskAssessment != nil else {
            return
        }
        self.setSelectedRiskAssessment(level: riskAssessment?.Level ?? 0)
    }
    
    @IBAction func onBtnActions(sender: UIButton) {
        Utilities.instance.setButtonStateSelected(sender: [self.btnSurveyAction ?? UIButton(), self.btnDeskModeAction ?? UIButton(), self.btnUserProfileAction ?? UIButton(), self.btnSurveyAction ?? UIButton()])
        //sender.isSelected = !sender.isSelected
        
        switch sender.tag {
            case 11:
                delegate?.goToActivityProfile()
            case 12:
                delegate?.goToDeskMode()
            case 13:
                delegate?.goToUserProfile()
            case 14:
                delegate?.goToSurvey()
            default: break
        }
    }
    
    func setSelectedRiskAssessment(level: Int) {
        switch level {
            case 0:
                txtContent?.text = "Congratulations! \n You have been classified with a LOW health risk score. This is in part due to amount of movement that you are successfully completing on a daily basis at your desk. Keep up the great work and continue to move regularly throughout the day."
                lblActivityContent?.text = "15-30 min of standing/h"
                lblDeskModeContent?.text = " Automatic or Interactive"
                lblUserProfileContent?.text = "Height, weight and age"
                lblSurveyContent?.text = "Health surveys"
                btnActivity?.setImage(UIImage.fontAwesomeIcon(name: .check,
                                                              style: .solid,
                                                              textColor: UIColor(hexString: Constants.smartpods_blue),
                                                              size: CGSize(width: 30, height: 30)), for: .normal)
                btnDeskMode?.setImage(UIImage.fontAwesomeIcon(name: .check,
                                                              style: .solid,
                                                              textColor: UIColor(hexString: Constants.smartpods_blue),
                                                              size: CGSize(width: 30, height: 30)), for: .normal)
                btnUserProfile?.setImage(UIImage.fontAwesomeIcon(name: .check,
                                                              style: .solid,
                                                              textColor: UIColor(hexString: Constants.smartpods_blue),
                                                              size: CGSize(width: 30, height: 30)), for: .normal)
                btnSurvey?.setImage(UIImage.fontAwesomeIcon(name: .minus,
                                                              style: .solid,
                                                              textColor: UIColor(hexString: Constants.smartpods_gray),
                                                              size: CGSize(width: 30, height: 30)), for: .normal)
            case 1:
                txtContent?.text = "You are showing EARLY indicators associated to a MEDIUM health score. \n This could be due to a few reasons such as: \n your BMI, Health survey score or daily desk movements."
                lblActivityContent?.text = "15-30 min of standing/h"
                lblDeskModeContent?.text = " Automatic or Interactive"
                lblUserProfileContent?.text = "Height, weight and age"
                lblSurveyContent?.text = "Health surveys"
            
                btnActivity?.setImage(UIImage.fontAwesomeIcon(name: .minus,
                                                              style: .solid,
                                                              textColor: UIColor(hexString: Constants.smartpods_gray),
                                                              size: CGSize(width: 30, height: 30)), for: .normal)
                btnDeskMode?.setImage(UIImage.fontAwesomeIcon(name: .minus,
                                                              style: .solid,
                                                              textColor: UIColor(hexString: Constants.smartpods_gray),
                                                              size: CGSize(width: 30, height: 30)), for: .normal)
                btnUserProfile?.setImage(UIImage.fontAwesomeIcon(name: .minus,
                                                              style: .solid,
                                                              textColor: UIColor(hexString: Constants.smartpods_gray),
                                                              size: CGSize(width: 30, height: 30)), for: .normal)
                btnSurvey?.setImage(UIImage.fontAwesomeIcon(name: .minus,
                                                              style: .solid,
                                                              textColor: UIColor(hexString: Constants.smartpods_gray),
                                                              size: CGSize(width: 30, height: 30)), for: .normal)
            case 2:
                txtContent?.text = "You are showing SEVERAL indicators associated to a HIGH health score. \n This could be due to a several reasons such as: \n your BMI, Health survey score or daily desk movements."
                lblActivityContent?.text = "10-20 min of standing/h"
                lblDeskModeContent?.text = " Automatic or Interactive"
                lblUserProfileContent?.text = "Height, weight and age"
                lblSurveyContent?.text = "Health surveys"
            
                btnActivity?.setImage(UIImage.fontAwesomeIcon(name: .minus,
                                                              style: .solid,
                                                              textColor: UIColor(hexString: Constants.smartpods_gray),
                                                              size: CGSize(width: 30, height: 30)), for: .normal)
                btnDeskMode?.setImage(UIImage.fontAwesomeIcon(name: .minus,
                                                              style: .solid,
                                                              textColor: UIColor(hexString: Constants.smartpods_gray),
                                                              size: CGSize(width: 30, height: 30)), for: .normal)
                btnUserProfile?.setImage(UIImage.fontAwesomeIcon(name: .minus,
                                                              style: .solid,
                                                              textColor: UIColor(hexString: Constants.smartpods_gray),
                                                              size: CGSize(width: 30, height: 30)), for: .normal)
                btnSurvey?.setImage(UIImage.fontAwesomeIcon(name: .minus,
                                                              style: .solid,
                                                              textColor: UIColor(hexString: Constants.smartpods_gray),
                                                              size: CGSize(width: 30, height: 30)), for: .normal)
        default:
            break
        }
    }
}
