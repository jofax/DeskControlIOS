//
//  SPControlBoxController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-04-02.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class SPControlBoxController: BaseController {

   @IBOutlet private weak var stackViewScrollView: ScrollViewStack!
   let boxController = BoxControlController.instantiateFromStoryboard(storyboard: "Settings") as! BoxControlController
   let indicatorBlinker = SPTimeScheduler(timeInterval: 5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPBluetoothManager.shared.delegate = self
        let email = Utilities.instance.getUserEmail()
        createCustomNavigationBar(title: "options.control_title".localize(), user: email, cloud: true, back: false, ble: true)
        self.stackViewScrollView.showsVerticalScrollIndicator = true
        self.stackViewScrollView.indicatorStyle = .black
        
        self.stackViewScrollView.insertView(view: boxController.view)
        indicatorBlinker.resume()
        customizeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        boxController.appControlsCheck()
        self.stackViewScrollView.flashScrollIndicators()
    }
    
    override func customizeUI() {
        indicatorBlinker.eventHandler = {
            
            switch deviceSize {
                case .i4Inch, .i4_7Inch:
                    DispatchQueue.main.async {
                        self.stackViewScrollView.flashScrollIndicators()
                    }
                    break
                default:
                    
                break
            }
            
        }
    }
    
}

extension SPControlBoxController: SPBluetoothManagerDelegate {
    
    func updateInterface() {
        print("SPControlBoxController : updateInterface")
    }
    
    func unableToPairWithBox() {
        
    }
    
    func updateDeviceConnectivity(connect: Bool) {
        boxController.appControlsCheck()
    }
    
    func connectivityState(title: String, message: String, code: Int) {
        self.showAlert(title: title, message: message)
    }
    
    func deviceConnected() {
        /*if let peripheral = SPBluetoothManager.shared.state.peripheral {
            print("device connected peripheral: ", peripheral.state)
            if peripheral.state == .connected {
                let hasPSP = peripheral.name?.hasPrefix("PSP-") ?? false
                if hasPSP {
                    if peripheral.spDesiredCharacteristic != nil {
                        SPBluetoothManager.shared.sendHeartBeat(peripheral, peripheral.spDesiredCharacteristic!)
                    }
                }
                checkBLEConnectivityIndicator()
            }
        } else {
            print("INVALID PERIPHERAL")
        }*/
    }

}

