//
//  BoxControlController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-26.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import TGPControls
import EventCenter
import SwiftEventBus
import FontAwesome_swift
import RealmSwift

class BoxControlController: BaseController, UIScrollViewDelegate {

    //STORYBOARD OUTLETS
    
    @IBOutlet weak var indicatorLightSlider: TGPDiscreteSlider?
    @IBOutlet weak var lblIndicatorTitle: UILabel?
    @IBOutlet weak var lblIndicatorValue: UILabel?
    @IBOutlet weak var lblBrightness: UILabel?
    @IBOutlet weak var btnIndicatorMinus: UIButton?
    @IBOutlet weak var btnIndicatorPlus: UIButton?
    
    @IBOutlet weak var lblSafetyTitle: UILabel?
    @IBOutlet weak var lblSafetyValue: UILabel?
    @IBOutlet weak var lblSafetySensitivity: UILabel?
    @IBOutlet weak var btnSafetyMinus: UIButton?
    @IBOutlet weak var btnSafetyPlus: UIButton?
    @IBOutlet weak var safetySlider: TGPDiscreteSlider?
    
    @IBOutlet weak var lblPresenceTitle: UILabel?
    @IBOutlet weak var lblPresenceValue: UILabel?
    @IBOutlet weak var lblPresenceSensitivity: UILabel?
    @IBOutlet weak var btnPresenceMinus: UIButton?
    @IBOutlet weak var btnPresencePlus: UIButton?
    @IBOutlet weak var presenceSlider: TGPDiscreteSlider?
    
    
    @IBOutlet weak var lblAwayTitle: UILabel?
    @IBOutlet weak var lblAwayValue: UILabel?
    @IBOutlet weak var lblAwayDuration: UILabel?
    @IBOutlet weak var btnAwayMinus: UIButton?
    @IBOutlet weak var btnAwayPlus: UIButton?
    @IBOutlet weak var awaySlider: TGPDiscreteSlider?
    
    @IBOutlet weak var lblPresenceStandTitle: UILabel?
    @IBOutlet weak var lblPresenceStandValue: UILabel?
    @IBOutlet weak var lblPresenceStandSensitivity: UILabel?
    @IBOutlet weak var btnPresenceStandMinus: UIButton?
    @IBOutlet weak var btnPresenceStandPlus: UIButton?
    @IBOutlet weak var presenceSliderStand: TGPDiscreteSlider?
    
    @IBOutlet weak var btnInvertSitting: UIButton?
    @IBOutlet weak var btnInvertStanding: UIButton?
    
    @IBOutlet weak var lblInvertSitting: UILabel?
    @IBOutlet weak var lblInvertStanding: UILabel?
    
    @IBOutlet weak var btnFunctionInvertedSitting: UIButton?
    @IBOutlet weak var btnFunctionInvertedStanding: UIButton?
    
    @IBOutlet weak var sittingSwitch: UISwitch?
    @IBOutlet weak var standingSwitch: UISwitch?
    
    @IBOutlet weak var legacySwitch: UISwitch?
    @IBOutlet weak var btnCapture: UIButton?
    
    @IBOutlet weak var viewSittingContainer: UIView?
    @IBOutlet weak var viewStandingContainer: UIView?
    
    var isAutomatic: Bool = false
    var isLegacy: Bool = false
    let dataHelper = SPRealmHelper()
    
    //CLASS VARIABLES

    var lightValue: Int?
    var presenceValue: Int?
    var safetyValue: Int?
    var awayAdjustValue: Int?
    var appSigmaStandingThreshold: Int?
    var appSigmaSittingThreshold: Int?
    var enableHeatSensingFlipStanding: Bool?
    var enableHeatSensingFlipSitting: Bool?
    
    var isAutomaticPresence: Bool?
    var isLegacyEnabled: Bool?
    
    var sigmaStandingThreshold: Int?
    
    var coreOneObject: SPCoreObject?
    
    var safetyAlertShown: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SPBluetoothManager.shared.event = self.event
        SPBluetoothManager.shared.delegate = self
        let email = Utilities.instance.getUserEmail()
        createCustomNavigationBar(title: "options.control_title".localize(), user: email, cloud: true, back: false, ble: true)
        customizeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("BoxControlController viewDidAppear")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("BoxControlController viewWillAppear")
    }
    
    override func customizeUI() {
        lblIndicatorTitle?.adjustContentFontSize()
        lblIndicatorValue?.adjustContentFontSize()
        
        lblBrightness?.adjustContentFontSize()
        lblSafetyTitle?.adjustContentFontSize()
        lblSafetyValue?.adjustContentFontSize()
        lblSafetySensitivity?.adjustContentFontSize()
        lblPresenceTitle?.adjustContentFontSize()
        lblPresenceValue?.adjustContentFontSize()
        lblPresenceSensitivity?.adjustContentFontSize()
        
        lblAwayTitle?.adjustContentFontSize()
        lblAwayDuration?.adjustContentFontSize()
        lblAwayValue?.adjustContentFontSize()
        
        lblPresenceStandTitle?.adjustContentFontSize()
        lblPresenceStandValue?.adjustContentFontSize()
        lblPresenceStandSensitivity?.adjustContentFontSize()
        
        btnInvertSitting?.titleLabel?.adjustContentFontSize()
        btnInvertStanding?.titleLabel?.adjustContentFontSize()
        
        
        indicatorLightSlider?.addTarget(self, action: #selector(self.sliderValueChange), for: .valueChanged)
        safetySlider?.addTarget(self, action: #selector(self.sliderValueChange), for: .valueChanged)
        presenceSlider?.addTarget(self, action: #selector(self.sliderValueChange), for: .valueChanged)
        awaySlider?.addTarget(self, action: #selector(self.sliderValueChange), for: .valueChanged)
        presenceSliderStand?.addTarget(self, action: #selector(self.sliderValueChange), for: .valueChanged)
        
        indicatorLightSlider?.maximumTrackTintColor = UIColor(hexString: Constants.smartpods_gray)
        safetySlider?.maximumTrackTintColor = UIColor(hexString: Constants.smartpods_gray)
        presenceSlider?.maximumTrackTintColor = UIColor(hexString: Constants.smartpods_gray)
        presenceSliderStand?.maximumTrackTintColor = UIColor(hexString: Constants.smartpods_gray)
        awaySlider?.maximumTrackTintColor = UIColor(hexString: Constants.smartpods_gray)
        
        btnCapture?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnCapture?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        btnCapture?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .selected)

        
        
        SPBluetoothManager.shared.delegate = self
        
        SwiftEventBus.onMainThread(self, name: ViewEventListenerType.BLEConnectivityStream.rawValue) {_ in
            self.appControlsCheck()
        }
        
        SwiftEventBus.onMainThread(self, name: ViewEventListenerType.BoxControlDataStream.rawValue) { [weak self] result in
            let obj = result?.object
            
            if obj is SPCoreObject {
                let _core = obj as? SPCoreObject
                self?.coreOneObject = _core
                //print("_core?.NeedPresenceCapture: ", _core?.NeedPresenceCapture)
                
                if (self?.lightValue == nil) ||
                    (self?.appSigmaSittingThreshold == nil) ||
                    (self?.safetyValue == nil) ||
                    (self?.awayAdjustValue == nil) || (self?.appSigmaStandingThreshold == nil) {
                    
                    self?.lightValue = _core?.LEDSlider
                    self?.appSigmaSittingThreshold = _core?.SitPresence
                    self?.safetyValue = _core?.SafetySlider
                    self?.awayAdjustValue = _core?.AwaySlider
                    self?.appSigmaStandingThreshold = _core?.StandPresence
                    
                } else {
                    if (_core?.LEDSlider == self?.lightValue) ||
                        (_core?.SitPresence == self?.appSigmaSittingThreshold) ||
                        (_core?.SafetySlider == self?.safetyValue) ||
                        (_core?.AwaySlider == self?.awayAdjustValue) ||
                        (_core?.StandPresence == self?.appSigmaStandingThreshold){
                       return
                    } else {
                        self?.lightValue = _core?.LEDSlider
                        self?.appSigmaSittingThreshold = _core?.SitPresence
                        self?.safetyValue = _core?.SafetySlider
                        self?.awayAdjustValue = _core?.AwaySlider
                        self?.appSigmaStandingThreshold = _core?.StandPresence
                    }
                }
                
                self?.updateControlValues()
                self?.invertedStatusIndicators()
                                   
               if (self?.enableHeatSensingFlipStanding == nil) ||
                   (self?.enableHeatSensingFlipSitting == nil){
                   
                   self?.enableHeatSensingFlipStanding = _core?.EnableHeatSenseFlipStanding
                   self?.enableHeatSensingFlipSitting = _core?.EnableHeatSenseFlipSitting
                   
               } else {
                   if (_core?.EnableHeatSenseFlipStanding == self?.enableHeatSensingFlipStanding) ||
                       (_core?.EnableHeatSenseFlipSitting == self?.enableHeatSensingFlipSitting) {
                      return
                   } else {
                       self?.enableHeatSensingFlipStanding = _core?.EnableHeatSenseFlipStanding
                       self?.enableHeatSensingFlipSitting = _core?.EnableHeatSenseFlipSitting
                   }
               }
                
                
                
                if (self?.isAutomaticPresence == nil){
                    
                    self?.isAutomaticPresence = _core?.AutoPresenceDetection
                    
                    if (_core?.AutoPresenceDetection == true) {
                        self?.presenceIndicator(automatic: true, legacy: false, withCommand: false)
                    } else {
                        self?.presenceIndicator(automatic: false, legacy: true, withCommand: false)
                    }
                    
                } else {
                    if (_core?.AutoPresenceDetection == self?.isAutomaticPresence) {
                       return
                    } else {
                        self?.isAutomaticPresence = _core?.AutoPresenceDetection
                        if (_core?.AutoPresenceDetection == true) {
                            self?.presenceIndicator(automatic: true, legacy: false, withCommand: false)
                        } else {
                            self?.presenceIndicator(automatic: false, legacy: true, withCommand: false)
                        }

                    }
                }
                
                //print("CORE OBJECT: ", _core?.LEDSlider)
                //self?.updateControlValues()
                self?.invertedStatusIndicators()
               
            }
            
//            if obj is BoxHeight {
//                let _data = obj as? BoxHeight
//                self?.boxHeightObject = _data
//                self?.sigmaStandingThreshold = _data?.SigmaStandingThreshold
//            }
                
        }
        
    }
    
    func appControlsCheck() {
        if let peripheral = SPBluetoothManager.shared.state.peripheral {
            guard peripheral.state == .connected else {
            
                indicatorLightSlider?.isUserInteractionEnabled = false
                safetySlider?.isUserInteractionEnabled = false
                presenceSlider?.isUserInteractionEnabled = false
                awaySlider?.isUserInteractionEnabled = false
                presenceSliderStand?.isUserInteractionEnabled = false
                
                btnIndicatorPlus?.isEnabled = false
                btnIndicatorMinus?.isEnabled = false
                
                btnSafetyPlus?.isEnabled = false
                btnSafetyMinus?.isEnabled = false
                
                btnAwayPlus?.isEnabled = false
                btnAwayMinus?.isEnabled = false
                
                btnPresenceMinus?.isEnabled = false
                btnPresencePlus?.isEnabled = false
                
                btnPresenceStandPlus?.isEnabled = false
                btnPresenceStandMinus?.isEnabled = false
                
                btnCapture?.isEnabled = false
                legacySwitch?.isEnabled = false
                
                return
            }
            
            indicatorLightSlider?.isUserInteractionEnabled = true
            safetySlider?.isUserInteractionEnabled = true
            presenceSlider?.isUserInteractionEnabled = true
            awaySlider?.isUserInteractionEnabled = true
            presenceSliderStand?.isUserInteractionEnabled = true
            
            btnIndicatorPlus?.isEnabled = true
            btnIndicatorMinus?.isEnabled = true
            
            btnSafetyPlus?.isEnabled = true
            btnSafetyMinus?.isEnabled = true
            
            btnAwayPlus?.isEnabled = true
            btnAwayMinus?.isEnabled = true
            
            btnPresenceMinus?.isEnabled = true
            btnPresencePlus?.isEnabled = true
            
            btnPresenceStandPlus?.isEnabled = true
            btnPresenceStandMinus?.isEnabled = true
            
            btnCapture?.isEnabled = true
            legacySwitch?.isEnabled = true
            
        } else {
            indicatorLightSlider?.isUserInteractionEnabled = false
            safetySlider?.isUserInteractionEnabled = false
            presenceSlider?.isUserInteractionEnabled = false
            awaySlider?.isUserInteractionEnabled = false
            presenceSliderStand?.isUserInteractionEnabled = false
            
            btnIndicatorPlus?.isEnabled = false
            btnIndicatorMinus?.isEnabled = false
            
            btnSafetyPlus?.isEnabled = false
            btnSafetyMinus?.isEnabled = false
            
            btnAwayPlus?.isEnabled = false
            btnAwayMinus?.isEnabled = false
            
            btnPresenceMinus?.isEnabled = false
            btnPresencePlus?.isEnabled = false
            
            btnPresenceStandPlus?.isEnabled = false
            btnPresenceStandMinus?.isEnabled = false
            
            btnCapture?.isEnabled = false
            legacySwitch?.isEnabled = false
        }
        
        getAppState()
        
    }
    
    func updateControlValues() {
        print("updateControlValues")
        
        indicatorLightSlider?.value = CGFloat(exactly: NSNumber(integerLiteral: self.coreOneObject?.LEDSlider ?? 0)) ?? 0.0
        lightSensitivity(value: self.indicatorLightSlider?.value ?? 0, command: false)
        
        safetySlider?.value = CGFloat(exactly: NSNumber(integerLiteral: self.coreOneObject?.SafetySlider ?? 0)) ?? 0.0
        safetySensitivity(value: self.safetySlider?.value ?? 0, command: false)
        
        awaySlider?.value = CGFloat(exactly: NSNumber(integerLiteral: self.coreOneObject?.AwaySlider ?? 0)) ?? 0.0
        awayStatus(value: self.awaySlider?.value ?? 0)
        
        presenceSlider?.value = CGFloat(exactly: NSNumber(integerLiteral: self.coreOneObject?.SitPresence ?? 0)) ?? 0.0
        presenceSensitivity(value: self.presenceSlider?.value ?? 0, tag: presenceSlider?.tag ?? 3)
        
        presenceSliderStand?.value = CGFloat(exactly: NSNumber(integerLiteral: self.coreOneObject?.StandPresence ?? 0)) ?? 0.0
        presenceSensitivity(value: self.presenceSliderStand?.value ?? 0, tag: presenceSliderStand?.tag ?? 4)
        
    }
    
    func getAppState() {
        
        let email = Utilities.instance.getLoggedEmail()
        let realm = try! Realm(configuration: getRealmForUser(username: email))
        let state = realm.objects(UserAppStates.self).filter("Email = %@", email)
        
        guard state.count > 0 else {
            return
        }
        self.isAutomatic = state[0].AutomaticControls
        self.isLegacy = state[0].LegacyControls
        self.updatePrecenseDetection()
    }
    
    func saveUserAppState() {
        let email = Utilities.instance.getLoggedEmail()
        let realm = try! Realm(configuration: getRealmForUser(username: email))
        let state = realm.objects(UserAppStates.self).filter("Email = %@", email)
        
        guard state.count > 0 else {
            return
        }
        
        try! realm.write {
            state[0].LegacyControls = isLegacy
            state[0].AutomaticControls = isAutomatic
           realm.add(state, update: .modified)
           realm.refresh()
        }
    }
    
    func updatePrecenseDetection() {
        self.btnCapture?.isSelected = self.isAutomatic
        self.legacySwitch?.isOn = self.isLegacy
        self.hideShowLegacyView(show: !self.isLegacy)
        saveUserAppState()
    }
    
    func hideShowLegacyView(show: Bool) {
        
        self.viewSittingContainer?.isHidden = show
        self.viewStandingContainer?.isHidden = show
        
        saveUserAppState()
    }
    
    @objc func sliderValueChange(_ sender: TGPDiscreteSlider, event:UIEvent) {
        
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
                case .ended:
                    switch sender.tag {
                        case 0: // light
                            Threads.performTaskAfterDealy(1.0, {
                                self.lightSensitivity(value: sender.value, command: true)
                            })
                        case 1: // safety
                            lblSafetyValue?.text = String(format:"%.0f", sender.value)
                            Threads.performTaskAfterDealy(3.0, {
                                print("sliderValueChange value : ", sender.value)
                                self.safetySensitivity(value: sender.value, command: true)
                            })
                        case 2: //away
                            Threads.performTaskAfterDealy(1.0, {
                                self.awayStatus(value: sender.value)
                            })
                        case 3://sitting presence
                            Threads.performTaskAfterDealy(1.0, {
                                self.presenceSensitivity(value: sender.value, tag: sender.tag)
                            })
                        case 4://standing presence
                            
                            Threads.performTaskAfterDealy(1.0, {
                                self.presenceSensitivity(value: sender.value, tag: sender.tag)
                            })
                        default:
                            break
                    }
                default:
                    break
            }
        }
        
    }
    
    func lightSensitivity(value: CGFloat, command: Bool) {
        switch value {
        case 0:
            lblIndicatorValue?.text = "LOW"
        case 1:
            lblIndicatorValue?.text = "DIM"
        case 2:
            lblIndicatorValue?.text = "HIGH"
        default:
            lblIndicatorValue?.text = "LOW"
        }
        
        guard command else {
            return
        }
        
        self.setIndicatorLights(value: Int(indicatorLightSlider?.value ?? 0))
    }
    
    func awayStatus(value: CGFloat) {
         print("away values: ", value)
         lblAwayValue?.text = getAwayString(value: value) //String(format:"%.0f", value)
         setAwayStatusDelay(value: Int(value))
    }
    
    func getAwayString(value: CGFloat) -> String {
        switch value {
            case 1:
                return  "30 sec"
            case 2:
                return  "1 min"
            case 3:
                return  "3 min"
            case 4:
                return  "5 min"
            case 5:
                return  "10 min"
            default:
                return  "0 sec"
        }
    }
    
    func safetySensitivity(value: CGFloat, command: Bool) {
        lblSafetyValue?.text = String(format:"%.0f", value)
        
        guard safetyAlertShown == false else {
            return
        }
        
        if command {
            safetyAlertShown = true
            self.showAlert(title: "generic.notice".localize(),
               message: "box_controls.safety_alert".localize(),
               positiveText: "buttons.agree".localize(),
               negativeText: "buttons.cancel".localize(),
               success: {
                    //success
                    self.lblSafetyValue?.text = String(format:"%.0f", value)
                    self.setSafetySensitivty(value: Int(value), withCommand: command)
               }) {
                    self.safetyAlertShown = false
                    self.safetySlider?.value = CGFloat(exactly: NSNumber(integerLiteral: self.coreOneObject?.SafetySlider ?? 0)) ?? 0.0
                    if let _safety = self.safetyValue {
                        self.lblSafetyValue?.text = String(format: "%d", _safety)
                    }
                }
         }
    }
    
    func presenceSensitivity(value: CGFloat, tag: Int) {
        if tag == 3 {
            lblPresenceValue?.text = String(format:"%.0f", value)
            setPresenceSittingSensitivity(value: Int(value))
        } else {
            lblPresenceStandValue?.text = String(format: "%.0f", value)
            setPresenceStandingSensitivity(value: Int(value))
        }
    }
    
    @IBAction func onBtnAction(sender: UIButton) {
        
        switch sender.tag {
            case 0:
                if Int(indicatorLightSlider?.value ?? 0) > 0 {
                        indicatorLightSlider?.value -= 1
                        lightSensitivity(value: indicatorLightSlider?.value ?? 0, command: true)
                    
                }
            case 1:
                if Int(indicatorLightSlider?.value ?? 0) < 2 {
                    indicatorLightSlider?.value += 1
                    lightSensitivity(value: indicatorLightSlider?.value ?? 0, command: true)
                    
                }
            case 2:
                if Int(safetySlider?.value ?? 0) > 0 {
                        safetySlider?.value -= 1
                        safetySensitivity(value: safetySlider?.value ?? 0, command: true)
                }
            case 3:
                if Int(safetySlider?.value ?? 0) < 10 {
                        safetySlider?.value += 1
                        safetySensitivity(value: safetySlider?.value ?? 0, command: true)
                }
            case 4:
                if Int(awaySlider?.value ?? 0) > 0 {
                    awaySlider?.value -= 1
                    awayStatus(value: awaySlider?.value ?? 0)
                }
            case 5:
                if Int(awaySlider?.value ?? 0) < 5 {
                    awaySlider?.value += 1
                    awayStatus(value: awaySlider?.value ?? 0)
                }
            case 6:
                if Int(presenceSlider?.value ?? 0) > 0 {
                    presenceSlider?.value -= 1
                    presenceSensitivity(value: presenceSlider?.value ?? 0,tag: 3)
                }
            case 7:
                if Int(presenceSlider?.value ?? 0) < 10 {
                    presenceSlider?.value += 1
                    presenceSensitivity(value: presenceSlider?.value ?? 0, tag: 3)
                }
            case 8:
                if Int(presenceSliderStand?.value ?? 0) > 0 {
                    presenceSliderStand?.value -= 1
                    presenceSensitivity(value: presenceSliderStand?.value ?? 0,tag: 4)
                }
            case 9:
                if Int(presenceSliderStand?.value ?? 0) < 10 {
                    presenceSliderStand?.value += 1
                    presenceSensitivity(value: presenceSliderStand?.value ?? 0, tag: 4)
                }
        case 20:
            print("enable automatic")
            presenceIndicator(automatic: true, legacy: false, withCommand: true)
            
            break
        case 21:
            print("capture presence")
            self.requestPulseData(type: .NeedPresence)
            break
        default: break
        }
    }
    
    @IBAction func onBtnInvertActions(sender: AnyObject) {
        let flipStand = self.enableHeatSensingFlipStanding ?? false
        let flipSit = self.enableHeatSensingFlipSitting ?? false
        
        switch sender.tag {
            case 0:
                setPresenceInvert(inverted: flipSit, invertType: .SIT)
            case 1:
                setPresenceInvert(inverted: flipStand, invertType: .STAND)
            default:
            break
        }
    }
    
    func setIndicatorLights(value: Int) {
        // / 0 / 1 / 2
        
        let command = SPCommand.GetSetIndicatorLight(value: value)
        self.sendACommand(command: command, name: "SPCommand.GetSetIndicatorLight")
    }
    
    func setSafetySensitivty(value: Int, withCommand: Bool) {
        // 0 - 10
        self.safetyValue = value
        
        if withCommand {
            safetyAlertShown = false
            let command = SPCommand.GetSetCrushThreshold(value: value)
            self.sendACommand(command: command, name: "SPCommand.GetSetCrushThreshold")
        }
        
    }
    
    func setAwayStatusDelay(value: Int) {
        // 0 to 5
        
        let command = SPCommand.GetSetAwayAdjust(value: value)
        self.sendACommand(command: command, name: "SPCommand.GetSetAwayAdjust")
    }
    
    func setPresenceSittingSensitivity(value: Int) {
        // 0 to 10
        
        let command = SPCommand.GetSetPNDThreshold(value: value)
        self.sendACommand(command: command, name: "SPCommand.GetSetPNDThreshold")
    }
    
    func setPresenceStandingSensitivity(value: Int) {
        // 0 to 10
        
        let command = SPCommand.GetSetPNDStandThreshold(value: value)
        self.sendACommand(command: command, name: "SPCommand.GetSetPNDStandThreshold")
    }
    
    func setPresenceInvert(inverted: Bool, invertType: INVERT_TYPE) {
        
        var command = [UInt8]()
        //log.debug("inverted: \(inverted)")
        if invertType == .SIT {
            if inverted {
                command = SPCommand.GetPresenceNoInverted()
                self.enableHeatSensingFlipSitting = false
            } else {
                command = SPCommand.GetPresenceInverted()
                self.enableHeatSensingFlipSitting = true
            }
        } else {
            if inverted {
                command = SPCommand.GetPresenceStandNoInverted()
                self.enableHeatSensingFlipStanding = false
            } else {
                command = SPCommand.GetPresenceStandInverted()
                self.enableHeatSensingFlipStanding = true
            }
        }
        
        self.sendACommand(command: command, name: command.debugDescription)
        invertedStatusIndicators()
    }
    
    func presenceIndicator(automatic: Bool, legacy: Bool, withCommand: Bool) {
        
        self.legacySwitch?.isOn = legacy
        self.isLegacy = legacy
        self.hideShowLegacyView(show: !legacy)
        self.btnCapture?.isSelected = automatic
        self.isAutomatic = automatic
        //log.debug("is automatic detection:\(String(describing: isAutomaticPresence))")
        
        if legacy {
            btnCapture?.setTitle("Automatic", for: .normal)
            btnCapture?.tag = 20
            //log.debug("enable legacy request")
        }
        
        if automatic {
            btnCapture?.setTitle("Capture", for: .normal)
            btnCapture?.setTitle("Capture", for: .selected)
            btnCapture?.tag = 21
            //log.debug("enable automatic and submit capture request")
        }
        
        
        guard withCommand else {
            
            return
        }
        
        if legacy {
            self.requestPulseData(type: .LegacyDetection)
               }
        
        if automatic {
            self.requestPulseData(type: .AutoPresence)
            
            Threads.performTaskAfterDealy(1) {
                self.requestPulseData(type: .NeedPresence)
            }
        }
    }
    
    func invertedStatusIndicators() {
        let flipStand = self.enableHeatSensingFlipStanding ?? false
        let flipSit = self.enableHeatSensingFlipSitting ?? false
        
        self.sittingSwitch?.isOn = flipSit
        self.standingSwitch?.isOn = flipStand
        
        if flipSit {
            Utilities.instance.invertSittingThreshold = 100 + (self.coreOneObject?.SitPresence ?? 0 * 15)
        } else {
            Utilities.instance.invertSittingThreshold = 70 + ((10 - (self.coreOneObject?.SitPresence ?? 0) * 15))
        }
        
        if flipStand {
            Utilities.instance.invertStandingThreshold = 100 + (self.coreOneObject?.StandPresence ?? 0 * 15)
        } else {
            Utilities.instance.invertStandingThreshold = 70 + ((10 - (self.coreOneObject?.StandPresence ?? 0) * 15))
        }
        
        
        btnFunctionInvertedSitting?.setImage(flipSit ? UIImage.fontAwesomeIcon(name: .check,
                                                                                  style: .solid,
                                                                                  textColor: UIColor(hexString: Constants.smartpods_blue),
                                                                                  size: CGSize(width: 30, height: 30)): nil , for: .normal)
        
        btnFunctionInvertedStanding?.setImage(flipStand ? UIImage.fontAwesomeIcon(name: .check,
                                                                                  style: .solid,
                                                                                  textColor: UIColor(hexString: Constants.smartpods_blue),
                                                                                  size: CGSize(width: 30, height: 30)): nil , for: .normal)
    }
    
    @IBAction func onBtnLegacyDetection(sender: UISwitch) {
        
        if sender.isOn {
            presenceIndicator(automatic: false, legacy: true, withCommand: true)
        } else {
            presenceIndicator(automatic: true, legacy: false, withCommand: true)
        }
 
    }
}

extension TGPDiscreteSlider {
    public convenience init() { self.init() }
}


extension BoxControlController: SPBluetoothManagerDelegate {
    func updateInterface() {
        
    }
    
    func deviceConnected() {
        
    }
    
    func updateDeviceConnectivity(connect: Bool) {
        
    }
    
    func connectivityState(title: String, message: String, code: Int) {
        
    }
    
    func unableToPairWithBox() {
        
    }

}
