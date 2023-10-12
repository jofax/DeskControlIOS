//
//  ForgotPasswordController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-10.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Material

class ForgotPasswordController: BaseController {
    
    //STORYBOARD OUTLETS
    
    @IBOutlet weak var lblEmailTitle: UILabel?
    @IBOutlet weak var lblForgotTitle: UILabel?
    @IBOutlet weak var txtEmail: TextField?
    @IBOutlet weak var btnSubmit: UIButton?
    @IBOutlet weak var btnBack: UIButton?
    
    //CLASS VARIABLES
    
    var viewModel: ForgotPasswordViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCustomNavigationBar(title: "welcome.forgot".localize(), user: "", cloud: false, back: false, ble: false)
        customizeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }

    override func customizeUI() {
        
        lblEmailTitle?.text = "forgot.email_content".localize()
        lblForgotTitle?.text = "forgot.forgot_title".localize()
        txtEmail?.placeholder = "welcome.email".localize()
        btnSubmit?.setTitle("welcome.submit".localize(), for: .normal)
        btnBack?.setTitle("common.cancel".localize(), for: .normal)
        
        btnSubmit?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnSubmit?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        
        btnBack?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnBack?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        
        lblEmailTitle?.adjustContentFontSize()
        lblForgotTitle?.adjustContentFontSize()
        btnSubmit?.titleLabel?.adjustContentFontSize()
        btnBack?.titleLabel?.adjustContentFontSize()
        
        txtEmail?.adjustContentFontSize()
        
    }
    
    override func bindViewModelAndCallbacks() {
        self.viewModel = ForgotPasswordViewModel()
        
        viewModel?.alertMessage = { [weak self](title: String, message: String, tag: Int) in
            self?.displayStatusNotification(title: message, style: .danger)
        }

        viewModel?.enableState = { [weak self] (enable: Bool) in
            self?.btnSubmit?.isEnabled = enable
        }
        
        viewModel?.showIndicator = { [weak self] (show: Bool) in
            self?.showActivityIndicator(show: show)
            
        }
        
        viewModel?.successResponse = {[weak self] (object: Any) in
            self?.displayNotificationMessage(title: "success.title".localize(), subTitle: "forgot.success_request_pincode".localize(), style: .success)
            Threads.performTaskAfterDealy( 1, {
                let _email = self?.txtEmail?.text ?? ""
                let controller = ResetPasswordController.instantiateFromStoryboard(storyboard: "Login") as! ResetPasswordController
                controller.email = _email
                self?.navigationController?.pushViewController(controller, animated: true)
            })
        }
    }

    /**
     Button actions.
     
    - Parameters: Button sender
    - Returns: none
     
    */
    
    @IBAction func onBtnActions(sender: UIButton) {
        
        textFieldDismissKeyboard(sender: txtEmail ?? UITextField())
        
        switch sender.tag {
        case 0:
            let _email = txtEmail?.text ?? ""
            viewModel?.initializePinCodeRequest(username: _email)
            
            break
        case 1:
            self.navigationController?.popToRootViewController(animated: true)
            break
        default:
            break
        }
    }
}
