//
//  RegisterController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-10.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Material

class RegisterController: BaseController {
    
    //STORYBOARD OUTLETS

    @IBOutlet weak var txtUsername: TextField?
    @IBOutlet weak var txtPassword: TextField?
    @IBOutlet weak var txtVerifyPassword: TextField?
    @IBOutlet weak var btnBack: UIButton?
    @IBOutlet weak var btnRegister: UIButton?
    @IBOutlet weak var lblLoginTitle: UILabel?
    @IBOutlet weak var lblPassword: UILabel?
    @IBOutlet weak var lblVerifyPassword: UILabel?
       
    //CLASS VARIABLES
       
    private var viewModel: RegisterViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        createCustomNavigationBar(title: "welcome.register".localize(), user: "", cloud: false, back: false, ble: false)
        customizeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func customizeUI() {
        
        lblLoginTitle?.text = "welcome.login".localize()
        lblPassword?.text = "welcome.password".localize()
        txtUsername?.placeholder = "welcome.email".localize()
        txtVerifyPassword?.placeholder = "registration.verify_password".localize()
        txtPassword?.placeholder = "welcome.password".localize()
        btnRegister?.setTitle("registration.register".localize(), for: .normal)
        btnBack?.setTitle("common.back".localize(), for: .normal)
        
        btnRegister?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnRegister?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        
        btnBack?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnBack?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        
        lblLoginTitle?.adjustContentFontSize()
        lblPassword?.adjustContentFontSize()
        btnRegister?.titleLabel?.adjustContentFontSize()
        btnBack?.titleLabel?.adjustContentFontSize()
        
        txtUsername?.adjustContentFontSize()
        txtPassword?.adjustContentFontSize()
        txtVerifyPassword?.adjustContentFontSize()
    }
    
    override func bindViewModelAndCallbacks() {
        self.viewModel = RegisterViewModel()
        
        viewModel?.alertMessage = { [weak self](title: String, message: String, tag: Int) in
            self?.displayStatusNotification(title: message, style: .danger)
        }
        
        viewModel?.enableState = { [weak self] (enable: Bool) in
            self?.btnRegister?.isEnabled = enable
        }
        
        viewModel?.showIndicator = { [weak self] (show: Bool) in
            self?.showActivityIndicator(show: show)
        }
        
        viewModel?.successResponse = { [weak self] (object: Any) in
            //check if use is successfully verified
            self?.displayNotificationMessage(title: "success.title".localize(), subTitle: "success.signup_message".localize(), style: .success)
            
            Threads.performTaskAfterDealy( 2, {
                let _email = self?.txtUsername?.text ?? ""
                let _password = self?.txtPassword?.text ?? ""
                let controller = ActivateController.instantiateFromStoryboard(storyboard: "Login") as! ActivateController
                controller.email = _email
                controller.userPassword = _password
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
        
        textFieldDismissKeyboard(sender: txtUsername ?? UITextField())
        textFieldDismissKeyboard(sender: txtPassword ?? UITextField())
        textFieldDismissKeyboard(sender: txtVerifyPassword ?? UITextField())
        
        switch sender.tag {
        case 0:
            let _email = txtUsername?.text ?? ""
            let _password = txtPassword?.text ?? ""
            let _verify_password = txtVerifyPassword?.text ?? ""
            viewModel?.initializeUserSignup(username: _email,
                                            password: _password,
                                            verify_password: _verify_password)
            break
        case 1:
            viewModel?.cancelCurrentRequest()
            self.navigationController?.popViewController(animated: true)
            break
        default:
            break
        }
    }

}
