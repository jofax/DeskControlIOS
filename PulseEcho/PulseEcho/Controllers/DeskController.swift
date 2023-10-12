//
//  DeskController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-24.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import FontAwesome_swift
import EventCenter
import SwiftEventBus

class DeskController: BaseController {

    //STORYBOARD OUTLETS
    @IBOutlet weak var viewUp: UIView?
    @IBOutlet weak var viewDown: UIView?
    @IBOutlet weak var btnUp: UIButton?
    @IBOutlet weak var btnDown: UIButton?
    @IBOutlet weak var lblCurrentHeight: UILabel?
    @IBOutlet weak var lblHeightValue: UILabel?
    @IBOutlet weak var btnStand: CustomButtonWithShadow?
    @IBOutlet weak var btnSit: CustomButtonWithShadow?
    @IBOutlet weak var lblStand: UILabel?
    @IBOutlet weak var lblSit: UILabel?
    @IBOutlet weak var btnSetStand: UIButton?
    @IBOutlet weak var btnSetSit: UIButton?
    @IBOutlet weak var sitStandImageView: UIImageView?
    
    @IBOutlet weak var upArrowView: UIView?
    @IBOutlet weak var downArrowView: UIView?
    
    let commandTimer = SPTimeScheduler(timeInterval: 0.1)
    var deskSequence = DeskSequence.None
    var commandSequence: Timer?
    
    var sitTimerStarted = false
    var standTimerStarted = false
    let sitAnimateTimer = SPTimeScheduler(timeInterval: 0.15)
    let standAnimateTimer = SPTimeScheduler(timeInterval: 0.15)
    
    //CLASS VARIABLES
    var viewModel: ProfileSettingsViewModel?
    var currentHeight: Int = 0
    var standHeight: Int = 0
    var sittingHeight: Int = 0
    var sittingHeightTruncated: Bool = false
    var standHeightTruncated: Bool = false
    var profileRawString = ""
    
    var standingImages =  [UIImage()]
    var sittingImages =  [UIImage()]
    var deskImages = [UIImage()]
    var movesReported: Int = 0
    var lastIndex: Int = 0
    var startImageIndex = 0
    
    var timer: Timer?
    var animateTimer: Timer?
    var upButtonNoOfTaps: Int = 0
    var downButtonNoOfTaps: Int = 0
    var userProfileSettings = ProfileSettings(params: [String : Any]())
    
    var standCommandPressCount: Int = 0
    var sitCommandPressCount: Int = 0
    
    var stopCommandPressCount: Int = 0
    var boxIdentifier: SPIdentifier?
    let  sittingProccess = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let email = Utilities.instance.getUserEmail()
        SPBluetoothManager.shared.event = self.event
        createCustomNavigationBar(title: "deskHeight.title".localize(), user: email, cloud: true, back: false, ble: true)
        customizeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        standAnimateTimer.suspend()
        sitAnimateTimer.suspend()
        requestBoxData()
        getProfileSettings()
        print("boxControlViewOpen: ", boxControlViewOpen)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.requestPulseData(type: .Profile)
        //requestBoxData()
        //getProfileSettings()
    }
    
    override func customizeUI() {
        viewUp?.roundCorners([.layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 30)
        viewDown?.roundCorners([.layerMinXMinYCorner, .layerMinXMaxYCorner], radius: 30)
        
        lblCurrentHeight?.text = "deskHeight.current_height".localize()
        btnStand?.titleLabel?.text = "deskHeight.stand_title".localize()
        btnSit?.titleLabel?.text = "deskHeight.sit_title".localize()
        
//        btnUp?.setBackgroundColor(color: .clear, forState: .normal)
//        btnUp?.setBackgroundColor(color: .red, forState: .highlighted)
//        btnDown?.setBackgroundColor(color: .clear, forState: .normal)
//        btnDown?.setBackgroundColor(color: .red, forState: .highlighted)
//
        
        
//        btnSetStand?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
//        btnSetStand?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
//        btnSetStand?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .selected)
//
//        btnSetSit?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
//        btnSetSit?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
//        btnSetSit?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .selected)
        
        lblCurrentHeight?.adjustContentFontSize()
        lblHeightValue?.adjustNumberFontSize()
        btnStand?.titleLabel?.adjustContentFontSize()
        btnSit?.titleLabel?.adjustContentFontSize()
        lblStand?.adjustNumberFontSize()
        lblSit?.adjustNumberFontSize()
        
        setUpButtonGesture(enable: true)

        // Need to unregister event listener to avoid duplicate data stream
        SwiftEventBus.unregister(self, name: ViewEventListenerType.DeskDataStream.rawValue)
        
        commandTimer.eventHandler = {
            if LOGS.BUILDTYPE.boolValue == false {
                print("commandTimer timer Scheduler Fired | info: \(Utilities.instance.loginfo())")
            } else {
                print("commandTimer timer Scheduler Fired | info: \(Utilities.instance.loginfo())")
            }
            
            if let peripheral = SPBluetoothManager.shared.state.peripheral {
                
                guard peripheral.spDesiredService != nil else {
                    self.commandTimer.suspend()
                    self.deskSequence = .None
                    return
                }
                
                
                if self.deskSequence == .DeskUp {
                    self.moveDeskUp(stop: false)
                }
                
            } else {
                self.commandTimer.suspend()
                self.deskSequence = .None
            }
        }
        
        sitAnimateTimer.eventHandler = {
            self.animateSitAndStand(type: .DOWN)
        }
        
        standAnimateTimer.eventHandler = {
            self.animateSitAndStand(type: .UP)
        }
        
        SwiftEventBus.onMainThread(self, name: ViewEventListenerType.DeskDataStream.rawValue) { [weak self] result in
            let obj = result?.object
            
            
            /**** CoreOne Data ****/
            if obj is SPCoreObject {
                let _core = obj as? SPCoreObject
                self?.lblHeightValue?.text = String(format: "%d", _core?.ReportedVertPos ?? "0")
                
                self?.currentHeight = _core?.ReportedVertPos ?? 0
                self?.movesReported = _core?.NextMove ?? 4
                
                if self?.sittingHeightTruncated != _core?.SitHeightAdjusted {
                    self?.sittingHeightTruncated = _core?.SitHeightAdjusted ?? false
                }
                
                if self?.standHeightTruncated != _core?.StandHeightAdjusted {
                    self?.standHeightTruncated = _core?.StandHeightAdjusted ?? false
                }
                
                
                let moveUpStatus = _core?.Movingupstatus ?? false
                let moveDownStatus =  _core?.Movingdownstatus ?? false
                
                //print("desk control moveUpStatus: \(moveUpStatus)")
                //print("desk control moveDownStatus: \(moveDownStatus)")
                
                if moveUpStatus {
                    if (self?.standTimerStarted == false) {
                        self?.sitTimerStarted = false
                        self?.sitAnimateTimer.suspend()

                        self?.standTimerStarted = true
                        self?.standAnimateTimer.resume()
                        
                        print("deks control moveUpStatus")
                        
                    }
                } else if moveDownStatus {
                    
                    if (self?.sitTimerStarted == false) {
                        self?.standTimerStarted = false
                        self?.standAnimateTimer.suspend()

                        self?.sitTimerStarted = true
                        self?.sitAnimateTimer.resume()
                        
                        print("deks control moveDownStatus")
                    }
                    
                    
                } else {
                    self?.sitTimerStarted = false
                    self?.standTimerStarted = false
                    self?.sitAnimateTimer.suspend()
                    self?.standAnimateTimer.suspend()
                }
            }
            
            /***************************************************************************************/
            
            /**** BoxHeight Data ****/
            
            if obj is SPVerticalProfile {
                let heightObject = obj as? SPVerticalProfile
                
                //log.debug("profile string: \(heightObject?.movementRawString)")
                self?.profileRawString = heightObject?.movementRawString ?? ""
                
                print("user sit height: \(heightObject?.SittingPos)")
                print("user stand height: \(heightObject?.StandingPos)")
                
                print("DeskDataStream profile")
                
                
                self?.standHeight = heightObject?.StandingPos ?? 0
                self?.sittingHeight = heightObject?.SittingPos ?? 0
                self?.generateImageFrames()
                
                if (PulseDataState.instance.sittingHeightTruncated ||  PulseDataState.instance.standHeightTruncated) {
                    self?.lblSit?.text = String(format: "%d",heightObject?.SittingPos ?? 0)
                    self?.lblStand?.text = String(format:"%d", heightObject?.StandingPos ?? 0)
                }
                
            }
            
            /*********************************************************************************************/
           
           /** Identifier Data **/
           
           if obj is SPIdentifier {
               let boxInformation = obj as? SPIdentifier
               if self?.boxIdentifier == nil {
                   self?.boxIdentifier = boxInformation
                   
                   if Utilities.instance.compareAndUpdateSerial(serial: boxInformation?.SerialNumber ?? "") == false {
                       Utilities.instance.saveDefaultValueForKey(value: String(format: "%@",boxInformation?.SerialNumber ?? ""), key: "serialNumber")
                       Utilities.instance.saveDefaultValueForKey(value: String(format: "%@",boxInformation?.RegistrationID ?? ""), key: "registrationID")
                       self?.updateDeviceConnectStatus(serial: boxInformation?.SerialNumber ?? "",registration: boxInformation?.RegistrationID ?? "" ,connected: true)
                   }
                   
               } else {
                   if self?.boxIdentifier?.SerialNumber != boxInformation?.SerialNumber {
                       
                       if Utilities.instance.compareAndUpdateSerial(serial: boxInformation?.SerialNumber ?? "") == false {
                           Utilities.instance.saveDefaultValueForKey(value: String(format: "%@",boxInformation?.SerialNumber ?? ""), key: "serialNumber")
                           Utilities.instance.saveDefaultValueForKey(value: String(format: "%@",boxInformation?.RegistrationID ?? ""), key: "registrationID")
                           self?.updateDeviceConnectStatus(serial: boxInformation?.SerialNumber ?? "",registration: boxInformation?.RegistrationID ?? "", connected: true)
                       }
                   }
               }
            
            self?.getProfileSettings()
           }
            
        }
        
    }
    
    override func bindViewModelAndCallbacks() {
        self.viewModel = ProfileSettingsViewModel()
        
        viewModel?.forceLogout = { [weak self] () in
            self?.logoutUser(useGuest: false)
        }
        
        viewModel?.alertMessage = { [weak self](title: String, message: String, tag: Int) in
            
                if tag == 4 {
                   self?.showAlert(title: title, message: message, tapped: {
                       self?.logoutUser(useGuest: false)
                   })
                } else if tag == 5 {
                       self?.showAlert(title: title,
                                      message: message,
                                      positiveText: "common.yes".localize(),
                                      negativeText: "common.no".localize(),
                                      success: {
                                       
                                       self?.logoutUser(useGuest: true)
                                       
                                       },
                                      cancel: {
                                       SPBluetoothManager.shared.disconnect(forget: false)
                       })
                   } else {
                       
                       self?.displayStatusNotification(title: message, style: .danger)
                   }
            
        }

        viewModel?.showIndicator = { [weak self] (show: Bool) in
            self?.showActivityIndicator(show: show)
        }
        
        viewModel?.apiCallback = { [weak self] (_ response : Any, _ status: Int) in
            if status == 6 {
                self?.showAlertWithAction(title: "generic.notice".localize(),
                                          message: "generic.invalid_session".localize(),
                                          buttonTitle: "common.ok".localize(), buttonAction: {
                                            self?.logoutUser(useGuest: false)
                                          })
            }
        }
    }
    
    func setUpButtonGesture(enable: Bool) {
        if enable {
            let upTapGesture = UITapGestureRecognizer(target: self, action: #selector (handleUpTapPress(gesture:)))
            let downTapGesture = UITapGestureRecognizer(target: self, action: #selector (handleDownTapPress(gesture:)))
            
            let upLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleUpLongPress(gestureReconizer:)))
            upLongGesture.numberOfTouchesRequired = 1
            upLongGesture.allowableMovement = 60
            
            //upLongGesture.allowableMovement = 50
            upArrowView?.addGestureRecognizer(upLongGesture)
            
            let downLongGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleDownLongPress(gestureReconizer:)))
            downLongGesture.numberOfTouchesRequired = 1
            downLongGesture.allowableMovement = 60
            downArrowView?.addGestureRecognizer(downLongGesture)
            
        } else {
            //upArrowView?.gestureRecognizers?.removeAll()
            //downArrowView?.gestureRecognizers?.removeAll()
        }
    }
    
    func requestBoxData() {
        getSavedUserProfile()
        self.requestPulseData(type: .Profile)
        self.requestPulseData(type: .Info)
    }
    
    func getSavedUserProfile() {
        
        guard Utilities.instance.typeOfUserLogged() != .None else {
            return
        }
        
        let dataHelper = SPRealmHelper()
        let email = Utilities.instance.getLoggedEmail()
        
        do {
            let vm = try dataHelper.getPulseDevice(email)
            
            guard !vm.UserProfile.isEmpty else {
                self.requestPulseData(type: .Profile)
                return
            }
            
            let profile = vm.UserProfile.hexaBytes
            let verticalMovementProfile = SPVerticalProfile(data: profile, rawString: vm.UserProfile, notify: false)
            
            if Utilities.instance.typeOfUserLogged() == .Guest {
                //log.debug("verticalMovementProfile guest : \(verticalMovementProfile)")
                if (verticalMovementProfile.SittingPos == 0) {
                    self.lblSit?.text = String(format: "%d",Constants.defaultSittingPosition )
                    
                } else {
                    self.lblSit?.text = String(format: "%d",verticalMovementProfile.SittingPos )
                    
                }
                
                if (verticalMovementProfile.StandingPos == 0) {
                    self.lblStand?.text = String(format:"%d", Constants.defaultStandingPosition)
                } else {
                    self.lblStand?.text = String(format:"%d", verticalMovementProfile.StandingPos)
                }
                
            }
            
            self.standHeight = verticalMovementProfile.StandingPos
            self.sittingHeight = verticalMovementProfile.SittingPos
            
            
        } catch {
            print("Realm getPulseDevice error | info: \(Utilities.instance.loginfo())")
        }
    }
    
    func getProfileSettings() {
        guard !Utilities.instance.isGuest else {
            requestProfileObject()
            return
        }
        
        if SPDeviceConnected() {
            if (PulseDataState.instance.sittingHeightTruncated ||  PulseDataState.instance.standHeightTruncated) {
                    print("getProfileSettings truncated should check with the box")
                self.requestPulseData(type: .Profile)
            } else {
                print("getProfileSettings not truncated")
                requestProfileObject()
            }
            
        } else {
            requestProfileObject()
        }
        
        let reachable = reachability?.isReachable ?? false
        if  reachable{
           refreshProfileSettings()
        } else {
          requestProfileObject()
        }
    }
    
    func refreshProfileSettings() {
        
        viewModel?.getProfileSettings(completion: { [weak self] object in
            // refresh data
            self?.userProfileSettings = object
            
            if (PulseDataState.instance.sittingHeightTruncated ||  PulseDataState.instance.standHeightTruncated) {
                self?.lblSit?.text = String(format: "%d",self?.sittingHeight ?? object.SittingPosition)
                self?.lblStand?.text = String(format:"%d", self?.standHeight ?? object.SittingPosition)
            } else {
                self?.lblSit?.text = String(format: "%d",object.SittingPosition)
                self?.lblStand?.text = String(format:"%d", object.StandingPosition)
            }
            
            
            if object.StandingPosition == 0 || object.SittingPosition == 0 {
                self?.requestProfileObject()
            }
        })
    }
    
    func requestProfileObject() {
        
        viewModel?.getLocalUserProfileInformation(email: Utilities.instance.getLoggedEmail() ,completion: { [weak self] object in
            self?.userProfileSettings = object
            
            if (PulseDataState.instance.sittingHeightTruncated ||  PulseDataState.instance.standHeightTruncated) {
                self?.lblSit?.text = String(format: "%d",self?.sittingHeight ?? object.SittingPosition)
                self?.lblStand?.text = String(format:"%d", self?.standHeight ?? object.SittingPosition)
            } else {
                self?.lblSit?.text = String(format: "%d",object.SittingPosition)
                self?.lblStand?.text = String(format:"%d", object.StandingPosition)
            }
            
            
            
            self?.generateImageFrames()
        })
    }
    
    @objc func handleUpTapPress(gesture: UITapGestureRecognizer) {
        print("handleUpTapPress state: ", gesture.state.rawValue)
        
        if SPDeviceConnected() {
            self.viewUp?.backgroundColor = UIColor(hexString: Constants.smartpods_green)
            self.btnUp?.isHighlighted = true
            if standCommandPressCount == 0 {
                self.moveDeskUp(stop: true)
            }

        }
    }
    
    @objc func handleUpLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        print("handleUpLongPress state: ", gestureReconizer.state.rawValue)
        
        if gestureReconizer.state == .changed{
            print("standCommandPressCount: ", standCommandPressCount)
            
            if standCommandPressCount == 0 {
                standCommandPressCount = 1
                print("gesture started should execute command up")
                self.btnUp?.isSelected = true
                    
                if SPDeviceConnected() {
                    self.viewUp?.backgroundColor = UIColor(hexString: Constants.smartpods_green)
                    self.moveDeskUp(stop: false)
                    
                    animateTimer =  Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
                        guard let _ = self.animateTimer
                           else { return }
                        self.animateSitAndStand(type: .UP)
                    }
                }
            } else {
                print("long gesture calling up desk : \(standCommandPressCount)")
                self.startCommandTimer()
            }
            
        } else if  gestureReconizer.state == UIGestureRecognizer.State.ended ||
                    gestureReconizer.state == UIGestureRecognizer.State.cancelled ||
                    gestureReconizer.state == UIGestureRecognizer.State.failed {
                
                stopDeskMovement()
                standCommandPressCount = 0
                print("gesture ended should stop command")
                animateTimer?.invalidate()
                btnUp?.isSelected = false
        }
    }
    
    @objc func handleDownTapPress(gesture: UITapGestureRecognizer) {
        print("handleDownTapPress: ", gesture.state.rawValue)
        if SPDeviceConnected() {
            if standCommandPressCount == 0 {
                self.viewDown?.backgroundColor = UIColor(hexString: Constants.smartpods_green)
                self.moveDeskDown(stop: true)
                self.btnDown?.isHighlighted = true
            } else {
                self.btnDown?.isHighlighted = false
            }

        }
    }
    
    @objc func handleDownLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        print("handleDownLongPress state: ", gestureReconizer.state.rawValue)
        if gestureReconizer.state == UIGestureRecognizer.State.changed {
            if sitCommandPressCount == 0 {
                sitCommandPressCount = 1
                print("gesture started should execute command down")
                 self.btnDown?.isHighlighted = true
                if SPDeviceConnected() {
                    self.viewDown?.backgroundColor = UIColor(hexString: Constants.smartpods_green)
                    self.moveDeskDown(stop: false)
                    
                    animateTimer =  Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (_) in
                        guard let _ = self.animateTimer
                           else { return }
                        self.animateSitAndStand(type: .DOWN)
                    }
                }
            } else {
                print("calling down desk : \(sitCommandPressCount)")
                self.startCommandTimer()
            }
        } else if  gestureReconizer.state == UIGestureRecognizer.State.ended ||
                        gestureReconizer.state == UIGestureRecognizer.State.cancelled ||
                        gestureReconizer.state == UIGestureRecognizer.State.failed {
            
            stopDeskMovement()
            sitCommandPressCount = 0
            animateTimer?.invalidate()
            self.btnDown?.isHighlighted = false
        }

    }
    
    @objc func runStackCommand() {
        print("runStackCommand executed")
        if let peripheral = SPBluetoothManager.shared.state.peripheral {

            guard peripheral.spDesiredService != nil else {
                self.commandTimer.suspend()
                self.deskSequence = .None
                return
            }


            if self.deskSequence == .DeskUp {
                self.moveDeskUp(stop: false)
            }
            
            if self.deskSequence == .DeskDown {
                self.moveDeskDown(stop: false)
            }

        } else {
            self.commandTimer.suspend()
            self.deskSequence = .None
            self.stopCommandTimer()
        }
    }
    
    func startCommandTimer() {
        if commandSequence != nil {
            if let _timerActive = commandSequence?.isValid {
                print("_timerActive: \(_timerActive)")
                if !_timerActive {
                    commandSequence = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(runStackCommand), userInfo: nil, repeats: true)
                }
            }
        } else {
            commandSequence = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(runStackCommand), userInfo: nil, repeats: true)
        }
    }
    
    func stopCommandTimer() {
        if commandSequence != nil {
            commandSequence?.invalidate()
        }
    }
    
    @IBAction func onBtnActions(sender: UIButton) {
        sender.isHighlighted = true
        switch sender.tag {
            case 0:
                moveDeskUp(stop: true)
            case 1:
                moveDeskDown(stop: true)
            case 2:
                if SPDeviceConnected() {
                    btnSetStand?.isSelected = true
                    updateStandingPosition()
                }
            case 3:
                if SPDeviceConnected() {
                    btnSetSit?.isSelected = true
                    updateSittingPosition()
                }
            default:
                break
        }
    }
    
    @IBAction func onBtnStopActions(sender: UIButton) {
        sender.isHighlighted = false
        stopDeskMovement()
    }
    
    func moveDeskUp(stop: Bool) {
        if SPDeviceConnected() {
            let _command = SPCommand.GetMoveUpCommand()
            self.sendACommand(command: _command, name: "SPCommand.GetMoveUpCommand")
            //animateSitAndStand(type: .UP)
            DispatchQueue.main.async {
                self.btnUp?.isHighlighted = false
            }
            
            //print("onBtnActions GetMoveUpCommand")
            self.deskSequence = .DeskUp
            self.commandTimer.suspend()
            
            if stop {
                self.stopDeskMovement()
            }
        }
    }
    
    func moveDeskDown(stop: Bool) {
        if SPDeviceConnected() {
            let _command = SPCommand.GetMoveDownCommand()
            self.sendACommand(command: _command, name: "SPCommand.GetMoveDownCommand")
            //animateSitAndStand(type: .DOWN)
            DispatchQueue.main.async {
                self.btnDown?.isHighlighted = false
            }
            self.deskSequence = .DeskDown
            self.commandTimer.suspend()
            //print("onBtnActions GetMoveDownCommand")
            //animateSitAndStand(type: .DOWN)
            
            if stop {
               self.stopDeskMovement()
            }
        }
    }
    
    func stopDeskMovement() {
        //print("stopDeskMovement")
        let command = SPCommand.GetStopCommand()
        self.sendACommand(command: command, name: "SPCommand.GetStopCommand")
        
        self.standCommandPressCount = 0
        self.sitCommandPressCount = 0
        self.deskSequence = .None
        self.commandTimer.suspend()
        self.stopCommandTimer()
        
        btnUp?.isSelected = false
        btnDown?.isHighlighted = false
        self.viewUp?.backgroundColor = UIColor(hexString: Constants.smartpods_blue)
        self.viewDown?.backgroundColor = UIColor(hexString: Constants.smartpods_blue)
        
    }
    
    func animateSitAndStand(type: MovementType) {
        let _img_srt  = String(format: "NewDeskRaising_%d", startImageIndex)
        //print("_img_srt: ", _img_srt)
        
        
        
        if type == .UP {
            if startImageIndex <= deskImages.count {
                DispatchQueue.main.async {
                    guard (self.deskImages.item(at: self.startImageIndex) != nil) else { return }
                    self.sitStandImageView?.image = self.deskImages[self.startImageIndex] //UIImage(named: _img_srt)
                    
                    if self.startImageIndex < self.deskImages.count {
                        self.startImageIndex += 1
                    }
                    
                }
            }
            
        }
        
        if type == .DOWN {
            if startImageIndex <= deskImages.count {
                DispatchQueue.main.async {
                    
                    if (self.startImageIndex != 0) {
                        self.startImageIndex -= 1
                    }
                    
                    guard (self.deskImages.item(at: self.startImageIndex) != nil) else { return }
                    
                    self.sitStandImageView?.image = self.deskImages[self.startImageIndex]  //UIImage(named: _img_srt)
                    
                    if (self.currentHeight < self.sittingHeight) {
                        self.sitStandImageView?.image = self.deskImages[0]
                    }
                    
                }
            }
        }
    }
    
    func generateImageFrames() {
        deskImages.removeAll()
        let frames = (self.standHeight - self.sittingHeight) / 18
        var starterImgIndex = 4
        let endImgIndex = 21
        let perImage = (frames / 18) + 2
        
        for _ in 0...frames {
            if starterImgIndex != endImgIndex {
                for i in 0...perImage {
                    let _img_srt  = String(format: "NewDeskRaising_%d", starterImgIndex)
                    let _img = UIImage(named: _img_srt)!
                    deskImages.append(_img)
                    if (i == perImage) {
                        starterImgIndex += 1
                    }
               }
               
            }
        }
        
        let sitImgFrames: [UIImage] = [UIImage(named: "NewDeskRaising_0")!,
                                       UIImage(named: "NewDeskRaising_1")!,
                                       UIImage(named: "NewDeskRaising_2")!,
                                       UIImage(named: "NewDeskRaising_3")!]
        let standImgFrames = [UIImage(named: "NewDeskRaising_22")!,
                              UIImage(named: "NewDeskRaising_22")!,
                              UIImage(named: "NewDeskRaising_23")!,
                              UIImage(named: "NewDeskRaising_24")!]
        
        deskImages.insert(contentsOf: sitImgFrames, at: 0)
        deskImages.insert(contentsOf: standImgFrames, at: deskImages.count)
        
        if (currentHeight >= self.standHeight) {
            self.startImageIndex = deskImages.count - 1
        }
        
        if currentHeight <= self.sittingHeight {
            self.startImageIndex = 0
        }
        
        if (currentHeight > sittingHeight && currentHeight < standHeight) {
            //self.startImageIndex = (deskImages.count / 2) - 2
        }
        
        print("deskImages : \(deskImages.count)")
        
    }
    
    func checkForTruncatedSitAndStandHeights(tag: Int) {
        let updateSittingHeight = (PulseDataState.instance.sittingHeight != PulseDataState.instance.currentHeight) && PulseDataState.instance.sittingHeightTruncated
        let updateStandHeight = (PulseDataState.instance.standHeight != PulseDataState.instance.currentHeight) && PulseDataState.instance.standHeightTruncated
        if updateStandHeight || updateSittingHeight {
            //self.userProfileSettings = PulseDataState.instance.adjustSittingAndStandHeights(profile: self.userProfileSettings)
            
            //showAlert(title: "generic.notice".localize(), message:"generic.desk_adjusted".localize())
        }
        
        if (tag == 0 && PulseDataState.instance.sittingHeightTruncated) {
            self.showAlert(title: "generic.notice".localize(), message: "deskHeight.sit_height_adjusted".localize())
        } else if (tag == 1 && PulseDataState.instance.standHeightTruncated)  {
            self.showAlert(title: "generic.notice".localize(), message: "deskHeight.stand_height_adjusted".localize())
        }
    }
    
    func updateSittingPosition() {
        let newSitOffset = self.currentHeight
        let currentStand = self.standHeight
        let diff = abs(currentStand - newSitOffset)
        
        Threads.performTaskAfterDealy(1) {
            self.btnSetSit?.isSelected = false
        }
        
        if currentStand < newSitOffset {
            let message = "deskHeight.set_sitting_error".localize()
            self.showAlert(title: "generic.information".localize(), message: message)
           return
        }
        
        //default values
        
        //stand = 1100
        //sit = 730
        
        if (diff < Constants.sitStandDifference * 10) {
            let _difference = Constants.sitStandDifference * 10
             let message = String(format:"The difference between sitting and standing must be greater than %d (MM)",_difference)
             self.showAlert(title: "generic.information".localize(), message: message)
            return
        }
        let command = SPCommand.GetSetDownCommand(value: Double(newSitOffset))
        self.sendACommand(command: command, name: "SPCommand.GetSetDownCommand(value: \(Double(newSitOffset))")
        
        
        print("sitting truncated: \(self.sittingHeightTruncated)")
        
        Threads.performTaskAfterDealy(1.0) {
            if (self.sittingHeightTruncated) {
                self.checkForTruncatedSitAndStandHeights(tag: 0)
                Threads.performTaskAfterDealy(0.5) {
                    self.requestPulseData(type: .Profile)
                    self.syncronizeSittingHeight(height: self.sittingHeight)
                }
            } else {
                self.syncronizeSittingHeight(height: newSitOffset)
            }
        }
    }
    
    func syncronizeSittingHeight(height: Int) {
        guard Utilities.instance.typeOfUserLogged() != .None else {
            return
        }
        
        let dataHelper = SPRealmHelper()
        let email = Utilities.instance.getLoggedEmail()
        let _newSitOffset = height
        
        self.userProfileSettings =  dataHelper.updateUserProfileSettings(["SittingPosition": _newSitOffset], email)
           
        guard Utilities.instance.typeOfUserLogged() == .Cloud else {
            return
        }
        
        self.viewModel?.requestUpdateProfileSettings(self.userProfileSettings.generateProfileParameters()) { data in
            let result = ProfileSettings(params: data)
            self.requestPulseData(type: .Profile)
            
            if (self.sittingHeightTruncated == false) {
                self.lblSit?.text = String(format: "%d",result.SittingPosition)
            }
        }
        
    }
    
    
    func updateStandingPosition() {
        let newStandOffset = self.currentHeight
        let currentSit = self.sittingHeight
        let diff = abs(newStandOffset - currentSit)
        
        Threads.performTaskAfterDealy(1) {
            self.btnSetStand?.isSelected = false
        }
        
        print("(self.currentHeight < standHeight)", (self.currentHeight < standHeight))
        print("self.currentHeight > currentSit:", (self.currentHeight > currentSit))
        print("updateStandingPosition:", (self.currentHeight > currentSit) && (self.currentHeight < standHeight))
        
        if (self.currentHeight < currentSit) {
            let message = "deskHeight.set_standing_error".localize()
            self.showAlert(title: "generic.information".localize(), message: message)
           return
        }
        
        if (diff < Constants.sitStandDifference * 10) {  //10 in mm
            let _difference = Constants.sitStandDifference * 10
            let message = String(format:"The difference between sitting and standing must be greater than %d (MM)",_difference)
            self.showAlert(title: "generic.information".localize(), message: message)
           return
        }
        
        let command = SPCommand.GetSetTopCommand(value: Double(newStandOffset))
        self.sendACommand(command: command, name: "SPCommand.GetSetTopCommand")
        
        print("standing truncated: \(self.standHeightTruncated)")
        
        Threads.performTaskAfterDealy(1.0) {
            if (self.standHeightTruncated) {
                self.checkForTruncatedSitAndStandHeights(tag: 1)
                Threads.performTaskAfterDealy(0.5) {
                    self.requestPulseData(type: .Profile)
                    self.syncronizeStandinggHeight(height: self.standHeight)
                }
            } else {
                self.syncronizeStandinggHeight(height: newStandOffset)
            }
        }
         
    }
    
    func syncronizeStandinggHeight(height: Int) {
        let dataHelper = SPRealmHelper()
        let email = Utilities.instance.getLoggedEmail()
        var _newStandOffset = height
        
        self.userProfileSettings =  dataHelper.updateUserProfileSettings(["StandingPosition":_newStandOffset], email)

        guard Utilities.instance.typeOfUserLogged() == .Cloud else {
            return
        }
        self.viewModel?.requestUpdateProfileSettings(self.userProfileSettings.generateProfileParameters()) { data in
            let result = ProfileSettings(params: data)
            self.requestPulseData(type: .Profile)
            
            if (self.standHeightTruncated == false) {
                self.lblStand?.text = String(format:"%d", result.StandingPosition)
            }
        }
        
    }

}
