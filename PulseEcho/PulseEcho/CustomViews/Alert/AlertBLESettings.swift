//
//  AlertBLESettings.swift
//  PulseEcho
//
//  Created by Joseph on 2021-02-24.
//  Copyright © 2021 Smartpods. All rights reserved.
//

import UIKit
import FontAwesome_swift

protocol AlertBLESettingsDelegate {
    func dismissAlertBleSettings()
}

class AlertBLESettings: UIViewController {
    
    var delegate: AlertBLESettingsDelegate?
    
    @IBOutlet weak var imgSettingsIcon: UIImageView?
    @IBOutlet weak var imgBluetoothIcon: UIImageView?
    @IBOutlet weak var imgInfoIcon: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgSettingsIcon?.image = UIImage(named: "apple-settings")
        imgBluetoothIcon?.image = UIImage.fontAwesomeIcon(name: .bluetoothB, style: .brands, textColor:  UIColor(hexString: Constants.smartpods_blue), size: CGSize(width: 30, height: 30))
        imgInfoIcon?.image = UIImage.fontAwesomeIcon(name: .infoCircle, style: .solid, textColor:  UIColor(hexString: Constants.smartpods_blue), size: CGSize(width: 30, height: 30))
        
        //need to update pulse device object
        let device = ["Identifier":"",
                      "PeripheralName": "",
                      "State":PulseState.Disconnected.rawValue,
                      "DisconnectedByUser": false] as [String : Any]
        
        SPBluetoothManager.shared.pulseObjectParameters(parameters: device)
    }

    @IBAction func onBtnActions(sender: UIButton) {
        switch sender.tag {
        case 0:
            dismiss(animated: true, completion: {
                self.delegate?.dismissAlertBleSettings()
            })
        case 1:
            dismiss(animated: true, completion: nil)
        default: break
        }
    }

}
