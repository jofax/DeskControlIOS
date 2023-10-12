//
//  UserCredentialsController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-26.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Material

class UserCredentialsController: BaseController {
    
    //STORYBOARD OUTLETS
    @IBOutlet weak var lblEmail: UILabel?
    @IBOutlet weak var txtEmail: UITextField?
    @IBOutlet weak var lblOldPassword: UILabel?
    @IBOutlet weak var txtOldPassword: UITextField?
    
    @IBOutlet weak var lblNewPassword: UILabel?
    @IBOutlet weak var txtNewPassword: UITextField?
    @IBOutlet weak var lblVerifyPassword: UILabel?
    @IBOutlet weak var txtVerifyPassword: UITextField?
    
    @IBOutlet weak var btnSave: UIButton?
    
    //CLASS VARIABLES
    var viewModel: ForgotPasswordViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let email = Utilities.instance.getUserEmail()
        createCustomNavigationBar(title: "options.password_change".localize(), user: email, cloud: true, back: false, ble: true)
        customizeUI()
        
    }
    
    override func customizeUI() {
        
        //lblEmail?.text = "options_password_change.email".localize()
        //lblOldPassword?.text = "options_password_change.old_password".localize()
        //lblVerifyPassword?.text = "options_password_change.new_password".localize()
        //lblVerifyPassword?.text = "options_password_change.verify_password".localize()
        
        txtNewPassword?.placeholder = "options_password_change.new_password".localize()
        txtOldPassword?.placeholder = "options_password_change.old_password".localize()
        txtVerifyPassword?.placeholder = "options_password_change.verify_password".localize()
        
        txtNewPassword?.textColor = UIColor(hexString: Constants.smartpods_gray)
        txtNewPassword?.font = UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_text_size_small)
        
        txtOldPassword?.textColor = UIColor(hexString: Constants.smartpods_gray)
        txtOldPassword?.font = UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_text_size_small)
        
        txtVerifyPassword?.textColor = UIColor(hexString: Constants.smartpods_gray)
        txtVerifyPassword?.font = UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_text_size_small)
        
        
        btnSave?.setTitle("options_password_change.save".localize(), for: .normal)
        
        lblEmail?.adjustContentFontSize()
        txtEmail?.adjustContentFontSize()
        lblOldPassword?.adjustContentFontSize()
        txtOldPassword?.adjustContentFontSize()
        lblNewPassword?.adjustContentFontSize()
        txtNewPassword?.adjustContentFontSize()
        lblVerifyPassword?.adjustContentFontSize()
        txtVerifyPassword?.adjustContentFontSize()
    }
    
    override func bindViewModelAndCallbacks() {
        self.viewModel = ForgotPasswordViewModel()
        
        viewModel?.alertMessage = { [weak self](title: String, message: String, tag: Int) in
            //self?.displayStatusNotification(title: message, style: .danger)
            self?.displayNotificationMessage(title: "generic.error_title".localize(), subTitle: message, style: .danger)
        }

        
        viewModel?.showIndicator = { [weak self] (show: Bool) in
            self?.showActivityIndicator(show: show)
            
        }
        
        viewModel?.successResponse = {[weak self] (object: Any) in
            self?.displayNotificationMessage(title: "success.title".localize(), subTitle: "options_password_change.success_password_changed".localize(), style: .success)
            Threads.performTaskAfterDealy( 2, {
                BaseController.loginController(false)
            })
        }
    }
    
    /**
     Button actions.

    - Parameters: Button sender
    - Returns: none
     
    */
    
    @IBAction func onBtnActions(sender: UIButton) {
        switch sender.tag {
            case 0:
                let _email = txtEmail?.text ?? ""
                let _password = txtNewPassword?.text ?? ""
                let _oldPassword = txtOldPassword?.text ?? ""
                let _verifyPassword = txtVerifyPassword?.text ?? ""
                
                viewModel?.intializeResetPasswordUserLogged(email: _email,
                                                            old_password: _oldPassword,
                                                            new_password: _password,
                                                            verify_password: _verifyPassword)
                
            break
        default:
            break
        }
    }

}
