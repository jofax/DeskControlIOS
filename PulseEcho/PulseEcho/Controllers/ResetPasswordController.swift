//
//  ResetPasswordController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-15.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Material
import Localize

class ResetPasswordController: BaseController {

    //STORYBOARD OUTLETS
    @IBOutlet weak var txtCode: TextField?
    @IBOutlet weak var txtPassword: TextField?
    @IBOutlet weak var txtVerifyPassword: TextField?
    @IBOutlet weak var btnValidate: UIButton?
    @IBOutlet weak var btnSave: UIButton?
    @IBOutlet weak var btnCancel: UIButton?
    @IBOutlet weak var viewResetPassword: UIView?
    @IBOutlet weak var viewPinCode: UIView?
       
    //CLASS VARIABLES
    var viewModel: ForgotPasswordViewModel?
    var isValidate: Bool = false
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createCustomNavigationBar(title: "welcome.forgot".localize(), user: "", cloud: false, back: false, ble: false)
        customizeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func customizeUI() {
        
        txtCode?.placeholder = "forgot.reset_code".localize()
        txtPassword?.placeholder = "forgot.new_password".localize()
        txtVerifyPassword?.placeholder = "forgot.verify_new_password".localize()
        
        btnValidate?.setTitle("forgot.validate_code".localize(), for: .normal)
        btnSave?.setTitle("common.submit".localize(), for: .normal)
        btnCancel?.setTitle("common.cancel".localize(), for: .normal)
        
        btnValidate?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnValidate?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        
        btnSave?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnSave?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        
        btnCancel?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnCancel?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        
        btnValidate?.titleLabel?.adjustContentFontSize()
        btnSave?.titleLabel?.adjustContentFontSize()
        btnCancel?.titleLabel?.adjustContentFontSize()
        txtCode?.adjustContentFontSize()
        txtPassword?.adjustContentFontSize()
        txtVerifyPassword?.adjustContentFontSize()
    }
    
    override func bindViewModelAndCallbacks() {
        self.viewModel = ForgotPasswordViewModel()
        
        viewModel?.alertMessage = { [weak self](title: String, message: String, tag: Int) in
            self?.displayStatusNotification(title: message, style: .danger)
        }
        
        viewModel?.enableState = { (enable: Bool) in
            
        }
        
        viewModel?.showIndicator = { [weak self] (show: Bool) in
            self?.showActivityIndicator(show: show)
        }
        
        viewModel?.successResponse = { [weak self] (object: Any) in
            self?.displayNotificationMessage(title: "success.title".localize(), subTitle: "forgot.success_reset_password".localize(), style: .success)
            Threads.performTaskAfterDealy( 3, {
               self?.navigationController?.popToRootViewController(animated: true)
            })
        }
    }
    
    /**
     Button actions.
    - Parameters: Button sender
    - Returns: none
     */
    
    @IBAction func onBtnActions(sender: UIButton) {
        textFieldDismissKeyboard(sender: txtCode ?? UITextField())
        textFieldDismissKeyboard(sender: txtPassword ?? UITextField())
        textFieldDismissKeyboard(sender: txtVerifyPassword ?? UITextField())
        
        switch sender.tag {
        case 0:
            let _code = txtCode?.text ?? ""
            viewModel?.initializePinCode(pincode: _code)
            self.isValidate = true
        case 1:
            let _password = txtPassword?.text ?? ""
            let _verify_password = txtVerifyPassword?.text ?? ""
            let _code = txtCode?.text ?? ""
            viewModel?.intializeResetPassword(email: email ?? "", code: _code, password: _password, verify_password: _verify_password)
            break
        case 2:
            self.navigationController?.popToRootViewController(animated: true)
        default:
            break
        }
    }
    
    /**
     Reset password elements to be enable or disabled if pin code is not yet verified..
     - Parameters: Bool enable
     - Parameters: CGFloat alpha
     - Parameters: Bool enableValidateFields
     - Returns: none
     
     */
    
    private func enableDisableViewElemants(enable: Bool, alpha: CGFloat, enableValidateFields: Bool) {
        self.txtVerifyPassword?.isEnabled = enable
        self.txtVerifyPassword?.alpha = alpha
        self.txtPassword?.isEnabled = enable
        self.txtPassword?.alpha = alpha
        self.btnSave?.isEnabled = enable
        self.btnSave?.alpha = alpha
        
        self.txtCode?.isEnabled = enableValidateFields
        self.btnValidate?.isEnabled = enableValidateFields
        
        self.txtCode?.alpha = enableValidateFields ? 1.0 : 0.5
        self.btnValidate?.alpha = enableValidateFields ? 1.0 :0.5
    }
}
