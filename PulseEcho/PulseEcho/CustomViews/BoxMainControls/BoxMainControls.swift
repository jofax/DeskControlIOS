//
//  BoxMainControls.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-12.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import FontAwesome_swift
import SwiftEventBus

protocol BoxMainControlsDelegate: class {
    func stopAction()
    func sitAction()
    func standAction()
    func closePanel()
}

class BoxMainControls: UIView {

     //VIEW OUTLETS
    @IBOutlet weak var btnControlMenu: UIButton?
    @IBOutlet weak var btnSit: UIButton?
    @IBOutlet weak var btnStand: UIButton?
    @IBOutlet weak var btnStop: UIButton?
    
    
    //CLASS VARIABLES
    var delegate: BoxMainControlsDelegate?
     /**
     Static variable nib for identifying the view
     - Returns: Nib file
     */
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    /**
     Static variable string for the view identifier
     - Returns: String filename
     */
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        //print("BOX INITIALIZATION CALLED")
        
        //Event to get height informations
        
//        guard !Utilities.instance.IS_FREE_VERSION else {
//            return
//        }
        
        SwiftEventBus.onMainThread(self, name: ViewEventListenerType.BoxMainControlDataStream.rawValue) { [weak self] result in
            let obj = result?.object
            
            if obj is SPCoreObject {
                let _heightObject = obj as? SPCoreObject
                let moveUpStatus = _heightObject?.Movingupstatus ?? false
                let moveDownStatus =  _heightObject?.Movingdownstatus ?? false
                
                if moveUpStatus {
                    self?.btnSit?.isSelected = false
                    self?.updateSelectedTag(tag: Utilities.instance.boxControlButtonTag)
                } else if moveDownStatus {
                    self?.btnStand?.isSelected = false
                    self?.updateSelectedTag(tag: Utilities.instance.boxControlButtonTag)
                } else {
                   self?.resetBtnState()
                   //Utilities.instance.boxControlButtonTag = 0
                   //self?.updateSelectedTag(tag: Utilities.instance.boxControlButtonTag)
                }

            }
        }
        
        
        btnControlMenu?.setImage(UIImage.fontAwesomeIcon(name: .angleDoubleRight,
                                                         style: .solid,
                                                         textColor: UIColor(hexString: Constants.smartpods_blue),
                                                         size: CGSize(width: 30, height: 30)),
                                 for: .normal)

        btnControlMenu?.setImage(UIImage.fontAwesomeIcon(name: .angleDoubleRight,
                                                         style: .solid,
                                                         textColor: UIColor(hexString: Constants.smartpods_green),
                                                         size: CGSize(width: 30, height: 30)),
                                 for: .highlighted)
        
//        btnControlMenu?.setImage(UIImage(named: "controls_shortcut"),
//                                       for: .normal)
//
//        btnControlMenu?.setImage(UIImage(named: "controls_shortcut_click"),
//                                       for: .highlighted)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
         swipeRight.direction = .right
         self.addGestureRecognizer(swipeRight)
    }
    
    @IBAction func onBtnActions(sender: UIButton) {
        resetBtnState()
        switch sender.tag {
            case 0:
                delegate?.closePanel()
            case 1:
                if Utilities.instance.isBLEBoxConnected() {
                    sender.isSelected = !sender.isSelected
                }
                
                delegate?.sitAction()
            case 2:
                if Utilities.instance.isBLEBoxConnected() {
                    sender.isSelected = !sender.isSelected
                }
                
                delegate?.standAction()
            case 3:
                delegate?.stopAction()
            default:break
        }
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
       if gesture.direction == .right {
             delegate?.closePanel()
       }
    }
    
    func updateSelectedTag(tag: Int) {
        switch tag {
        case 1:
            if Utilities.instance.isBLEBoxConnected() {
                btnSit?.isSelected = true
            }
        case 2:
            if Utilities.instance.isBLEBoxConnected() {
                btnStand?.isSelected = true
            }
        default:
            btnSit?.isSelected = false
            btnStand?.isSelected = false
        }
    }
    
    func resetBtnState() {
        btnSit?.isSelected = false
        btnStand?.isSelected = false
    }
}
