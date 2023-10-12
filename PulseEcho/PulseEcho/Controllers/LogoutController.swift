//
//  LogoutController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-28.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class LogoutController: BaseController {

    //STORYBOARD OUTLETS
    @IBOutlet weak var lblTitle1: UILabel?
    @IBOutlet weak var lblTitle2: UILabel?
    @IBOutlet weak var btnLogout: UIButton?
    
    //CLASS VARIABLES

    override func viewDidLoad() {
        super.viewDidLoad()
        let email = Utilities.instance.getUserEmail()
        createCustomNavigationBar(title: "logout.title".localize(), user: email, cloud: true, back: false, ble: true)
        customizeUI()
    }
    
    override func customizeUI() {
        
        lblTitle1?.text = "logout.desc1".localize()
        lblTitle2?.text = "logout.desc2".localize()
        btnLogout?.titleLabel?.text = "logout.title".localize()
        
        lblTitle1?.adjustContentFontSize()
        lblTitle1?.adjustContentFontSize()
        btnLogout?.titleLabel?.adjustContentFontSize()
    }
    
    @IBAction func onBtnAction(sender: UIButton) {
        self.logoutUser(useGuest: false)
    }
}
