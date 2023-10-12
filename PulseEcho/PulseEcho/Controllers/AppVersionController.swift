//
//  AppVersionController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-26.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import EventCenter
import SwiftEventBus

class AppVersionController: BaseController {
    
    //STORYBOARD OUTLETS
    @IBOutlet weak var lblTitle1: UILabel?
    @IBOutlet weak var lblTitle2: UILabel?
    @IBOutlet weak var lblTitle3: UILabel?
    @IBOutlet weak var txtDescription: UITextView?
    @IBOutlet weak var viewContainer: UIView?
    
    //CLASS VARIABLES
    var identifierObject: SPIdentifier?

    override func viewDidLoad() {
        super.viewDidLoad()
        let email = Utilities.instance.getUserEmail()
        createCustomNavigationBar(title: "app_version.title".localize(), user: email, cloud: true, back: false, ble: true)
        customizeUI()
        SPBluetoothManager.shared.event = self.event
        
        viewContainer?.addBorder(on: [.top(thickness: 3, color: UIColor(hexstr: Constants.smartpods_blue))])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !Utilities.instance.IS_FREE_VERSION else {
            return
        }
            
        let firmwareVersion = Utilities.instance.getObjectFromUserDefaults(key: "firmware_ver") as? String
        self.lblTitle3?.text = String(format: "%@",firmwareVersion ?? "")
        
        self.requestPulseData(type: .Info)
    }
    
    override func customizeUI() {
        let app_version = "app_version.app_ver".localize()
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        view.addBorder(on: [.top(thickness: 3, color: .red)])
        
        lblTitle1?.text = String(format: "%@ (%@)", app_version,appVersion ?? "1.0")
        lblTitle1?.textAlignment = .center
        
        guard !Utilities.instance.IS_FREE_VERSION else {
            return
        }
        
        lblTitle2?.text = "app_version.firmware_ver".localize()
        
        SwiftEventBus.onMainThread(self, name: ViewEventListenerType.AppVersion.rawValue) { [weak self] result in
                
            if let obj = result?.object {
                if obj is SPIdentifier {
                    let identifier = obj as? SPIdentifier
                    
                    if self?.identifierObject == nil {
                        self?.identifierObject = identifier
                        self?.lblTitle3?.text = String(format: "%@",identifier?.Version ?? "0")
                        Utilities.instance.saveDefaultValueForKey(value: String(format: "%@",identifier?.Version ?? "0"), key: "firmware_ver")
                    } else {
                        if self?.identifierObject?.Version != identifier?.Version {
                            Utilities.instance.saveDefaultValueForKey(value: String(format: "%@",identifier?.Version ?? "0"), key: "firmware_ver")
                            self?.lblTitle3?.text = String(format: "%@",identifier?.Version ?? "0")
                        } else {
                            self?.lblTitle3?.text = String(format: "%@",self?.identifierObject?.Version ?? "0")
                        }
                    }
                }
                
            }
        }
        
        txtDescription?.text = "app_version.version_desc".localize()
        
        lblTitle1?.adjustContentFontSize()
        lblTitle2?.adjustContentFontSize()
        
    }
    
    

}

