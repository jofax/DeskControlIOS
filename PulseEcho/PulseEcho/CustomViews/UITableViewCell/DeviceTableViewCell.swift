//
//  DeviceTableViewCell.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-12.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol DeviceTableViewCellDelegate {
    func connectToDevice(_ index: IndexPath)
    func dismissDeviceList()
    func deviceNotInPairingMode()
}

class DeviceTableViewCell: BaseTableViewCell {

    //VIEW OUTLETS
    
    @IBOutlet weak var peripheralLabel: UILabel?
    @IBOutlet weak var btnConnect: UIButton?
    @IBOutlet weak var connectStatus: UIActivityIndicatorView?
    
    //CLASS VARIABLES
    var indexPath: IndexPath?
    var delegate: DeviceTableViewCellDelegate?
    var currentSelected: Bool = false
    var deviceName: String = ""
    
    var questDevice: QuestDevice? {
        didSet {
            loaderStatus(connect: questDevice?.isConnecting ?? false)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        connectStatus?.isHidden = true
        // Initialization code
        
        //btnConnect?.isEnabled = enableConnect
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onBtnActions(sender: UIButton) {
        delegate?.connectToDevice(indexPath ?? IndexPath())
    }
    
//    override func prepareForReuse() {
//            super.prepareForReuse()
//        if let spinner = self.connectStatus {
//            guard currentSelected else {
//                spinner.startAnimating()
//                return
//            }
//
//            if let peripheral = SPBluetoothManager.shared.state.peripheral {
//                if peripheral.state == .connecting {
//
//                    spinner.startAnimating()
//                    btnConnect?.isHidden = true
//                    btnConnect?.isUserInteractionEnabled = false
//                    connectStatus?.isHidden = false
//                 } else {
//                    spinner.stopAnimating()
//                    btnConnect?.isHidden = false
//                    btnConnect?.isUserInteractionEnabled = true
//                    connectStatus?.isHidden = true
//                 }
//            }
//        }
//    }
    
    func loaderStatus(connect: Bool) {
        DispatchQueue.main.async {
            guard  connect else {
                self.connectStatus?.stopAnimating()
                self.btnConnect?.isHidden = false
                self.btnConnect?.isUserInteractionEnabled = true
                self.connectStatus?.isHidden = true
                return
            }
            
            self.connectStatus?.startAnimating()
            self.btnConnect?.isHidden = true
            self.btnConnect?.isUserInteractionEnabled = false
            self.connectStatus?.isHidden = false
        }
    }

    func checkStatus() {
        
        /*guard currentSelected else {
            connectStatus?.stopAnimating()
            btnConnect?.isHidden = false
            btnConnect?.isUserInteractionEnabled = true
            connectStatus?.isHidden = true
            return
        }
        
        if SPBluetoothManager.shared.pulse == .Disconnected {
            connectStatus?.stopAnimating()
            btnConnect?.isHidden = false
            btnConnect?.isUserInteractionEnabled = true
            connectStatus?.isHidden = true
            return
        }
        
        if SPBluetoothManager.shared.pulse == .Connecting {
            connectStatus?.startAnimating()
            btnConnect?.isHidden = true
            btnConnect?.isUserInteractionEnabled = false
            connectStatus?.isHidden = false
        } else {

            connectStatus?.startAnimating()
            btnConnect?.isHidden = true
            btnConnect?.isUserInteractionEnabled = false
            connectStatus?.isHidden = false
            
            if let peripheral = SPBluetoothManager.shared.state.peripheral {
                
                if peripheral.state == .connected {
                    
                    btnConnect?.setTitle("Disconnect", for: .normal)
                    btnConnect?.setTitleColor(.red, for: .normal)
                    
                    connectStatus?.stopAnimating()
                    btnConnect?.isHidden = false
                    btnConnect?.isUserInteractionEnabled = true
                    connectStatus?.isHidden = true
                    delegate?.dismissDeviceList()
                    
                 } else {
                    
                        connectStatus?.stopAnimating()
                        btnConnect?.isHidden = false
                        btnConnect?.isUserInteractionEnabled = true
                        connectStatus?.isHidden = true
                        
                        btnConnect?.setTitle("Connect", for: .normal)
                        btnConnect?.setTitleColor(UIColor(hexString: Constants.smartpods_green), for: .normal)
                        
                }
            } else {
                connectStatus?.stopAnimating()
                btnConnect?.isHidden = false
                btnConnect?.isUserInteractionEnabled = true
                connectStatus?.isHidden = true
            }
            
        }*/
        
        
    }
    
}
