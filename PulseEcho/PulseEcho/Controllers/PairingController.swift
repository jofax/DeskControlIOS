//
//  PairingController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-04-07.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

protocol PairingControllerDelegate {
    func showDeviceList()
}

class PairingController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var boxImage: UIImageView?
    @IBOutlet weak var lblHold: UILabel?
    @IBOutlet weak var lblDescription: UITextView?
    @IBOutlet weak var lblRecognized: UILabel?
    @IBOutlet weak var lblDeviceId: UILabel?
    @IBOutlet weak var btnPair: CustomButtonWithShadow?
    @IBOutlet weak var btnCancel: CustomButtonWithShadow?
    @IBOutlet weak var viewVideoContainer: UIView?

    var delegate: PairingControllerDelegate?
    
    var videoUrl: URL?
    var player: AVPlayer?
    let avPVC = AVPlayerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btnPair?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnPair?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        btnPair?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .selected)
        
        btnPair?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnPair?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        btnPair?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .selected)
        
        // Do any additional setup after loading the view.
        
        lblTitle?.adjustContentFontSize()
        lblHold?.adjustContentFontSize()
        lblDescription?.adjustContentFontSize()
        lblDeviceId?.adjustContentFontSize()
        btnPair?.titleLabel?.adjustContentFontSize()
        btnCancel?.titleLabel?.adjustContentFontSize()
        
        guard let path = Bundle.main.path(forResource: "pairing_instruction", ofType: "mp4") else {
            return
        }
        self.videoUrl =  URL(fileURLWithPath: path)
        
        guard let videoUrl = self.videoUrl else { return }
        self.player = AVPlayer(url: videoUrl)
        avPVC.player = self.player
        avPVC.view.frame = CGRect(x: 0, y: 0, width: self.viewVideoContainer?.frame.width ?? 320, height: self.viewVideoContainer?.frame.height ?? 240)
        self.addChild(avPVC)
        self.viewVideoContainer?.addSubview(avPVC.view)
        avPVC.didMove(toParent: self)
        
        Threads.performTaskAfterDealy(1.0) {
            self.player?.play()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func onBtnActions(sender: UIButton) {
        switch sender.tag {
        case 0:
            self.dismiss(animated: true, completion: {
                self.player?.stop()
                
                let dataHelper = SPRealmHelper()
                let email = Utilities.instance.getUserEmail()
                let appState = dataHelper.getAppState(email)
                let hasOrgCode = appState.HasOrgCode
                
                if (!hasOrgCode) {
                    self.dismiss(animated: true, completion: {
                        //self.delegate?.showDeviceList()
                    })
                } else {
                    if Utilities.instance.isFirstAppLaunch() {
                        self.delegate?.showDeviceList()
                    }
                }
                
                
            })
            
        case 1:
            self.player?.stop()
            self.dismiss(animated: true, completion: {
                //self.delegate?.showDeviceList()
            })
        default:break
        }
    }
    

}
