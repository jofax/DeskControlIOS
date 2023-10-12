//
//  ActivityProfileController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-22.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
//import RLBAlertsPickers
import FontAwesome_swift
import Device
import SwiftEventBus
import UICircularProgressRing

protocol ActivityProfileControllerDelegate {
    func activityProfileRedirectToHome()
}

class ActivityProfileController: BaseController {

    //STORYBOARD OUTLETS
    
    @IBOutlet weak var contentScroll: UIScrollView?
    @IBOutlet weak var viewContent: UIView?
    @IBOutlet weak var contentStack: UIStackView?
    
    @IBOutlet weak var lblPreset: PaddedLabel?
    @IBOutlet weak var btnFive: UIButton?
    @IBOutlet weak var btnFifteen: UIButton?
    @IBOutlet weak var btnThirty: UIButton?
    @IBOutlet weak var lblSecondEdit: PaddedLabel?
    @IBOutlet weak var btnSecondEdit: UIButton?
    @IBOutlet weak var lblFirstEdit: PaddedLabel?
    @IBOutlet weak var btnFirstEdit: UIButton?
    @IBOutlet weak var lblMinutes: PaddedLabel?
    @IBOutlet weak var lblStandDuration: PaddedLabel?
    @IBOutlet weak var btnDuration: UIButton?
    @IBOutlet weak var btnThirtyByThirty: CustomButtonWithShadow?
    @IBOutlet weak var btnSixty: CustomButtonWithShadow?
    @IBOutlet weak var lblMinutedDuration: PaddedLabel?
    @IBOutlet weak var presetView: PresetTimeDurationCircle?
    
    @IBOutlet weak var durationView: UIView?
    @IBOutlet weak var customizationView: UIView?
    
    @IBOutlet weak var imgEditBg: UIImageView?
    
    @IBOutlet weak var customCircleDuration: PresetTimeDurationCircle?
    @IBOutlet weak var stackSecondEdit: UIStackView?
    @IBOutlet weak var btnHealthy: CustomButtonWithShadow?
    @IBOutlet weak var stackFirstEdit: UIStackView?
    
    @IBOutlet weak var lblSitIndicator: UILabel?
    @IBOutlet weak var lblStandIndicator: UILabel?
    @IBOutlet weak var lblPastIndicator: UILabel?
    @IBOutlet weak var lblRecommended: UILabel?
    
    @IBOutlet weak var viewBgFirst30: UIView?
    @IBOutlet weak var viewBgSecond30: UIView?
    
    @IBOutlet weak var viewMakeMeHealthy: UIView?
    @IBOutlet weak var viewFifteenThirthy: UIView?
    
    @IBOutlet weak var timerProgress: UICircularProgressRing?
    @IBOutlet weak var customTimerProgress: UICircularProgressRing?
    @IBOutlet weak var progressCircle: ProgressCircleLayer?
    @IBOutlet weak var customProgressCircle: ProgressCircleLayer?
    
    //CLASS VARIABLES
    var standingDuration: Int = 5
    var selectedStanding30FirstHour: Int = 5
    var selectedStanding30SecondHour: Int = 5
    var selectedStanding60Hour: Int = 5
    var custom30MinActivtySelected: Int = 1
    let custom30MinTimeDurationArray = [5,10,15,20,25]
    var presetSelected = PresetActivityProfile.None
    var customDuration = [[String: Any]]()
    var selectedCustomDuration  = CustomActivityProfile.None
    var thirtyMinsFirstPeriod: Bool = false
    var userMovement: String = ""
    var activityProfileDelegate: ActivityProfileControllerDelegate?
    var profileCountCommit: Int = 0
    var profileCommited: Bool = false
    
    var userProfileSettings = ProfileSettings(params: [String : Any]())
    var userProfile = ProfileSettingsData()
    var viewModel: ProfileSettingsViewModel?
    var progress = 0.0
    var profileType = ProfileSettingsType.Active
    
    let indicatorBlinker = SPTimeScheduler(timeInterval: 5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let email = Utilities.instance.getUserEmail()
        createCustomNavigationBar(title: "activity_profile.title".localize(), user: email, cloud: true, back: false, ble: true)
        customizeUI()
        indicatorBlinker.resume()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.onBtnAction(sender: btnFive ?? UIButton())
        
        self.contentScroll?.flashScrollIndicators()
        resetDurationTime()
        getProfileSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.onBtnAction(sender: btnFive ?? UIButton())
    }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
        let contentInsets = UIEdgeInsets.zero
        contentScroll?.contentInset = contentInsets
        contentScroll?.scrollIndicatorInsets = contentInsets
        print("deviceSize :", deviceSize)
        
        switch deviceSize {
            case .i4Inch, .i4_7Inch:
                contentScroll?.isScrollEnabled = true
                break
            default:
                contentScroll?.isScrollEnabled = false
            break
        }
    }
    
    override func customizeUI() {
        
        switch deviceSize {
            case .i4Inch:
                contentScroll?.contentInset = UIEdgeInsets.zero
                contentScroll?.scrollIndicatorInsets = UIEdgeInsets.zero
                contentScroll?.addSubview(contentStack ?? UIStackView())
                contentStack?.translatesAutoresizingMaskIntoConstraints = false
                
                contentStack?.leadingAnchor.constraint(equalTo: contentScroll?.leadingAnchor ?? NSLayoutXAxisAnchor(), constant: 10).isActive = true
                contentStack?.trailingAnchor.constraint(equalTo: contentScroll?.trailingAnchor ?? NSLayoutXAxisAnchor(), constant: 10).isActive = true
                contentStack?.topAnchor.constraint(equalTo: contentScroll?.topAnchor ?? NSLayoutYAxisAnchor() , constant: 0).isActive = true
                contentStack?.bottomAnchor.constraint(equalTo: contentScroll?.bottomAnchor ?? NSLayoutYAxisAnchor()).isActive = true
                contentStack?.widthAnchor.constraint(equalToConstant: self.view.frame.width - 20).isActive = true
                contentScroll?.isScrollEnabled = true
                break
                
            case .i4_7Inch:
                contentScroll?.contentInset = UIEdgeInsets.zero
                contentScroll?.scrollIndicatorInsets = UIEdgeInsets.zero
                contentScroll?.addSubview(contentStack ?? UIStackView())
                contentStack?.translatesAutoresizingMaskIntoConstraints = false
                
                contentStack?.leadingAnchor.constraint(equalTo: contentScroll?.leadingAnchor ?? NSLayoutXAxisAnchor(), constant: 10).isActive = true
                contentStack?.trailingAnchor.constraint(equalTo: contentScroll?.trailingAnchor ?? NSLayoutXAxisAnchor(), constant: 10).isActive = true
                contentStack?.topAnchor.constraint(equalTo: contentScroll?.topAnchor ?? NSLayoutYAxisAnchor() , constant: -5).isActive = true
                contentStack?.spacing = 0
                contentStack?.bottomAnchor.constraint(equalTo: contentScroll?.bottomAnchor ?? NSLayoutYAxisAnchor()).isActive = true

                contentStack?.widthAnchor.constraint(equalToConstant: self.view.frame.width - 20).isActive = true
                contentScroll?.isScrollEnabled = true
            break
            default:
                self.contentScroll?.removeFromSuperview()
                contentStack?.translatesAutoresizingMaskIntoConstraints = false
                viewContent?.addSubview(contentStack ?? UIStackView())
                contentStack?.leadingAnchor.constraint(equalTo: viewContent?.leadingAnchor ?? NSLayoutXAxisAnchor(), constant: 10).isActive = true
                contentStack?.trailingAnchor.constraint(equalTo: viewContent?.trailingAnchor ?? NSLayoutXAxisAnchor(), constant: 10).isActive = true
                contentStack?.topAnchor.constraint(equalTo: viewContent?.topAnchor ?? NSLayoutYAxisAnchor(), constant: 10).isActive = true
                contentStack?.bottomAnchor.constraint(equalTo: viewContent?.bottomAnchor ?? NSLayoutYAxisAnchor()).isActive = true

                contentStack?.centerXAnchor.constraint(equalTo: viewContent?.centerXAnchor ?? NSLayoutXAxisAnchor()).isActive = true
                contentStack?.centerYAnchor.constraint(equalTo: viewContent?.centerYAnchor ?? NSLayoutYAxisAnchor()).isActive = true
                contentStack?.widthAnchor.constraint(equalTo: viewContent?.widthAnchor ?? NSLayoutDimension(), constant: -20).isActive = true
        }
        
        
        btnDuration?.setImage(UIImage.fontAwesomeIcon(name: .caretDown,
                                                       style: .solid,
                                                       textColor: UIColor(hexString: Constants.smartpods_gray),
                                                       size: CGSize(width: 20, height: 20)), for: .normal)
        
        btnThirtyByThirty?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .selected)
        btnSixty?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .selected)
        
        btnThirtyByThirty?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnSixty?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        
        btnHealthy?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_blue), forState: .normal)
        btnHealthy?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .selected)
        btnHealthy?.setBackgroundColor(color: UIColor(hexString: Constants.smartpods_green), forState: .highlighted)
        
       lblPreset?.adjustContentFontSize()
       lblSecondEdit?.adjustContentFontSize()
       lblFirstEdit?.adjustContentFontSize()
       lblMinutes?.adjustContentFontSize()
       lblStandDuration?.adjustContentFontSize()
       btnDuration?.titleLabel?.adjustContentFontSize()
       btnThirtyByThirty?.titleLabel?.adjustContentFontSize()
       btnSixty?.titleLabel?.adjustContentFontSize()
       btnHealthy?.titleLabel?.adjustContentFontSize()
       lblSitIndicator?.adjustContentFontSize()
       lblStandIndicator?.adjustContentFontSize()
       lblPastIndicator?.adjustContentFontSize()
        lblRecommended?.adjustContentFontSize()
        
        viewBgFirst30?.roundCorners([.layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 15)
        viewBgSecond30?.roundCorners([.layerMinXMinYCorner, .layerMinXMaxYCorner], radius: 15)
        
       viewFifteenThirthy?.roundCorners([.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner], radius: 30)  
       
        
        //TIMER, SIT AND STAND PROGRESS VIEW
        let knobStyle = UICircularRingValueKnobStyle(size: 9, color: UIColor(hexstr: Constants.smartpods_green))
        timerProgress?.valueKnobStyle = knobStyle
        timerProgress?.shouldDrawMinValueKnob = true
        timerProgress?.startAngle = 270
        timerProgress?.style = .ontop
        
        let knobStyleCustom = UICircularRingValueKnobStyle(size: 7, color: UIColor(hexstr: Constants.smartpods_green))
        customTimerProgress?.valueKnobStyle = knobStyleCustom
        customTimerProgress?.shouldDrawMinValueKnob = true
        customTimerProgress?.startAngle = 270
        customTimerProgress?.style = .ontop
        
        indicatorBlinker.eventHandler = {
            
            switch deviceSize {
                case .i4Inch, .i4_7Inch:
                    DispatchQueue.main.async {
                        self.contentScroll?.flashScrollIndicators()
                    }
                    break
                default:
                    
                break
            }
            
        }
        
        
        SwiftEventBus.onMainThread(self, name: ViewEventListenerType.ActivityDataStream.rawValue) { [weak self] result in
            let obj = result?.object
        
            /******  CoreOne Data********/
            
            if obj is SPCoreObject {
                let _core = obj as? SPCoreObject
                //print("coreDataObjectEvent:", _core ?? CoreObject(strings: [""]))
                
                //PROGRESS INDICATORS
                let timeRemaining = NSNumber(value: _core?.MainTimerCycleSeconds ?? 3600)
                self?.progress = Double(Int(truncating: timeRemaining))
                
                if self?.profileType == .Custom {
                    self?.customTimerProgress?.startProgress(to: CGFloat(self?.progress ?? 0), duration:0.2)
                    //self?.presetView?.setProgressMaskLayer(to: Double(self?.progress ?? 0) / 3600, withAnimation: false)
                    self?.customProgressCircle?.setProgressMaskLayer(to: Double(self?.progress ?? 0) / 3600, withAnimation: false)
                } else {
                    self?.timerProgress?.startProgress(to: CGFloat(self?.progress ?? 0), duration:0.2)
                    //self?.presetView?.setProgressMaskLayer(to: Double(self?.progress ?? 0) / 3600, withAnimation: false)
                    self?.progressCircle?.setProgressMaskLayer(to: Double(self?.progress ?? 0) / 3600, withAnimation: false)
                }
                
            }
        }

    }
    
    override func bindViewModelAndCallbacks() {
        viewModel = ProfileSettingsViewModel()
        
        viewModel?.alertMessage = { [weak self](title: String, message: String, tag: Int) in
            self?.displayStatusNotification(title: message, style: .danger)
        }

        viewModel?.showIndicator = { [weak self] (show: Bool) in
            self?.showActivityIndicator(show: show)
        }
        
        viewModel?.forceLogout = { [weak self] () in
            self?.logoutUser(useGuest: false)
        }
    }
    
    func resetDurationTime() {
        standingDuration = 5
        selectedStanding30FirstHour = 5
        selectedStanding30SecondHour = 5
        selectedStanding60Hour = 5
    }
    
    func defaultActivityProfile() {
        // self.onBtnAction(sender: btnFive ?? UIButton())
        hideDurationView(hide: false)
        hideCustomizeDuration(hide: true)
        setButtonTabSelected(sender: [btnFifteen ?? UIButton(),
                                      btnThirty ?? UIButton(),
                                      btnThirtyByThirty ?? UIButton(),
                                      btnSixty ?? UIButton()])
        btnFive?.isSelected = true
        presetSelected = .Five
        drawPresetLayer(preset: presetSelected.rawValue)
        selectedCustomDuration = .None
        self.userProfile.StandingTime1 = 5
        self.userProfile.StandingTime2 = 0
        self.userProfile.ProfileSettingType = ProfileSettingsType.Active.rawValue
        self.profileType = ProfileSettingsType.Active
    }
    
    func getProfileSettings() {
        viewMakeMeHealthy?.doGlowAnimation(withColor: UIColor(hexString: Constants.smartpods_green), withEffect: .normal, repeatAnimation: true)
        guard !Utilities.instance.isGuest else {
            //self.onBtnAction(sender: btnFive ?? UIButton())
            requestProfileObject()
            return
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
            self?.refreshActivityProfileWithUserSettings(profile: object)
            self?.requestProfileObject()
        })
        
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
        
    }
    
    func requestProfileObject() {
        viewModel?.getLocalUserProfileInformation(email: Utilities.instance.getLoggedEmail() ,completion: { [weak self] object in
            
            self?.userProfileSettings = object
            self?.userProfile = ProfileSettingsData(data: object)
            self?.refreshActivityProfileWithUserSettings(profile: object)
            
        })
    }
    
    @IBAction func onBtnAction(sender: UIButton) {
        switch sender.tag {
            case 0:
             
             print("customDuration time: ", customDuration)
             sender.isSelected = true
             
             //should update the profile to the cloud
             if !Utilities.instance.isGuest {
                viewModel?.requestUpdateProfileSettings(self.userProfile.generateProfileParameters()) { data in
                    //let result = ProfileSettings(params: data)
                    //self.viewModel?.updateRecordinTable(object: result)
                    
                    self.userProfileSettings =  SPRealmHelper().updateUserProfileSettings(["StandingTime1":self.userProfile.StandingTime1,
                                                                                           "StandingTime2":self.userProfile.StandingTime2,
                                                                                           "ProfileSettingType":self.userProfile.ProfileSettingType,
                                                                                           "SittingPosition":self.userProfile.SittingPosition,
                                                                                           "StandingPosition":self.userProfile.StandingPosition,
                                                                                           "IsInteractive":self.userProfile.IsInteractive],
                                                                                          Utilities.instance.getLoggedEmail())
                }
             } else {
                
                    self.userProfileSettings =  SPRealmHelper().updateUserProfileSettings(["StandingTime1":self.userProfile.StandingTime1,
                                                                                           "StandingTime2":self.userProfile.StandingTime2,
                                                                                           "ProfileSettingType":self.userProfile.ProfileSettingType,
                                                                                           "SittingPosition":self.userProfile.SittingPosition,
                                                                                           "StandingPosition":self.userProfile.StandingPosition,
                                                                                           "IsInteractive":self.userProfile.IsInteractive],
                                                                                          Utilities.instance.getLoggedEmail())
             }

             if SPDeviceConnected() {
                
                Utilities.instance.saveDefaultValueForKey(value: false, key: "should_syncronize")
                let command = SPCommand.GenerateVerticalProfile(movements: customDuration)
                
                repeat {
                    self.sendACommand(command: command, name: "SPCommand.GenerateVerticalProfile - \(PulseDataState.instance.commitProfileCount)")
                    PulseDataState.instance.commitProfileCount += 1
                } while (PulseDataState.instance.commitProfileCount < PulseDataState.instance.commitProfileLimit && PulseDataState.instance.commitProfileCount != PulseDataState.instance.commitProfileLimit)
                 
                 Threads.performTaskAfterDealy(2.0) {
                    
                    //SwiftEventBus.postToMainThread(ViewEventListenerType.HomeDataStream.rawValue, sender: ["refreshProgress":true])
                    self.activityProfileDelegate?.activityProfileRedirectToHome()
                    PulseDataState.instance.commitProfileCount = 0
                    //self.requestPulseData(type: .Profile)
                
                    sender.isSelected = false
                }
                
                self.selectedStanding60Hour = 5
                self.selectedStanding30SecondHour = 5
                self.selectedStanding30SecondHour = 5
                self.standingDuration = 5
                 
             } else {
                sender.isSelected = false
                Utilities.instance.saveDefaultValueForKey(value: true, key: "should_syncronize")
            }
             
            case 1: //30/30 min
                standingDuration = 5
                self.lblMinutedDuration?.text = String(format:"%d",standingDuration)
                self.userProfile.ProfileSettingType = ProfileSettingsType.Custom.rawValue
                self.profileType = ProfileSettingsType.Custom
                selectedCustomDuration = .Thirthy
                
               let baseCustomDuration = [["key":"7",
                                    "value":0,
                                     "start":Constants.arcBaseAngle,
                                     "end":Utilities.instance.getAngle(duration: 15)],
                                    ["key":"4",
                                     "value":15 * 60,
                                     "start":Utilities.instance.getAngle(duration: 15),
                                     "end":Utilities.instance.getAngle(duration: 30)],
                                    ["key":"7",
                                     "value":30 * 60,
                                     "start":Utilities.instance.getAngle(duration: 30),
                                     "end":Utilities.instance.getAngle(duration: 45)],
                                    ["key":"4",
                                     "value":45 * 60,
                                     "start":Utilities.instance.getAngle(duration: 45),
                                     "end":Constants.arcBaseAngle]]
  
                if Utilities.instance.typeOfUserLogged() == .Guest {
                    self.selectedStanding30SecondHour = 5
                    self.selectedStanding30SecondHour = 5
                    customDuration = defaultCustomDuration(layers: baseCustomDuration, duration1: 5, duration2: 5)
                } else {
                    self.selectedStanding30SecondHour = self.userProfile.StandingTime1
                    self.selectedStanding30SecondHour = (self.userProfile.StandingTime2 != 0 ? self.userProfile.StandingTime2 : 5)
                    customDuration = defaultCustomDuration(layers: baseCustomDuration, duration1: self.selectedStanding30SecondHour, duration2: self.selectedStanding30SecondHour)
                }

                
                btnThirtyByThirty?.isSelected = true
                setButtonTabSelected(sender: [btnSixty ?? UIButton(),
                                              btnFive ?? UIButton(),
                                              btnFifteen ?? UIButton(),
                                              btnThirty ?? UIButton()])
                hideDurationView(hide: true)
                hideCustomizeDuration(hide: false)
                stackFirstEdit?.isHidden = true
                stackSecondEdit?.isHidden = false
                lblMinutes?.text = "activity_profile.first_30".localize()
                imgEditBg?.isHidden = false
                imgEditBg?.transform = CGAffineTransform(scaleX: 1, y: 1)
                thirtyMinsFirstPeriod = true
                
                presetSelected = .None
                
                stackFirstEdit?.isHidden = true
                stackSecondEdit?.isHidden = false
                setGlowingView(tag: 0)
                
                self.customProfileDuration(duration: standingDuration)
            
            case 2: //60 mins
                standingDuration = 5
                self.userProfile.ProfileSettingType = ProfileSettingsType.Custom.rawValue
                self.profileType = ProfileSettingsType.Custom
                selectedCustomDuration = .Sixty
                self.lblMinutedDuration?.text = String(format:"%d",standingDuration)
                let baseCustomDuration = [["key":"7",
                                     "start":0,
                                     "value":0,
                                     "end":0],
                                    ["key":"4",
                                     "start":0,
                                     "value":0,
                                     "end":0]]
                
                if Utilities.instance.typeOfUserLogged() == .Guest {
                    self.selectedStanding60Hour = 5
                    customDuration = defaultCustomDuration(layers: baseCustomDuration, duration1: 5, duration2: 0)
                } else {
                    self.selectedStanding60Hour = self.userProfile.StandingTime1
                    customDuration = defaultCustomDuration(layers: baseCustomDuration, duration1: self.selectedStanding30SecondHour, duration2: 0)
                }
                
                btnSixty?.isSelected = true
                setButtonTabSelected(sender: [btnThirtyByThirty ?? UIButton(),
                                              btnFive ?? UIButton(),
                                              btnFifteen ?? UIButton(),
                                              btnThirty ?? UIButton()])
                
                hideDurationView(hide: true)
                hideCustomizeDuration(hide: false)
                lblMinutes?.text = "activity_profile.hour_cycle".localize()
                imgEditBg?.isHidden = true
                stackFirstEdit?.isHidden = true
                stackSecondEdit?.isHidden = true
                presetSelected = .None
                self.customProfileDuration(duration: standingDuration)
                setGlowingView(tag: -1)
            
            case 3:
                standDuration() //stand duration
            
            case 4: //edit 1st
                custom30MinActivtySelected = 1
                stackFirstEdit?.isHidden = true
                stackSecondEdit?.isHidden = false
                lblMinutes?.text = "activity_profile.first_30".localize()
                imgEditBg?.transform = CGAffineTransform(scaleX: 1, y: 1)
                thirtyMinsFirstPeriod = true
                setGlowingView(tag: 0)
                self.lblMinutedDuration?.text = String(format:"%d",selectedStanding30FirstHour)
                self.customProfileDuration(duration: selectedStanding30FirstHour)
            case 5: //edit 2nd
                custom30MinActivtySelected = 2
                stackFirstEdit?.isHidden = false
                stackSecondEdit?.isHidden = true
                lblMinutes?.text = "activity_profile.second_30".localize()
                imgEditBg?.transform = CGAffineTransform(scaleX: -1, y: 1)
                thirtyMinsFirstPeriod = false
                setGlowingView(tag: 1)
                self.lblMinutedDuration?.text = String(format:"%d",selectedStanding30SecondHour)
                self.customProfileDuration(duration: selectedStanding30SecondHour)
            
            case 6: //5 preset
                hideDurationView(hide: false)
                hideCustomizeDuration(hide: true)
                setButtonTabSelected(sender: [btnFifteen ?? UIButton(),
                                              btnThirty ?? UIButton(),
                                              btnThirtyByThirty ?? UIButton(),
                                              btnSixty ?? UIButton()])
                btnFive?.isSelected = true
                presetSelected = .Five
                drawPresetLayer(preset: presetSelected.rawValue)
                selectedCustomDuration = .None
                self.userProfile.StandingTime1 = 5
                self.userProfile.StandingTime2 = 0
                self.userProfile.ProfileSettingType = ProfileSettingsType.Active.rawValue
                self.profileType = ProfileSettingsType.Active
                
            case 7: //15 preset
                hideDurationView(hide: false)
                hideCustomizeDuration(hide: true)
                setButtonTabSelected(sender: [btnFive ?? UIButton(),
                                              btnThirty ?? UIButton(),
                                              btnThirtyByThirty ?? UIButton(),
                                              btnSixty ?? UIButton()])
                btnFifteen?.isSelected = true
                presetSelected = .Fifteen
                drawPresetLayer(preset: presetSelected.rawValue)
                selectedCustomDuration = .None
            
                self.userProfile.StandingTime1 = 15
                self.userProfile.StandingTime2 = 0
                self.userProfile.ProfileSettingType = ProfileSettingsType.ModeratelyActive.rawValue
                self.profileType = ProfileSettingsType.ModeratelyActive
            
            case 8:  //30 preset
                hideDurationView(hide: false)
                hideCustomizeDuration(hide: true)
                setButtonTabSelected(sender: [btnFive ?? UIButton(),
                                              btnFifteen ?? UIButton(),
                                              btnThirtyByThirty ?? UIButton(),
                                              btnSixty ?? UIButton()])
                btnThirty?.isSelected = true
                presetSelected = .Thirthy
                drawPresetLayer(preset: presetSelected.rawValue)
                selectedCustomDuration = .None
                //dataHelper.updateUserProfileSettings(["StandingTime1": 15], Utilities.instance.getLoggedEmail())
                self.userProfile.StandingTime1 = 15
                self.userProfile.StandingTime2 = 15
                self.userProfile.ProfileSettingType = ProfileSettingsType.VeryActive.rawValue
                self.profileType = ProfileSettingsType.VeryActive
        default:
            hideDurationView(hide: false)
            hideCustomizeDuration(hide: true)
            setButtonTabSelected(sender: [btnFifteen ?? UIButton(),
                                          btnThirty ?? UIButton(),
                                          btnThirtyByThirty ?? UIButton(),
                                          btnSixty ?? UIButton()])
            btnFive?.isSelected = true
            presetSelected = .Five
            drawPresetLayer(preset: presetSelected.rawValue)
            selectedCustomDuration = .None
            self.userProfile.StandingTime1 = 5
            self.userProfile.StandingTime2 = 0
            self.userProfile.ProfileSettingType = ProfileSettingsType.Active.rawValue
            self.profileType = ProfileSettingsType.Active
        }
    }
    
    func refreshActivityProfileWithUserSettings(profile: ProfileSettings) {
        let _profileType: ProfileSettingsType = ProfileSettingsType(rawValue: profile.ProfileSettingType) ?? ProfileSettingsType.Active
        
        switch _profileType {
            case .Active:
                self.onBtnAction(sender: btnFive ?? UIButton())
            case .ModeratelyActive:
                self.onBtnAction(sender: btnFifteen ?? UIButton())
            case .VeryActive:
                self.onBtnAction(sender: btnThirty ?? UIButton())
            case .Custom:
                if profile.StandingTime2 == 0 {
                    self.onBtnAction(sender: btnSixty ?? UIButton())
                } else {
                    self.onBtnAction(sender: btnThirtyByThirty ?? UIButton())
                }
        }
    }
    
    func hideDurationView(hide: Bool) {
        durationView?.isHidden = hide
    }
    
    func hideCustomizeDuration(hide: Bool) {
        customizationView?.isHidden = hide
    }
    
    func setGlowingView(tag: Int) {
        
        viewBgFirst30?.backgroundColor = .clear
        viewBgSecond30?.backgroundColor = .clear
        
        switch tag {
        case 0:
                viewBgFirst30?.backgroundColor = UIColor(hexString: Constants.smartpods_green)
                viewBgFirst30?.alpha = 0.5
                
                viewBgFirst30?.startGlowing(
                    color: .white,
                    toIntensity: 1.0,
                    fill: true,
                    duration: 1.0)
                viewBgSecond30?.stopGlowing()
            case 1:
                viewBgSecond30?.backgroundColor = UIColor(hexString: Constants.smartpods_green)
                viewBgSecond30?.alpha = 0.5
                viewBgFirst30?.stopGlowing()
                viewBgSecond30?.startGlowing(
                        color: .white,
                        toIntensity: 1.0,
                        fill: true,
                        duration: 1.0)
        default:
            viewBgFirst30?.backgroundColor = .clear
            viewBgSecond30?.backgroundColor = .clear
            viewBgSecond30?.stopGlowing()
            viewBgFirst30?.stopGlowing()
        }
    }
    
    func standDuration() {
        let alert = UIAlertController(style: .alert, title: "Stand Duration", message: "Select standing duration.")
        let time: [Int] = selectedCustomDuration == CustomActivityProfile.Thirthy ? self.custom30MinTimeDurationArray : [5,10,15,20,25,30,35,40,45,50,55]
        let pickerViewValues: [[String]] = [time.map { Int($0).description }]
        let pickerViewSelectedValue: PickerViewViewController.Index = selectedCustomDuration == CustomActivityProfile.Thirthy ? (custom30MinActivtySelected == 1 ? (column: 0, row: time.firstIndex(of: selectedStanding30FirstHour) ?? 0) : (column: 0, row: time.firstIndex(of: selectedStanding30SecondHour) ?? 0)) : (column: 0, row: time.firstIndex(of: 5) ?? 0) //(column: 0, row: time.firstIndex(of: 5) ?? 0)
        //self.standingDuration = time[0]
        
        self.standingDuration = selectedCustomDuration == CustomActivityProfile.Thirthy ? (custom30MinActivtySelected == 1 ? selectedStanding30FirstHour : selectedStanding30SecondHour) : time[0]
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            //DispatchQueue.main.async {
                if self.selectedCustomDuration == .Thirthy {
                    if self.custom30MinActivtySelected == 1 {
                        self.selectedStanding30FirstHour = time[index.row]
                    } else {
                        self.selectedStanding30SecondHour = time[index.row]
                    }
                }
            
                self.standingDuration = time[index.row]

                self.lblMinutedDuration?.text = String(format:"%d",time[index.row])
                self.customProfileDuration(duration: time[index.row])
            //}
        }
        alert.addAction(title: "Done", style: .cancel, handler: { action in
            if self.selectedCustomDuration == .Thirthy {
                if self.custom30MinActivtySelected == 1 {
                    self.selectedStanding30FirstHour = self.standingDuration
                } else {
                    self.selectedStanding30SecondHour = self.standingDuration
                }
            }
            
            self.lblMinutedDuration?.text = String(format:"%d",self.standingDuration)
            self.customProfileDuration(duration: self.standingDuration)
        })
        
        alert.show()
    }
    
    func drawPresetLayer(preset: Int) {
        //VM|1|3,7|900,4|1800,7|2700,4
        let getTimeDiff = 60 - preset
        let startStandAngle = Utilities.instance.getAngle(duration: getTimeDiff)
        let startAngle = Constants.arcBaseAngle
        switch preset {
            case 5:
                Utilities.instance.clearAllLayersInView(view: self.presetView ?? UIView())
                let durationTime = [["key":"7",
                                     "start":startAngle,
                                     "value": 0,
                                     "end":startStandAngle],
                                    ["key":"4",
                                     "start":startStandAngle,
                                     "value":getTimeDiff * 60,
                                     "end":startAngle]]
                customDuration = durationTime
                self.presetView?.createPresetTimeDurationCircle(periods: durationTime, title: "5")
            case 15:
                let durationTime = [["key":"7",
                                     "start":startAngle,
                                     "end":startStandAngle,
                                     "value":0],
                                    ["key":"4",
                                     "start":startStandAngle,
                                     "end":startAngle,
                                     "value":getTimeDiff * 60]]
                customDuration = durationTime
                
                Utilities.instance.clearAllLayersInView(view: self.presetView ?? UIView())
                self.presetView?.createPresetTimeDurationCircle(periods:durationTime,  title: "15")
            
            case 30:
                Utilities.instance.clearAllLayersInView(view: self.presetView ?? UIView())
                let firstPeriod = Utilities.instance.getAngle(duration: getTimeDiff / 2)
                print("firstPeriod : ", firstPeriod)
                let nextDown = Utilities.instance.getAngle(duration: 30)
                let secondPeriod = Utilities.instance.getAngle(duration: 45)
                let durationTime = [["key":"7",
                                     "start":startAngle,
                                     "end":firstPeriod,
                                     "value":0],
                                    ["key":"4",
                                     "start":firstPeriod,
                                     "end":nextDown,
                                     "value": (getTimeDiff / 2) * 60],
                                    ["key":"7",
                                     "start":nextDown,
                                     "end":secondPeriod,
                                     "value": 30 * 60],
                                    ["key":"4",
                                     "start":secondPeriod,
                                     "end":startAngle,
                                     "value":45 * 60]]
                customDuration = durationTime
                self.presetView?.createPresetTimeDurationCircle(periods: durationTime, title: "30")
                default:break
        }
    }
    
    func customProfileDuration(duration: Int) {
        Utilities.instance.clearAllLayersInView(view: self.customCircleDuration ?? UIView())
        print("customProfileDuration duration : ", duration)
        if selectedCustomDuration == .Thirthy {
            //var firstPeriodStand = 0
            if thirtyMinsFirstPeriod {
                let getTimeDiff = 30 - duration
                let startStandAngle = Utilities.instance.getAngle(duration: getTimeDiff)
                let startAngle = Constants.arcBaseAngle
                let endAngle = Utilities.instance.getAngle(duration: 30)
                
                //firstPeriodStand = (getTimeDiff * 60)
                
                let firstItem: [String: Any] = ["key":"7","value":3,"start":startAngle,"end":startStandAngle]
                let secondItem: [String: Any] = ["key":"4","value":(getTimeDiff * 60) ,"start":startStandAngle,"end":endAngle] //+ (getTimeDiff * 60)
                customDuration.remove(at: 0)
                customDuration.insert(firstItem, at: 0)
                customDuration.remove(at: 1)
                customDuration.insert(secondItem, at: 1)
                self.userProfile.StandingTime1 = duration
                print("thirtyMinsFirstPeriod data: ", customDuration)
                
            } else {
                let getTimeDiff = 60 -  duration
                let startStandAngle = Utilities.instance.getAngle(duration: getTimeDiff)
                let startAngle = Utilities.instance.getAngle(duration: 30)
                let endAngle = Constants.arcBaseAngle
                
                let firstItem: [String: Any] = ["key":"7","value":1800, "start":startAngle,"end":startStandAngle]
                let secondItem: [String: Any] = ["key":"4","value": (getTimeDiff * 60) , "start":startStandAngle,"end":endAngle]
                customDuration.remove(at: 2)
                customDuration.insert(firstItem, at: 2)
                customDuration.remove(at: 3)
                customDuration.insert(secondItem, at: 3)
                self.userProfile.StandingTime2 = duration
                print("thirtyMinsSecondPeriod data: ", customDuration)
            }
            
            self.customCircleDuration?.createCustomTimeDuration(periods: customDuration, clockwise: true)
        } else if selectedCustomDuration == .Sixty {
            
            let getTimeDiff = 60 - duration
            let startStandAngle = Utilities.instance.getAngle(duration: getTimeDiff)
            let startAngle = Constants.arcBaseAngle
            
            let firstItem: [String: Any] = ["key":"7","value":3,"start":startAngle,"end":startStandAngle]
            let secondItem: [String: Any] = ["key":"4","value":(getTimeDiff * 60),"start":startStandAngle,"end":startAngle]
            customDuration.remove(at: 0)
            customDuration.insert(firstItem, at: 0)
            customDuration.remove(at: 1)
            customDuration.insert(secondItem, at: 1)
            self.userProfile.StandingTime1 = duration
            self.userProfile.StandingTime2 = 0
            self.customCircleDuration?.createCustomTimeDuration(periods: customDuration, clockwise: true)
        } else {
            return
        }
    }
    
    func defaultCustomDuration(layers:  [[String: Any]], duration1: Int, duration2: Int) ->  [[String: Any]] {
        var _customerDuration = layers
        
        if selectedCustomDuration == .Thirthy {
            let getTimeDiff = 30 - duration1
            let startStandAngle = Utilities.instance.getAngle(duration: getTimeDiff)
            let startAngle = Constants.arcBaseAngle
            let endAngle = Utilities.instance.getAngle(duration: 30)
            
            //firstPeriodStand = (getTimeDiff * 60)
            
            let firstItem: [String: Any] = ["key":"7","value":3,"start":startAngle,"end":startStandAngle]
            let secondItem: [String: Any] = ["key":"4","value":(getTimeDiff * 60) ,"start":startStandAngle,"end":endAngle] //+ (getTimeDiff * 60)
            _customerDuration.remove(at: 0)
            _customerDuration.insert(firstItem, at: 0)
            _customerDuration.remove(at: 1)
            _customerDuration.insert(secondItem, at: 1)
            self.userProfile.StandingTime1 = duration1
            print("thirtyMinsFirstPeriod data: ", _customerDuration)
            
            let getTimeDiff2 = 60 -  duration2
            let startStandAngle2 = Utilities.instance.getAngle(duration: getTimeDiff2)
            let startAngle2 = Utilities.instance.getAngle(duration: 30)
            let endAngle2 = Constants.arcBaseAngle
            
            let firstItem2: [String: Any] = ["key":"7","value":1800, "start":startAngle2,"end":startStandAngle2]
            let secondItem2: [String: Any] = ["key":"4","value": (getTimeDiff2 * 60) , "start":startStandAngle2,"end":endAngle2]
            _customerDuration.remove(at: 2)
            _customerDuration.insert(firstItem2, at: 2)
            _customerDuration.remove(at: 3)
            _customerDuration.insert(secondItem2, at: 3)
            self.userProfile.StandingTime2 = duration2
            print("thirtyMinsSecondPeriod data: ", _customerDuration)
        } else {
            let getTimeDiff = 60 - duration1
            let startStandAngle = Utilities.instance.getAngle(duration: getTimeDiff)
            let startAngle = Constants.arcBaseAngle
            
            let firstItem: [String: Any] = ["key":"7","value":3,"start":startAngle,"end":startStandAngle]
            let secondItem: [String: Any] = ["key":"4","value":(getTimeDiff * 60),"start":startStandAngle,"end":startAngle]
            customDuration.remove(at: 0)
            customDuration.insert(firstItem, at: 0)
            customDuration.remove(at: 1)
            customDuration.insert(secondItem, at: 1)
            self.userProfile.StandingTime1 = duration1
            self.userProfile.StandingTime2 = 0
        }
        
        
        
        return _customerDuration
    }
    
}
