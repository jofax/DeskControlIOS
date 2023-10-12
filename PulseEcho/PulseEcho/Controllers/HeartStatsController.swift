//
//  HeartStatsController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-08.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import FontAwesome_swift
import UICircularProgressRing
import AsyncTimer
import EventCenter
import SwiftEventBus
import Device
import MarqueeLabel
import NVActivityIndicatorView
import SPPermissions

protocol HeartStatsControllerDelegate {
    func redirectToDeskModeChange()
}

var heartBeatCount = 0

class HeartStatsController: BaseController {

    //STORYBOARD OUTLETS
    
    @IBOutlet weak var stackContent: UIStackView?
    @IBOutlet weak var homeContainer: UIView?
    
    @IBOutlet weak var heartViewIndicator: AnimatedHeartView?
    @IBOutlet weak var dailyView: UIView?
    @IBOutlet weak var viewTotal: UIView?
    @IBOutlet weak var heartContainer: UIView?
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var mainViewContainer: UIView!
    
    @IBOutlet weak var btnBankStars: UIButton?
    @IBOutlet weak var lblDailyTitle: UILabel?
    @IBOutlet weak var lblDaily: UILabel?
    @IBOutlet weak var lblTotalTitle: UILabel?
    @IBOutlet weak var lblTotal: UILabel?
    @IBOutlet weak var lblStarsTotal: UILabel?
    @IBOutlet weak var btnStars: UIButton?
    @IBOutlet weak var btnStarCounts: UIButton?
    @IBOutlet weak var timerProgress: UICircularProgressRing?
    @IBOutlet weak var sitStandProgress: HearProgressCircle?
    @IBOutlet weak var imgDeskMode: UIImageView?
    
    @IBOutlet weak var lblDeskModeTitle: UILabel?
    @IBOutlet weak var lblUpDownTitle: UILabel?
    
    @IBOutlet weak var imgNoProgress: UIImageView?
    @IBOutlet weak var lblDeskMode: UILabel?
    
    @IBOutlet weak var btnSound: UIButton?
    @IBOutlet weak var btnTemp: UIButton?
    @IBOutlet weak var btnLight: UIButton?
    @IBOutlet weak var btnListStars: UIButton?
    
    @IBOutlet weak var soundIndicator: TemperatureIndicator?
    @IBOutlet weak var lightIndicator: TemperatureIndicator?
    
    @IBOutlet weak var lblCelcius: UILabel?
    @IBOutlet weak var lblFarenheight: UILabel?
    
    @IBOutlet weak var lblUp: UILabel?
    @IBOutlet weak var lblDown: UILabel?
    
    @IBOutlet weak var lblUpValue: UILabel?
    @IBOutlet weak var lblDownValue: UILabel?
    
    @IBOutlet weak var heartProgressBg: HeartProgressBackgroundLayer!
    @IBOutlet weak var manualModeNotifier: MarqueeLabel?
    
    @IBOutlet weak var topHeartConstraint: NSLayoutConstraint?
    @IBOutlet weak var centerYHeartConstraint: NSLayoutConstraint?
    @IBOutlet weak var timerHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var sensorHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var dailyCountHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var bankStarHeightConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var viewHeartContainer: UIView?
    
    @IBOutlet weak var heartHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var heartWidthConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var viewHeartContainerTopConstraint: NSLayoutConstraint?
    @IBOutlet weak var viewHeartContainerBottomConstraint: NSLayoutConstraint?
    
    @IBOutlet weak var viewDeskModeIndicator: UIView?
    @IBOutlet weak var viewSitStandIndicator: UIView?
    @IBOutlet weak var viewDailyContainer: UIView?
    @IBOutlet weak var viewSensorContainer: UIView?
    @IBOutlet weak var stackViewSensor: UIStackView?
    
    var marqueeTimer: Timer?
    var marqueeTimerRunCount = 0
    var heartsRemainder = 0.0
    var viewState = USER_INTERACTION_STATE.NORMAL
    weak var homeProtocol: HomeActionsProtocol?
    
    //CLASS VARIABLES
    private var progressTimer: AsyncTimer?

    var coreOneObject: SPCoreObject?
    var verticalMovementProfile: SPVerticalProfile?
    var boxIdentifier: SPIdentifier?
    var mainTimerCycleSeconds: Int?
    var progress = 0.0
    var viewModel: UserViewModel?
    var heartStatsViewModel: HeartStatsViewModel?
    var awayStatus: Bool?
    var safetyStatus: Bool?
    var runSwitchStatus: Bool?
    var heightStatus: Bool?
    var commissioningFlag: Bool?
    var calibrationMode: Bool?
    var alertnateATBMode: Bool?
    var currentDeskMode: String = ""
    var pendingMovementCode: Int = 0
    var interactivePopUpShowed = false
    var safetyPopUpShowed = false
    var acknowledgeGesture = UITapGestureRecognizer()
    var heartStatsDelegate: HeartStatsControllerDelegate?
    
    let userEmail = Utilities.instance.getLoggedEmail()
    var detailsTapGesture = UITapGestureRecognizer()
    var indicatorStatus: Bool = false
    var isInteractive: Bool = false
    var refreshProgressProfile = false
    var tempSafetyStatus = false
    var newProfileDetected = false
    var profileViewModel: ProfileSettingsViewModel?
    var dailyHearts: Double = 0
    var dailyHeartsTotal: Double = 0
    
    lazy var interactivePopUp: InteractiveModePopUpController = {
        let controller = InteractiveModePopUpController.instantiateFromStoryboard(storyboard: "Home") as! InteractiveModePopUpController
        return controller
    }()
    
    var hasDepartment: Bool? {
        didSet {
            if let item = hasDepartment {
                if item == false {
                    showDepartmentPopUp()
                }
            }
        }
    }
    
    let scheduler = SPTimeScheduler(timeInterval: 300)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let email = Utilities.instance.getLoggedEmail()
        createCustomNavigationBar(title: "home.title".localize(), user: email,cloud: true, back: false, ble: true)
        customizeUI()
        
        guard !Utilities.instance.isGuest else {
            return
        }
        
        
        guard !Utilities.instance.IS_FREE_VERSION else {

            return
        }
        
        SPBluetoothManager.shared.event = self.event
        SPBluetoothManager.shared.delegate = self
        SPBluetoothManager.shared.connectivityDelegate = self
        scheduler.resume()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //app_delegate.scheduleLocalNotification()
        
        if Utilities.instance.permissionViewShown == false && Utilities.instance.isFirstAppLaunch() {
            Utilities.instance.permissionViewShown = true
            self.AppPermissionRequest()
        }
        
        
        
        #if targetEnvironment(simulator)
            return
        #endif
        
        checkBLEStatus()
        //getUser() //move this to the viewdidload
        print("profile data: ", verticalMovementProfile)
        
        setLocalDataExpiry()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkBLEStatus()
        super.viewWillAppear(animated)
    }

    func verticalMovementUpdate() {
        if verticalMovementProfile != nil {
            self.sitStandProgress?.initWithProfile(movements:verticalMovementProfile ?? SPVerticalProfile(data: [UInt8](), rawString: "", notify: false))
            //self?.reloadProgressStatus(refresh: false)
            self.reloadProgressStatus(refresh: false)
        }
    }
    
    func setLocalDataExpiry() {
        let currentDate = Date()
        let expiryDate = Calendar.current.date(byAdding: .day, value: 7, to: currentDate)
        viewModel?.updateUserAppState(email: Utilities.instance.getLoggedEmail(), data: ["UserAppStates": expiryDate?.currentTimeMillis() ?? 0])
    }
    
    func getSavedUserProfile() {
        let dataHelper = SPRealmHelper()
        let email = Utilities.instance.getLoggedEmail()

        do {
            let vm = try dataHelper.getPulseDevice(email)
            
            if vm.UserProfile.isEmpty {
                self.requestPulseData(type: .Profile)
                //self.requestPulseData(type: .Info)
                SPBluetoothManager.shared.getLatestProfile()
            } else {
                let profile = vm.UserProfile.hexaBytes
                self.verticalMovementProfile = SPVerticalProfile(data: profile, rawString: vm.UserProfile, notify: false)
                verticalMovementUpdate()
            }
        } catch {
            print("Realm getPulseDevice error | info: \(Utilities.instance.loginfo())")
        }
        
    }
    
    
    func getUser() {
        
        guard !Utilities.instance.isGuest else {
            guestPredefinedData()
            return
        }
        
        let reachable = reachability?.isReachable ?? false
        if  reachable{
            refreshProfile()
            refreshProfileSettings()
        } else {
          requestUserObject()
        }
    }
    
    func refreshProfile() {
        viewModel?.getUserInformation(completion: { [weak self] object in
           //update box
            // refresh data
            
            if object is User {
                self?.requestUserObject()
            } 
        })
    }
    
    func refreshProfileSettings() {
        profileViewModel?.getProfileSettings(completion: { [weak self] cloudProfile in
            self?.profileViewModel?.getLocalUserProfileInformation(email: Utilities.instance.getLoggedEmail() ,completion: { [weak self] localProfile in
                if (cloudProfile.SittingPosition != localProfile.SittingPosition) || (cloudProfile.StandingPosition != localProfile.StandingPosition) {
                    if (PulseDataState.instance.sittingHeightTruncated || PulseDataState.instance.standHeightTruncated) {
                        //self?.checkSitAndStandHeight()
                    }
                }
            })
        })
    }
    
    func refreshHeartProgress() {
        if verticalMovementProfile == nil {
            Threads.performTaskAfterDealy(0.5) {
                //self.requestPulseData(type: .Profile)
                self.getSavedUserProfile()
            }
        } else {
            guard ((self.verticalMovementProfile?.movementRawString.isEmpty) != nil) else {
                verticalMovementUpdate()
                return
            }
            self.getSavedUserProfile()
            
        }
    }
    
    func requestUserObject() {
        
        Threads.performTaskInMainQueue {
            self.viewModel?.getLocalUserInformation(completion: { [weak self] object in
                self?.refreshHeartsDailyAndTotal(today: object.HeartsToday,
                                                 total: object.HeartsTotal)
                let remainder = self?.heartsRemainder
                let _remainder = object.HeartsToday.truncatingRemainder(dividingBy: 1)
                
                self?.dailyHearts = object.HeartsToday
                self?.dailyHeartsTotal = object.HeartsTotal
                
                if remainder != _remainder && _remainder > remainder {
                    self?.heartsRemainder = _remainder
                    //self?.addHeartProgress(value: _remainder, alertStatus: false)
                }
                print("remainder : \(remainder) _remainder : \(_remainder)")
                print("remainder : \(remainder != _remainder && _remainder > remainder )")
                //self?.heartViewIndicator?.progress = 0.5
                
            })
        }
        
        //self.requestPulseData(type: .Profile)
    }
    
    func refreshHeartsDailyAndTotal(today: Double, total: Double) {
        lblTotal?.text = String(format: "%.0f", total)
        lblDaily?.text = String(format: "%.0f", today)
    }
    
    func showDepartmentPopUp() {
        self.chooseAndUpdateDepartmentList(shouldUpdate: true) { (Department) in
            
        }
    }
    
    override func bindViewModelAndCallbacks() {
        
    }
    
    override func allowLocationService() {
        let locationAuthorize = SPPermission.locationWhenInUse.isAuthorized
        
        if locationAuthorize {
            self.heartStatsViewModel = HeartStatsViewModel()
            self.heartStatsViewModel?.loadAllGeotifications()
        }
    }
    
    override func customizeUI() {
        
        self.viewModel = UserViewModel()
        self.profileViewModel = ProfileSettingsViewModel()
        
        let locationAuthorize = SPPermission.locationWhenInUse.isAuthorized
        
        if locationAuthorize {
            self.heartStatsViewModel = HeartStatsViewModel()
            //self.heartStatsViewModel?.loadAllGeotifications()
        }
        getUser()
        /*
         Disable main features of the app
         ------------------------------------------------------------------------------
         **/
        
        viewDeskModeIndicator?.isHidden = Utilities.instance.IS_FREE_VERSION
        viewSitStandIndicator?.isHidden = Utilities.instance.IS_FREE_VERSION
        stackViewSensor?.isHidden =  true //Utilities.instance.IS_FREE_VERSION
        manualModeNotifier?.isHidden = Utilities.instance.IS_FREE_VERSION
        
        viewDailyContainer?.bottomBorderWidth = 0
        viewDailyContainer?.borderColor = UIColor(hexString: Constants.smartpods_gray)
        viewSensorContainer?.bottomBorderWidth = 0
        viewSensorContainer?.borderColor = UIColor(hexString: Constants.smartpods_gray)
        
        /*if Utilities.instance.IS_FREE_VERSION == false {
            viewDailyContainer?.bottomBorderWidth = 1
            viewDailyContainer?.borderColor = UIColor(hexString: Constants.smartpods_gray)
            viewSensorContainer?.bottomBorderWidth = 1
            viewSensorContainer?.borderColor = UIColor(hexString: Constants.smartpods_gray)
        } else {
            viewDailyContainer?.bottomBorderWidth = 0
            viewDailyContainer?.borderColor = UIColor(hexString: Constants.smartpods_gray)
            viewSensorContainer?.bottomBorderWidth = 0
            viewSensorContainer?.borderColor = UIColor(hexString: Constants.smartpods_gray)
        }*/
        
        /**
         ------------------------------------------------------------------------------
         */
        
        
        //Localization labels and text
        btnBankStars?.setTitle("home.bank_stars".localize(), for: .normal)
        btnListStars?.setTitle("home.list_stars".localize(), for: .normal)
        lblDailyTitle?.text = "home.daily_title".localize()
        lblTotalTitle?.text = "home.total_title".localize()
        
        //Adjust font size for devices
        lblDailyTitle?.adjustContentFontSize()
        lblTotalTitle?.adjustContentFontSize()
        
        lblTotal?.adjustNumberFontSize()
        lblDaily?.adjustNumberFontSize()
        lblStarsTotal?.adjustContentFontSize()
        
        btnBankStars?.titleLabel?.adjustContentFontSize()
        btnListStars?.titleLabel?.adjustContentFontSize()
        
        lblDeskModeTitle?.adjustContentFontSize()
        lblUpDownTitle?.adjustContentFontSize()
        
        lblCelcius?.adjustContentFontSize()
        lblFarenheight?.adjustContentFontSize()
        
        lblUp?.adjustContentFontSize()
        lblDown?.adjustContentFontSize()
        
        lblUpValue?.adjustContentFontSize()
        lblDownValue?.adjustContentFontSize()
        lblDeskMode?.adjustContentFontSize()
        manualModeNotifier?.adjustContentFontSize()

        self.profileViewModel?.apiCallback = { [weak self] (_ response : Any, _ status: Int) in
            if status == 6 {
                self?.showAlertWithAction(title: "generic.notice".localize(),
                                          message: "generic.invalid_session".localize(),
                                          buttonTitle: "common.ok".localize(), buttonAction: {
                                            self?.logoutUser(useGuest: false)
                                          })
            }
        }
        
        scheduler.eventHandler = {
            print("Time Scheduler Fired")
            guard (Utilities.instance.typeOfUserLogged() != .None || Utilities.instance.typeOfUserLogged() != .Guest) else {
                return
            }
            
            self.getUser()
            self.checkAndUpdateProfileSettings()
            
        }
        
        //adjust heart layout
        switch deviceSize {
            case .i4_7Inch:
                
                centerYHeartConstraint?.constant = 20
                
                topHeartConstraint?.constant = 0
                heartWidthConstraint?.constant = 120
                heartHeightConstraint?.constant = 200
                
                viewHeartContainerTopConstraint?.constant = 50 //58
                viewHeartContainerBottomConstraint?.constant = 30 //35
                
                heartViewIndicator?.layoutIfNeeded()
                viewHeartContainer?.layoutIfNeeded()
            
            case .i6_1Inch :
                topHeartConstraint?.constant = 50
                heartWidthConstraint?.constant = 240
                heartHeightConstraint?.constant = 220
                heartViewIndicator?.layoutIfNeeded()
        
//                topHeartConstraint?.constant = 60
//                heartWidthConstraint?.constant = 270
//                heartHeightConstraint?.constant = 240
//                heartViewIndicator?.layoutIfNeeded()
                        
            case .i4Inch:
                timerHeightConstraint?.constant = 40 //60
                sensorHeightConstraint?.constant = 40 //60
                dailyCountHeightConstraint?.constant = 60 //80
                bankStarHeightConstraint?.constant = 40 //60
                viewHeartContainerTopConstraint?.constant = 40 //58
                viewHeartContainerBottomConstraint?.constant = 30 //35
            
                topHeartConstraint?.constant = 10
                heartWidthConstraint?.constant = 110
                heartHeightConstraint?.constant = 120
                
                heartViewIndicator?.layoutIfNeeded()
                viewHeartContainer?.layoutIfNeeded()
            
            case .i6_5Inch:
                            
                topHeartConstraint?.constant = 50
                 heartWidthConstraint?.constant = 240
                 heartHeightConstraint?.constant = 240
                 heartViewIndicator?.layoutIfNeeded()
            
        case .i5_8Inch, .i5_5Inch:
            topHeartConstraint?.constant = 20
            heartWidthConstraint?.constant = 170
            heartHeightConstraint?.constant = 190
            heartViewIndicator?.layoutIfNeeded()
            
            default:
                break
//                topHeartConstraint?.constant = 8
//                heartWidthConstraint?.constant = 190
//                heartHeightConstraint?.constant = 190
//                heartViewIndicator?.layoutIfNeeded()
//
//                topHeartConstraint?.constant = 20
//                heartWidthConstraint?.constant = 170
//                heartHeightConstraint?.constant = 190
//                heartViewIndicator?.layoutIfNeeded()
                

        }
        
                
        btnStars?.setImage(UIImage.fontAwesomeIcon(name: .star,
                                                  style: .solid,
                                                  textColor: .white,
                                                  size: CGSize(width: 40, height: 40)), for: .normal)
        
        //Heart Progress indicator
        
        print("device size: ", deviceSize)
        
        heartViewIndicator?.progress = 0.0
        heartViewIndicator?.heartAmplitude = 5.0
        heartViewIndicator?.isShowProgressText = false
        heartViewIndicator?.isAnimated = true
        
        dailyView?.roundCorners([.layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 30)
        viewTotal?.roundCorners([.layerMinXMinYCorner, .layerMinXMaxYCorner], radius: 30)
        
        heartViewIndicator?.heavyHeartColor = UIColor(hexstr: Constants.smartpods_bluish_white)
        heartViewIndicator?.lightHeartColor = .lightGray
        heartViewIndicator?.fillHeartColor = .clear
        
        if !Utilities.instance.isGuest {
            self.addHeartDetailsGesture(add: true)
        } else {
            //self.viewModel?.saveHeartsAccumulated()
        }
        
        self.imgDeskMode?.isUserInteractionEnabled = true
        self.imgNoProgress?.isUserInteractionEnabled = true
        let deskModeTap = UITapGestureRecognizer(target: self, action: #selector(changeDeskMode(_:)))
        deskModeTap.numberOfTapsRequired = 1
        self.imgDeskMode?.addGestureRecognizer(deskModeTap)
        
        //TIMER, SIT AND STAND PROGRESS VIEW
        
        if Utilities.instance.IS_FREE_VERSION {
            timerProgress?.valueKnobStyle = nil
            timerProgress?.shouldDrawMinValueKnob = false
            timerProgress?.startAngle = 270
            timerProgress?.style = .ontop
        } else {
            let knobStyle = UICircularRingValueKnobStyle(size: 9, color: UIColor(hexstr: Constants.smartpods_green))
            timerProgress?.valueKnobStyle = knobStyle
            timerProgress?.shouldDrawMinValueKnob = true
            timerProgress?.startAngle = 270
            timerProgress?.style = .ontop
        }
        
        Threads.performTaskAfterDealy(1) {
            self.getSavedUserProfile()
        }
        //Event to check bluetooth connectivity
        SwiftEventBus.onMainThread(self, name: ViewEventListenerType.BLEConnectivityStream.rawValue) {_ in
            print("bleConnectivity called")
            self.checkBLEStatus()
            self.checkBLEConnectivityIndicator()
            self.checkAppTransistion()
            
            //let serial = Utilities.instance.getObjectFromUserDefaults(key: "serialNumber") as? String
            //self.updateDeviceConnectStatus(serial: serial ?? "", connected: false)
        }
        
        // Need to unregister event listener to avoid duplicate data stream
        SwiftEventBus.unregister(self, name: ViewEventListenerType.HomeDataStream.rawValue)
        
        //reloadProgressStatus(refresh: true)
        //self.requestPulseData(type: .Profile)
        
        //Event to check core data stream from bluetooth
        SwiftEventBus.onMainThread(self, name: ViewEventListenerType.HomeDataStream.rawValue) { [weak self] result in
            let obj = result?.object
            
            /* View States */
            
            if obj is [String: Any] {
                let _response = obj as? [String: Any]
                //print("obejct state changes", _response)
                
                let _refreshProgress = _response?["refreshProgress"]
                
//                if _refreshProgress != nil {
//                    self?.reloadProgressStatus(refresh: true)
//                }
                
            }
            
            
            /** CoreOne Data **/
            if obj is SPCoreObject {
                let _core = obj as? SPCoreObject
                self?.coreOneObject = _core
                
               //print("obj: ", _core?.MainTimerCycleSeconds)
               //print("runSwitchStatus: ", _core?.RunSwitch)
               //print("safetyStatus: ", _core?.SafetyStatus)
               //print("authenticated: ", _core?.UserAuthenticated)
                
                //PROGRESS INDICATORS
                let timeRemaining = NSNumber(value: _core?.MainTimerCycleSeconds ?? 3600)
                self?.progress = Double(Int(truncating: timeRemaining))
                
                self?.timerProgress?.startProgress(to: CGFloat(self?.progress ?? 0), duration:0.2)
                self?.sitStandProgress?.setProgressMaskLayer(to: Double(self?.progress ?? 0) / 3600, withAnimation: false)
                
                self?.isInteractive = _core?.UseInteractiveMode ?? false
                
                if _core?.EnableSafety == false {
                    let command = self?.SPCommand.GetEnableSafetyCommand()
                    self?.sendACommand(command: command ?? [UInt8](), name: "SPCommand.GetEnableSafetyCommand")
                }
                
                //AWAY and SAFETY Status
                
                Threads.performTaskAfterDealy(1) {
                    if _core?.SafetyStatus == false {
                        self?.safetyPopUpShowed = false
                    }
                }
                
                //print("self?.tempSafetyStatus: ", self?.tempSafetyStatus)
                
                self?.safetyStatus = _core?.SafetyStatus
                
                //print("hearts : StandHeightAdjusted", _core?.StandHeightAdjusted)
                //print("hearts : SitHeightAdjusted", _core?.SitHeightAdjusted)
                
                
                self?.awayStatus = _core?.AwayStatus
                self?.runSwitchStatus = _core?.RunSwitch
                self?.heightStatus = _core?.HeightSensorStatus
                self?.calibrationMode = _core?.AlternateCalibrationMode
                self?.alertnateATBMode = _core?.AlternateAITBMode
                
                if self?.awayStatus == true {
                    self?.setAwayImageStatus()
                } else if (self?.safetyStatus == true) {
                    self?.setSafetyStatus()
                } else if (self?.heightStatus == false) {
                    self?.checkHeightSensorStatus()
                } else if (self?.calibrationMode == true) {
                    self?.calibrationModeStatus()
                } else if (self?.alertnateATBMode == true) {
                    self?.automationModeStatus()
                } else if (_core?.DeskCurrentlyBooked) == true {
                    self?.checkAppTransistion()
                } else {
                    self?.getCurrentDeskMode()
                }
                
                if self?.progress == 3599.0 {
                    //self?.sitStandProgress?.clearAllLayers()
                    self?.addHeartProgress(value: 0.1, alertStatus: true)
                    
                }
                
                //print("_core?.NewProfileData : \(_core?.NewProfileData)")
                
                if _core?.NewProfileData == true {
                    self?.newProfileDetected = true
                    self?.requestPulseData(type: .Profile)
                    
                }
                
                if _core?.NewInfoData == true {
                    //.self?.requestPulseData(type: .Info)
                }
                
                //print("MovesreportedVertPos : ", _core?.MovesreportedVertPos)
                
                //MOVEMENT AND COUNTDOWN TIMER
                self?.nextMovementTitleText(movement: Int(_core?.NextMove ?? 4))
                if let offset = _core?.TimesreportedVertPos {
                    //print("timer offset: \(offset)")
                    //print("main timer offset: \(_core?.MainTimerCycleSeconds)")
                    #warning("enable to test timer not sync")
//                    guard _core?.MainTimerCycleSeconds != 0 else {
//                        self?.lblUpValue?.text = "00:00"
//                        return
//                    }
                    
                    let _timeOffset = offset - (_core?.MainTimerCycleSeconds ?? 0)
                    
                    if self?.safetyStatus == true || self?.awayStatus == true || self?.runSwitchStatus == false || self?.heightStatus == false || self?.calibrationMode == true || self?.alertnateATBMode == true {
                        let _watch = StopWatch(totalSeconds: _timeOffset)
                        
                        if offset == -1 {
                            self?.lblUpValue?.text = (offset == 3) ? "00:00" : String(format: "%.2d:%.2d", abs(_watch.minutes), 0)
                        } else {
                            self?.lblUpValue?.text = (offset == 3) ? "00:00" : String(format: "%.2d:%.2d", abs(_watch.minutes), abs(_watch.seconds))
                        }
                        
                        
                    } else {
                        if offset == 3 {
                            let _lastMove = self?.verticalMovementProfile?.movements.last
                            if (_lastMove != nil) {
                                let _newTime = 3599 - (_core?.MainTimerCycleSeconds ?? 0)
                                self?.updateCountdownTimer(timeOffset: _newTime)
                            } else {
                                self?.updateCountdownTimer(timeOffset: (offset == 3) ? 0 : _timeOffset)
                            }
                        } else {
                            self?.updateCountdownTimer(timeOffset: (offset == 3) ? 0 : _timeOffset)
                        }
                    }
                }
                
                //PENDING MOVEMENT AND COMMISSIONING
                let _pendinMove = _core?.PendingMove ?? 0
                self?.pendingMovementCode = _pendinMove
                self?.commissioningFlag = _core?.CommissioningFlag
                
                if self?.commissioningFlag == false {
                   self?.setCommissioningFlag()
                }
                
                if _pendinMove != 0 &&  self?.isInteractive == true {
                    self?.showInteractiveMovePopUp(movement: _pendinMove)
                } else {
                    if self?.interactivePopUpShowed ?? false {
                        self?.interactivePopUpShowed = false
                        self?.interactivePopUp.dismiss(animated: true, completion: nil)
                    }
                }
            }
             /*********************************************************************************************/
            
            /** VerticalProfile Data **/
            
            if obj is SPVerticalProfile {
                let _vm = obj as? SPVerticalProfile
                
                
                if (self?.newProfileDetected ?? true) {
                    print("newProfileDetected: \(self?.newProfileDetected ?? false)")
                    self?.savePulseData(profile: _vm ?? SPVerticalProfile(data: [UInt8](), rawString: "", notify: false))

                }
                
                if self?.verticalMovementProfile == nil {
                    self?.verticalMovementProfile = _vm
                    self?.sitStandProgress?.initWithProfile(movements:_vm ?? SPVerticalProfile(data: [UInt8](), rawString: "", notify: false))
                    self?.reloadProgressStatus(refresh: false)
                    
                } else {
                    if ((_vm?.movement0 == self?.verticalMovementProfile?.movement0)
                        && (_vm?.movement1 == self?.verticalMovementProfile?.movement1)
                        && (_vm?.movement2 == self?.verticalMovementProfile?.movement2)
                        && (_vm?.movement3 == self?.verticalMovementProfile?.movement3)) {
                        //self?.reloadProgressStatus(refresh: false)
                        print("_vm: ", _vm)
                        self?.sitStandProgress?.initWithProfile(movements:_vm ?? SPVerticalProfile(data: [UInt8](), rawString: "", notify: false))
                        self?.reloadProgressStatus(refresh: false)
                        
                    } else {
                        
                        if let _refresh = self?.refreshProgressProfile {
                            if _refresh == true {
                                self?.verticalMovementProfile = _vm
                                self?.sitStandProgress?.initWithProfile(movements:_vm ?? SPVerticalProfile(data: [UInt8](), rawString: "", notify: false))
                                self?.reloadProgressStatus(refresh: false)
                            }
                        }
                    }

                }
                
            }
            
            /*********************************************************************************************/
            
            /** ReportOne Data **/
            
            if obj is SPReport {
                let sensors = obj as? SPReport
                self?.lightIndicator?.level = self?.lightSensitivity(light: sensors?.PhotocellReading ?? 0, low: 200, high: 800, by: 100) ?? Level.noValue
                self?.soundIndicator?.level = self?.soundSensitivity(sound: sensors?.DbReading ?? 0) ?? Level.noValue
                self?.temperatureSensitivty(temp: sensors?.getReadablesTemp() ?? 0)
            }
            
             /*********************************************************************************************/
            
            /** Identifier Data **/
            
            if obj is SPIdentifier {
                let boxInformation = obj as? SPIdentifier
                print("serial number : ", Utilities.instance.compareAndUpdateSerial(serial: boxInformation?.SerialNumber ?? ""))
                if self?.boxIdentifier == nil {
                    self?.boxIdentifier = boxInformation
                    
                    if Utilities.instance.compareAndUpdateSerial(serial: boxInformation?.SerialNumber ?? "") == false {
                        Utilities.instance.saveDefaultValueForKey(value: String(format: "%@",boxInformation?.SerialNumber ?? ""), key: "serialNumber")
                        Utilities.instance.saveDefaultValueForKey(value: String(format: "%@",boxInformation?.RegistrationID ?? ""), key: "registrationID")
                        self?.updateDeviceConnectStatus(serial: boxInformation?.SerialNumber ?? "", registration: boxInformation?.RegistrationID ?? "",  connected: true)
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
            }
            
             /*********************************************************************************************/
        }
        
        #if targetEnvironment(simulator)
            self.imgNoProgress?.isHidden = true
            let profile = "14047045774c02da03f7026c03fc000c0000c23c"
            self.sitStandProgress?.initWithProfile(movements: SPVerticalProfile(data: "14047045774c027103f7026c03fc000c0000d80a".hexaBytes, rawString: "14047045774c027103f7026c03fc000c0000d80a", notify: false))
            //self.reloadProgressStatus(refresh: false)
          
        #endif
        
       
        
    }
    
    func reloadProgressStatus(refresh: Bool) {
        refreshProgressProfile = refresh
        heartProgressBg.animateActivityLoader(animate: false)
        
    }
    
    func savePulseData(profile: SPVerticalProfile) {
        
        guard Utilities.instance.typeOfUserLogged() != .None else {
            return
        }
        
        let dataHelper = SPRealmHelper()
        let serial = Utilities.instance.getObjectFromUserDefaults(key: "serialNumber") as? String ?? ""
        var identifier = UserDefaults.standard
            .object(forKey: peripheralIdDefaultsKey) as? String ?? ""
        let email = Utilities.instance.getLoggedEmail()
        var peripheralName = ""
        
        if let peripheral = SPBluetoothManager.shared.state.peripheral {
            peripheralName = peripheral.name ?? ""
            
            if identifier.isEmpty {
                identifier = peripheral.identifier.uuidString
            }
        }

        if dataHelper.pulseDeviceExists(email) == false {
            let device = ["Email": email,
                          "Identifier":identifier,
                          "Serial":serial,
                          "PeripheralName": peripheralName,
                          "UserProfile":profile.movementRawString,
                          "DisconnectedByUser":false,
                          "State":SPBluetoothManager.shared.pulse.rawValue] as [String : Any]
            SPRealmHelper.saveObject(from: device, primaryKey: email) { (result: Result<PulseDevices, Error>) in
                switch result {
                case .success:
                    //self.getSavedUserProfile()
                    break
                case .failure: break
                }
            }
        } else {
            let device = ["Identifier":identifier,
                          "Serial":serial,
                          "PeripheralName": peripheralName,
                          "UserProfile":profile.movementRawString,
                          "DisconnectedByUser": false,
                          "State":SPBluetoothManager.shared.pulse.rawValue] as [String : Any]
                    
            let update = dataHelper.updatePulseObject(device, email)
            
            if update == true {
                self.getSavedUserProfile()
            }
            
        }
        
        
        guard self.newProfileDetected else {
            return
        }
        
        newProfileDetected = false
        
        if dataHelper.profileExists(email) {
            
            let _movements = profile.movements.filter { (object) -> Bool in
                let _item = object as [String: Any]
                let _key = _item["key"] as? String ?? ""
                return _key == "4"
            }
            
            var standTime1 = 0
            var standTime2 = 0
            var profileSettingsType = 0
            
            if _movements.count == 1 {
                for item in _movements {
                    let val = item["value"] as? Int ?? 0
                    standTime1 = 60 - (val / 60)
                    
                    if standTime1 == 5 {
                        profileSettingsType = ProfileSettingsType.Active.rawValue
                    } else {
                        profileSettingsType = ProfileSettingsType.ModeratelyActive.rawValue
                    }
                }
            } else {
                for (idx, item) in _movements.enumerated() {
                    let val = item["value"] as? Int ?? 0
                    
                    if idx == 0 {
                        standTime1 = (val / 60)
                    } else {
                        standTime2 = abs((val / 60) - 60)
                    }
                }
                
                profileSettingsType = ProfileSettingsType.VeryActive.rawValue
            }
         
            print("standTime1: \(standTime1) | standTime2: \(standTime2)")
//            _ =  SPRealmHelper().updateUserProfileSettings(["StandingTime1":standTime1,
//                                                            "StandingTime2":standTime2,
//                                                            "ProfileSettingType":profileSettingsType],
//                                                           Utilities.instance.getLoggedEmail())
        }
        
    }
    
    func checkSitAndStandHeight() {
        
        guard SPDeviceConnected() && SPBluetoothManager.shared.desktopApphasPriority == false  else {
            return
        }
        
        let dataHelper = SPRealmHelper()
        let email = Utilities.instance.getLoggedEmail()
        if dataHelper.profileExists(email) {
            let _profile = dataHelper.getProfileSettings(email)
            
            self.showAlert(title: "generic.notice".localize(), message:"generic.desk_adjusted".localize())
            _ = PulseDataState.instance.adjustSittingAndStandHeights(profile: _profile)
        }
    }
    
    func nextMovementTitleText(movement: Int) {
        
        if movement == MovementType.DOWN.rawValue {
              self.lblUpDownTitle?.text = "Sit"
        } else {
            self.lblUpDownTitle?.text = "Stand"
        }
    }
    
    func nextMovementTitle(index: Int) {
        //GET NEXT MOVEMENT
        
        if self.verticalMovementProfile?.movements.item(at: index) != nil {
            let _movement = self.verticalMovementProfile?.movements.item(at: index)
            let _key = _movement?["key"] as? String
            
            if _key == MovementType.DOWN.movementRawString {
                self.lblUpDownTitle?.text = "Sit"
            } else {
                self.lblUpDownTitle?.text = "Stand"
            }
        } else {
            self.lblUpDownTitle?.text = "Sit"
        }
    }
    
    func checkBLEStatus() {
        
        guard !Utilities.instance.IS_FREE_VERSION else {
            let command = SPCommand.GenerateVerticalProfile(movements: Constants.profileProgressOffState)
            let _vm = SPVerticalProfile(data: command, rawString: "", notify: false)
            self.sitStandProgress?.initWithProfile(movements:_vm)
            self.setProgressState(enable: true)

            self.manualModeNotifier?.isHidden = true
            self.scheduler.suspend()
            return
        }
        

        if (SPBluetoothManager.shared.state.peripheral?.state == nil) ||
            (SPBluetoothManager.shared.state.peripheral?.state == .disconnecting) ||
            (SPBluetoothManager.shared.state.peripheral?.state == .disconnected) ||
            (SPBluetoothManager.shared.state.peripheral?.state == .connecting){

            self.dailyHearts = 0
            self.dailyHeartsTotal = 0
            
            self.setProgressState(enable: false)
            self.enableDisableSensor(enable: false)
            imgNoProgress?.image = UIImage(named: "ble_not_connected")
            heartProgressBg?.overAllMaskLayer.fillColor = UIColor(red: CGFloat(103/255.0), green: CGFloat(104/255.0), blue: CGFloat(105/255.0), alpha: 1.0).cgColor

            manualModeNotifier?.type = .continuous
            manualModeNotifier?.speed = .duration(30)
            manualModeNotifier?.textAlignment = .center
            manualModeNotifier?.text = "You are not connected on the device."
            self.manualModeNotifier?.isHidden = false
            self.scheduler.suspend()
        } else {
            //SPBluetoothManager.shared.startReceivingData = true
            
            self.currentDeskMode = Utilities.instance.getObjectFromUserDefaults(key: "desk_mode") as? String ?? "Manual"
            print("self.currentDeskMode: ", self.currentDeskMode)
            self.setDeskMode(mode: self.currentDeskMode)
            self.scheduler.resume()
            checkAppTransistion()
            
            //self?.updateDeviceConnectStatus(serial: boxInformation?.SerialNumber ?? "",registration: boxInformation?.RegistrationID ?? "", connected: true)
        }
    }
    
    func checkAppTransistion() {
        //check connectivity for desktop priority
        guard SPBluetoothManager.shared.desktopApphasPriority || PulseDataState.instance.isDeskCurrentlyBooked else {
            Utilities.instance.dismissStatusNotification()
            return
        }
        
        if (SPBluetoothManager.shared.desktopApphasPriority) {
            switch deviceSize {
                case .i4_7Inch, .i4Inch:
                    imgNoProgress?.image = UIImage.fontAwesomeIcon(name: .desktop,
                                                                   style: .solid,
                                                                   textColor: UIColor.white,
                                                                   size: CGSize(width: ((imgNoProgress?.frame.size.width) ?? 0) / 3, height: ((imgNoProgress?.frame.size.height) ?? 0)))
                    imgNoProgress?.contentMode = .scaleAspectFit


                default:
                    imgNoProgress?.image = UIImage.fontAwesomeIcon(name: .desktop,
                                                                   style: .solid,
                                                                   textColor: UIColor.white,
                                                                   size: CGSize(width: ((imgNoProgress?.frame.size.width) ?? 0) / 2, height: ((imgNoProgress?.frame.size.height) ?? 0)))
                    imgNoProgress?.contentMode = .scaleAspectFit


            }
            
            manualModeNotifier?.text = "generic.desktop_app_active".localize()
        }
        
        if PulseDataState.instance.isDeskCurrentlyBooked {
            switch deviceSize {
                case .i4_7Inch, .i4Inch:
                    imgNoProgress?.image = UIImage.fontAwesomeIcon(name: .calendarDay,
                                                                   style: .solid,
                                                                   textColor: UIColor.white,
                                                                   size: CGSize(width: ((imgNoProgress?.frame.size.width) ?? 0) / 3, height: ((imgNoProgress?.frame.size.height) ?? 0)))
                    imgNoProgress?.contentMode = .scaleAspectFit


                default:
                    imgNoProgress?.image = UIImage.fontAwesomeIcon(name: .calendarDay,
                                                                   style: .solid,
                                                                   textColor: UIColor.white,
                                                                   size: CGSize(width: ((imgNoProgress?.frame.size.width) ?? 0) / 2, height: ((imgNoProgress?.frame.size.height) ?? 0)))
                    imgNoProgress?.contentMode = .scaleAspectFit


            }
            
            manualModeNotifier?.text = "generic.desk_is_booked".localize()
           
        }
        
        
        self.setProgressState(enable: false)
        self.enableDisableSensor(enable: false)
        heartProgressBg?.overAllMaskLayer.fillColor = UIColor(hexString: Constants.smartpods_blue).cgColor


        self.manualModeNotifier?.isHidden = false
        manualModeNotifier?.type = .continuous
        manualModeNotifier?.speed = .duration(30)
        manualModeNotifier?.textAlignment = .center
        self.scheduler.suspend()
    }
    
    func setProgressState(enable: Bool) {
        if enable {
            guard self.refreshProgressProfile == false else {
                heartProgressBg?.overAllMaskLayer.fillColor = UIColor(red: CGFloat(30/255.0), green: CGFloat(176/255.0), blue: CGFloat(255/255.0), alpha: 0.2).cgColor
                imgNoProgress?.image = nil
                heartViewIndicator?.isHidden = false
                sitStandProgress?.isHidden  = true
                timerProgress?.isHidden = false
                timerProgress?.shouldDrawMinValueKnob = false
                return
            }
            
            //heartProgressBg?.overAllMaskLayer.fillColor = UIColor(red: CGFloat(30/255.0), green: CGFloat(176/255.0), blue: CGFloat(255/255.0), alpha: 0.2).cgColor
            heartProgressBg?.overAllMaskLayer.fillColor = UIColor.white.cgColor
            heartProgressBg?.animateActivityLoader(animate: false)
            imgNoProgress?.image = nil
            heartViewIndicator?.isHidden = false
            sitStandProgress?.isHidden  = false
            timerProgress?.isHidden = false
            timerProgress?.shouldDrawMinValueKnob = true
            
            
        } else {
            //timerProgress?.isHidden = true
            
            DispatchQueue.main.async {
                self.timerProgress?.isHidden = true
            }

            timerProgress?.resetProgress()
            timerProgress?.shouldDrawMinValueKnob = false
            heartViewIndicator?.isHidden = true
            sitStandProgress?.isHidden  = true
            lblUpValue?.text = "00:00"
            
            heartProgressBg?.overAllMaskLayer.fillColor = UIColor.white.cgColor
        }
    }
    
    func enableDisableSensor(enable: Bool) {
        if !enable {
            lblCelcius?.text = String(format: "°C", "")
            lblFarenheight?.text = String(format: "°F","")
            
            lightIndicator?.level = Level.noValue
            soundIndicator?.level = Level.noValue
        }
    }
    
    func enableDisableManualNotifier(enable: Bool) {
        
        if self.currentDeskMode == "Manual" {
            if enable {
                
                //MARQUEE LABEL
               manualModeNotifier?.type = .continuous
               manualModeNotifier?.speed = .duration(40)
               manualModeNotifier?.text = "We’ve noticed that your desk has been inactive for too long. To achieve the most benefit from your Smartpods workstation, we recommend you move at least twice each hour."
                self.manualModeNotifier?.isHidden = false
               }
            } else {
                self.manualModeNotifier?.isHidden = true
                progressTimer?.stop()
                guard marqueeTimer != nil else { return }
                marqueeTimer?.invalidate()
            }
    }
    
    func getCurrentDeskMode() {
        
        if self.coreOneObject != nil {
            
            if self.coreOneObject?.RunSwitch == false {
                Utilities.instance.saveDefaultValueForKey(value: "Manual", key: "desk_mode")
            }
            
            if self.coreOneObject?.RunSwitch == true && self.coreOneObject?.UseInteractiveMode == true {
                Utilities.instance.saveDefaultValueForKey(value: "Interactive", key: "desk_mode")
            }
            
            if self.coreOneObject?.RunSwitch == true && self.coreOneObject?.UseInteractiveMode == false {
                Utilities.instance.saveDefaultValueForKey(value: "Automatic", key: "desk_mode")
            }
            
            let mode  = Utilities.instance.getObjectFromUserDefaults(key: "desk_mode") as? String ?? "Manual"
            
            self.setDeskMode(mode: mode)
        }
        
    }
    
    func setAwayImageStatus() {
        setProgressState(enable: false)
        imgNoProgress?.image = UIImage(named: "user_not_detected")
        heartProgressBg?.overAllMaskLayer.fillColor = UIColor(hexString: Constants.smartpods_purple_circle).cgColor
        self.capturePresenceGesture(add: true, detailsTap: false)

        
        //MARQUEE LABEL
        manualModeNotifier?.speed = .duration(8.0)
        manualModeNotifier?.fadeLength = 15.0
        manualModeNotifier?.text = "User Not Detected"
        manualModeNotifier?.textAlignment = .center
        self.manualModeNotifier?.isHidden = false
    }
    
    func setSafetyStatus() {
        
        setProgressState(enable: false)
        imgNoProgress?.image = UIImage(named: "safety_triggered")
        heartProgressBg?.overAllMaskLayer.fillColor = UIColor(hexString: Constants.smartpods_yellow).cgColor
        self.addAcknowledgeStatusGesture(add: true, detailsTap: false)
        if self.safetyPopUpShowed == false {
            if let safety = self.safetyStatus {
                self.safetyPopUpShowed = true
                print("setSafetyStatus: ", safety)
                print("safetyPopUpShowed: ", safetyPopUpShowed)
                if safety{
                    
                    self.showSafetyStatusAlert(status: safety)
                }
                /*else {
                    print("safetyPopUpShowed set to false")
                    self.safetyPopUpShowed = false
                }*/
            }
        }
        /*else {
            print("safetyPopUpShowed set to false")
            //self.safetyPopUpShowed = false
        }*/
        
    }
    
    func setCommissioningFlag() {
        setProgressState(enable: false)
        imgNoProgress?.image = UIImage(named: "commissioning_required")
        heartProgressBg?.overAllMaskLayer.fillColor = UIColor(hexString: Constants.smartpods_red).cgColor
        self.addAcknowledgeStatusGesture(add: true, detailsTap: false)
        
        //MARQUEE LABEL
        manualModeNotifier?.speed = .duration(8.0)
        manualModeNotifier?.fadeLength = 15.0
        manualModeNotifier?.text = "Commissioning Required"
        manualModeNotifier?.textAlignment = .center
        self.manualModeNotifier?.isHidden = false
    }
    
    func checkHeightSensorStatus() {
        setProgressState(enable: false)
        imgNoProgress?.image = UIImage(named: "height_sensor_disconnected")
        heartProgressBg?.overAllMaskLayer.fillColor = UIColor(hexString: Constants.smartpods_red).cgColor
        self.addAcknowledgeStatusGesture(add: true, detailsTap: false)
        
        //MARQUEE LABEL
        manualModeNotifier?.speed = .duration(8.0)
        manualModeNotifier?.fadeLength = 15.0
        manualModeNotifier?.text = "Your height sensor is disconnected"
        manualModeNotifier?.textAlignment = .center
        self.manualModeNotifier?.isHidden = false
    }
    
    func calibrationModeStatus() {
        setProgressState(enable: false)
        imgNoProgress?.image = UIImage(named: "calibration_mode")
        heartProgressBg?.overAllMaskLayer.fillColor = UIColor(hexString: Constants.smartpods_orange).cgColor
        self.addAcknowledgeStatusGesture(add: true, detailsTap: false)
        
        //MARQUEE LABEL
        manualModeNotifier?.speed = .duration(8.0)
        manualModeNotifier?.fadeLength = 15.0
        manualModeNotifier?.text = "Auto-Calibration Mode"
        manualModeNotifier?.textAlignment = .center
        self.manualModeNotifier?.isHidden = false
    }
    
    func automationModeStatus() {
        setProgressState(enable: false)
        imgNoProgress?.image = UIImage(named: "automation")
        heartProgressBg?.overAllMaskLayer.fillColor = UIColor(hexString: Constants.smartpods_green).cgColor
        //self.addAcknowledgeStatusGesture(add: true, detailsTap: false)
        
        //MARQUEE LABEL
        manualModeNotifier?.speed = .duration(8.0)
        manualModeNotifier?.fadeLength = 15.0
        manualModeNotifier?.text = "Automation-in-a-Box Mode"
        manualModeNotifier?.textAlignment = .center
        self.manualModeNotifier?.isHidden = false
    }
    
    func deskVacantStatus() {
           setProgressState(enable: false)
           imgNoProgress?.image = UIImage(named: "desk_vacant")
           heartProgressBg?.overAllMaskLayer.fillColor = UIColor(hexString: Constants.smartpods_light_green).cgColor
           self.addAcknowledgeStatusGesture(add: true, detailsTap: false)
           
           //MARQUEE LABEL
           manualModeNotifier?.speed = .duration(8.0)
           manualModeNotifier?.fadeLength = 15.0
           manualModeNotifier?.text = "Desk Vacant"
           manualModeNotifier?.textAlignment = .center
           self.manualModeNotifier?.isHidden = false
       }
    
    func setManualModeStatus() {
        setProgressState(enable: false)
        enableDisableManualNotifier(enable: true)
        imgNoProgress?.image = UIImage(named: "manual_mode")
        heartProgressBg?.overAllMaskLayer.fillColor = UIColor(hexString: Constants.smartpods_blue).cgColor
    }
    
    func setDeskMode(mode: String) {
        if mode == "Automatic" {
            setProgressState(enable: true)
            manualModeNotifier?.isHidden = true
            self.imgDeskMode?.image = UIImage(named: "automatic")
        }
        
        if mode == "Interactive" {
            setProgressState(enable: true)
            manualModeNotifier?.isHidden = true
            self.imgDeskMode?.image = UIImage(named: "interactive")
        }
        
        if mode == "Manual" {
            DispatchQueue.main.async {
                self.imgDeskMode?.image = UIImage(named: "manual")
            }
            setManualModeStatus()
        }
    }
    
    func showInteractiveMovePopUp(movement: Int) {
        interactivePopUp.nextMove = movement
        
        if movement != 0 {
            if interactivePopUpShowed == false {
                interactivePopUpShowed = true
                if #available(iOS 13.0, *) {
                    interactivePopUp.isModalInPresentation = true
                } else {
                    interactivePopUp.modalPresentationStyle = .fullScreen
                }
                
                DispatchQueue.main.async(execute: {
                    self.present(self.interactivePopUp, animated: true, completion: nil)
                })
                
            } else {
                interactivePopUp.isShowing = false
            }
        } else {
            interactivePopUp.dismiss(animated: true, completion: nil)
        }
    }
    
    func addHeartProgress(value: Double, alertStatus: Bool) {

        guard SPDeviceConnected() && SPBluetoothManager.shared.desktopApphasPriority == false  else {
            return
        }
        
        heartViewIndicator?.progress += value
        self.dailyHearts += value
        print("heartViewIndicator?.progress: \(heartViewIndicator?.progress)")
        
        if heartViewIndicator?.progress ?? 0 >= 1.0 {
            
            if alertStatus {
                self.heartProgressFillUp()
            }
            self.dailyHeartsTotal += 1
            self.dailyHearts = 0
            heartViewIndicator?.progress = 0
            self.viewModel?.saveHeartsAccumulated()
            
            guard Utilities.instance.typeOfUserLogged() == .Guest else {
                return
            }
            
            refreshHeartsDailyAndTotal(today: self.dailyHearts,
                                       total: self.dailyHeartsTotal)
        }
    }
    
    func heartProgressFillUp() {
        
        guard Utilities.instance.isLoggedIn() || Utilities.instance.isGuest else {
            return
        }
        
        self.showAlert(title: "generic.congratulations".localize(), message: "hear_progress.heart_fills_up".localize())
        
    }
    
    func lightSensitivity(light: Int, low: Int, high: Int, by: Int) -> Level {
        var rangeValue = 0
        var ranges = [[Int]]()
        for value in stride(from: low, to: high, by: by) {
            //print("range:\(rangeValue) value: \(value)")
            let _range = [rangeValue,value]
            ranges.append(_range)
            rangeValue = value
        }
        
        //print("ranges:",ranges)
        
        switch light {
            case 0...200:
                return .low
            case 200...400:
                return .good
            case 400...600:
                return .veryGood
            case 600...800:
                return .excellent
            default:
                return .noValue
        }
        
    }
    
    func soundSensitivity(sound: Int) -> Level {
        switch sound{
            case 0...20:
                return .low
            case 20...40:
                return .good
            case 40...60:
                return .veryGood
            case 60...100:
                return .excellent
            default:
                return .noValue
        }
    }
    
    func temperatureSensitivty(temp: Int) {
        let farenheight = temp * 9 / 5 + 32
        lblCelcius?.text = String(format: "%d °C", temp)
        lblFarenheight?.text = String(format: "%d °F",farenheight)
    }
    
    func updateCountdownTimer(timeOffset: Int) {
        let _watch = StopWatch(totalSeconds: timeOffset)
        //print("_watch: ", _watch)
        
        if timeOffset == 3599 {
            self.lblUpValue?.text = "00:00"
        } else {
            self.lblUpValue?.text = String(format: "%.2d:%.2d", abs(_watch.minutes), abs(_watch.seconds))
        }
        
    }
    
    func updateProgress() {
        let timeRemaining = NSNumber(value: self.coreOneObject?.MainTimerCycleSeconds ?? 3600)
        var progress = 0.0
        
        timerProgress?.maxValue = CGFloat(truncating: timeRemaining)
        
        progressTimer = AsyncTimer(
            interval: .seconds(1),
            times: Int(truncating: timeRemaining),
            block: { [weak self] value in
                progress += 1.0
                print("progress:", progress)
                self?.timerProgress?.startProgress(to: CGFloat(progress), duration:0.2)
                self?.sitStandProgress?.setProgressMaskLayer(to: progress/Double(truncating: timeRemaining), withAnimation: false)
            }, completion: { 
                print("finished")
            }
        )
        progressTimer?.start()
    }
    
    func addHeartDetailsGesture(add: Bool) {
        if add {
            self.detailsTapGesture = UITapGestureRecognizer(target: self, action: #selector(showHeartStatsDetails(_:)))
            self.detailsTapGesture.numberOfTapsRequired = 1
            //viewContainer?.addGestureRecognizer(detailsTapGesture)
            viewContainer?.addGestureRecognizer(detailsTapGesture)
        } else {
            viewContainer?.removeGestureRecognizer(detailsTapGesture)
        }
    }
    
    func addAcknowledgeStatusGesture(add: Bool, detailsTap: Bool) {
        indicatorStatus = detailsTap
        if add {
            self.addHeartDetailsGesture(add: false)
            self.acknowledgeGesture = UITapGestureRecognizer(target: self, action: #selector(acknowledgeStatus(_:)))
            self.acknowledgeGesture.numberOfTapsRequired = 1
            self.viewContainer?.addGestureRecognizer(self.acknowledgeGesture)
        } else {
            self.viewContainer?.removeGestureRecognizer(self.acknowledgeGesture)
            Threads.performTaskAfterDealy(1.0) {
                if detailsTap {
                    self.addHeartDetailsGesture(add: true)
                    print("enable tap details")
                }
            }
        }
    }
    
    func capturePresenceGesture(add: Bool, detailsTap: Bool) {
        indicatorStatus = detailsTap
        if add {
            self.addHeartDetailsGesture(add: false)
            self.acknowledgeGesture = UITapGestureRecognizer(target: self, action: #selector(capturePresenceDetection(_:)))
            self.acknowledgeGesture.numberOfTapsRequired = 1
            self.viewContainer?.addGestureRecognizer(self.acknowledgeGesture)
        } else {
            self.viewContainer?.removeGestureRecognizer(self.acknowledgeGesture)
            Threads.performTaskAfterDealy(1.0) {
                if detailsTap {
                    self.addHeartDetailsGesture(add: true)
                    print("enable tap details")
                }
            }
        }
    }
    
    @objc func showHeartStatsDetails(_ sender: UITapGestureRecognizer) {
        
        guard !Utilities.instance.IS_FREE_VERSION else {
            return
        }
        
        guard (Utilities.instance.typeOfUserLogged() != .None || Utilities.instance.typeOfUserLogged() != .Guest) else {
            return
        }
        
        let controller: HeartStatDetailsController = HeartStatDetailsController.instantiateFromStoryboard(storyboard: "Home") as! HeartStatDetailsController
        controller.homeProtocol = self.homeProtocol
        self.navigationController?.pushViewController(controller, animated: false)
    
    }
    
    @objc func acknowledgeStatus(_ sender: UITapGestureRecognizer) {
        let command = self.SPCommand.GetAknowledgeSafetyCommand()
        self.sendACommand(command: command, name: "SPCommand.GetAknowledgeSafetyCommand")
        indicatorStatus = false
        self.addAcknowledgeStatusGesture(add: false, detailsTap: true)
        
    }
    
    @objc func capturePresenceDetection(_ sender: UITapGestureRecognizer) {
        self.requestPulseData(type: .NeedPresence)
        indicatorStatus = false
        self.addAcknowledgeStatusGesture(add: false, detailsTap: true)
        
    }

    @objc func changeDeskMode(_ sender: UITapGestureRecognizer) {
//        let command = SPRequestParameters.GetAESKey
//        sendACommand(command: command, name: "SPRequestParameters.GetAESKey")
        heartStatsDelegate?.redirectToDeskModeChange()
    }
    
    @IBAction func onBtnActions(sender: UIButton) {
        switch sender.tag {
        case 0:
            let controller: ListStarsController = ListStarsController.instantiateFromStoryboard(storyboard: "Home") as! ListStarsController
            self.navigationController?.pushViewController(controller, animated: false)
        default: break
        }
    }
}

extension HeartStatsController{
    override func shouldSetDeviceConnected(connected: Bool) {
        print("function overriden by HeartStatsController")
        Threads.performTaskInMainQueue {
            //self.checkBLEStatus()
            //self.checkBLEConnectivityIndicator()
            let serial = Utilities.instance.getObjectFromUserDefaults(key: "serialNumber") as? String
            let registrationID = Utilities.instance.getObjectFromUserDefaults(key: "registrationID") as? String
            self.updateDeviceConnectStatus(serial: serial ?? "",registration: registrationID ?? "", connected: false)
            
//            if connected {
//                self.requestProfileSettingsIfAvailable()
//            }
        }
    }
    
    override func deviceNotInRange() {
        print("heart stats not in range")
    }
    
    func getBookingInfoAndUpdateDeviceConnect() {
        if SPDeviceConnected() {
            let serial = Utilities.instance.getObjectFromUserDefaults(key: "serialNumber") as? String
            let registrationID = Utilities.instance.getObjectFromUserDefaults(key: "registrationID") as? String
            self.updateDeviceConnectStatus(serial: serial ?? "",registration: registrationID ?? "", connected: false)
        }
    }
    
}

extension HeartStatsController: SPBluetoothManagerDelegate {
    
    func updateInterface() {
        print("HeartStatsController : updateInterface")
    }
    
    func unableToPairWithBox() {
        
    }
    
    func updateDeviceConnectivity(connect: Bool) {
        DispatchQueue.main.async {
            self.checkBLEConnectivityIndicator()
            self.checkBLEStatus()
            
            self.getBookingInfoAndUpdateDeviceConnect()
            
        }
    }
    
    func connectivityState(title: String, message: String, code: Int) {
        self.showAlert(title: title, message: message)
    }
    
    func deviceConnected() {
       
    }

}
