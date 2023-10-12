//
//  UserProfileController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-22.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Material
//import RLBAlertsPickers
import Foundation
import FontAwesome_swift
import ScrollingContentViewController
import IQKeyboardManagerSwift

class UserProfileController: BaseController {
    
    //STORYBOARD OUTLETS
    
    @IBOutlet weak var contentScroll: UIScrollView?
    @IBOutlet weak var viewContent: UIView?
    @IBOutlet weak var contentStack: UIStackView?
    
    @IBOutlet weak var lblNameTitle: UILabel?
    @IBOutlet weak var txtFirstname: UITextField?
    @IBOutlet weak var lblEmailTitle: UILabel?
    @IBOutlet weak var txtLastname: UITextField?
    @IBOutlet weak var lblGenderTitle: UILabel?
    @IBOutlet weak var txtGender: UITextField?
    @IBOutlet weak var lblYearTitle: UILabel?
    @IBOutlet weak var txtYear: UITextField?
    @IBOutlet weak var lblHeight: UILabel?
    @IBOutlet weak var txtHeight: UITextField?
    @IBOutlet weak var lblWeight: UILabel?
    @IBOutlet weak var txtWeight: UITextField?
    @IBOutlet weak var lblLifestyleTitle: UILabel?
    @IBOutlet weak var btnLifestyle: UIButton?
    @IBOutlet weak var txtLifestyle: UITextField?
    @IBOutlet weak var txtDepartment: UITextField?
    
    @IBOutlet weak var btnGender: UIButton?
    
    @IBOutlet weak var lblEstCalorie: UILabel?
    @IBOutlet weak var lblBMI: UILabel?
    @IBOutlet weak var lblBMR: UILabel?
    @IBOutlet weak var lblCalorieCount: UILabel?
    @IBOutlet weak var lblBMICount: UILabel?
    @IBOutlet weak var lblBMRCount: UILabel?
    
    @IBOutlet weak var btnCalorie: UIButton?
    @IBOutlet weak var btnBMI: UIButton?
    @IBOutlet weak var btnBMR: UIButton?
    
    @IBOutlet weak var btnSave: UIButton?
    @IBOutlet weak var btnCloud: UIButton?
    
    @IBOutlet weak var btnConvertHeight: UIButton?
    @IBOutlet weak var btnConvertWeight: UIButton?
    @IBOutlet weak var btnDepartment: UIButton?
    var height: Int = 0
    var weight: Double = 0
    
    var selectedUnitHeight: String = "cm"
    var selectedUnitWeight: String = "kg"
    
    var bmiValue: Double =  0.0
    var bmrValue: Double = 0.0
    var calorieValue: Double = 0.0
    var userStandingPosition: Int = 0
    
    //CLASS VARIABLES
    var viewModel: UserViewModel?
    var profileViewModel: ProfileSettingsViewModel?
    var departments: Departments?
    var gender: Int = -1
    var lifestyle: Int = -1
    var departmentId: Int = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let email = Utilities.instance.getUserEmail()
        createCustomNavigationBar(title: "userProfile.title".localize(), user: email, cloud: true, back: false, ble: true)
        let contentInsets = UIEdgeInsets.zero
        contentScroll?.contentInset = contentInsets
        contentScroll?.scrollIndicatorInsets = contentInsets
        customizeUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getUser()
    }
    
    override func customizeUI() {
        
        switch deviceSize {
        case .i4Inch, .i4_7Inch:
                contentScroll?.contentInset = UIEdgeInsets.zero
                contentScroll?.scrollIndicatorInsets = UIEdgeInsets.zero
                contentScroll?.addSubview(contentStack ?? UIStackView())
                contentStack?.translatesAutoresizingMaskIntoConstraints = false
                
                contentStack?.leadingAnchor.constraint(equalTo: contentScroll?.leadingAnchor ?? NSLayoutXAxisAnchor(), constant: 10).isActive = true
                contentStack?.trailingAnchor.constraint(equalTo: contentScroll?.trailingAnchor ?? NSLayoutXAxisAnchor(), constant: 10).isActive = true
                contentStack?.topAnchor.constraint(equalTo: contentScroll?.topAnchor ?? NSLayoutYAxisAnchor() , constant: 10).isActive = true
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
                contentStack?.topAnchor.constraint(equalTo: viewContent?.topAnchor ?? NSLayoutYAxisAnchor(), constant: 5).isActive = true
                contentStack?.bottomAnchor.constraint(equalTo: viewContent?.bottomAnchor ?? NSLayoutYAxisAnchor()).isActive = true

                contentStack?.centerXAnchor.constraint(equalTo: viewContent?.centerXAnchor ?? NSLayoutXAxisAnchor()).isActive = true
                contentStack?.centerYAnchor.constraint(equalTo: viewContent?.centerYAnchor ?? NSLayoutYAxisAnchor()).isActive = true
                contentStack?.widthAnchor.constraint(equalTo: viewContent?.widthAnchor ?? NSLayoutDimension(), constant: -20).isActive = true
        }
        
        
        txtFirstname?.textColor = UIColor(hexString: Constants.smartpods_gray)
        txtFirstname?.font = UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_textfield_size_small)
        
        txtLastname?.textColor = UIColor(hexString: Constants.smartpods_gray)
        txtLastname?.font = UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_textfield_size_small)
        
        txtGender?.textColor = UIColor(hexString: Constants.smartpods_gray)
        txtGender?.font = UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_textfield_size_small)
        
        txtYear?.textColor = UIColor(hexString: Constants.smartpods_gray)
        txtYear?.font = UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_textfield_size_small)
        
        txtHeight?.textColor = UIColor(hexString: Constants.smartpods_gray)
        txtHeight?.font = UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_textfield_size_small)
        
        txtWeight?.textColor = UIColor(hexString: Constants.smartpods_gray)
        txtWeight?.font = UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_textfield_size_small)
        
        txtLifestyle?.textColor = UIColor(hexString: Constants.smartpods_gray)
        txtLifestyle?.font = UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_textfield_size_small)
        
        txtDepartment?.textColor = UIColor(hexString: Constants.smartpods_gray)
        txtDepartment?.font = UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_textfield_size_small)
        
        btnGender?.setImage(UIImage.fontAwesomeIcon(name: .caretDown,
                                                    style: .solid,
                                                    textColor: UIColor(hexString: Constants.smartpods_gray),
                                                    size: CGSize(width: 20, height: 20)), for: .normal)
        
        btnLifestyle?.setImage(UIImage.fontAwesomeIcon(name: .caretDown,
                                                       style: .solid,
                                                       textColor: UIColor(hexString: Constants.smartpods_gray),
                                                       size: CGSize(width: 20, height: 20)), for: .normal)
        
        btnDepartment?.setImage(UIImage.fontAwesomeIcon(name: .caretDown,
                                                       style: .solid,
                                                       textColor: UIColor(hexString: Constants.smartpods_gray),
                                                       size: CGSize(width: 20, height: 20)), for: .normal)
        
        btnConvertHeight?.setImage(UIImage.fontAwesomeIcon(name: .syncAlt,
                                                       style: .solid,
                                                       textColor: UIColor(hexString: Constants.smartpods_gray),
                                                       size: CGSize(width: 20, height: 20)), for: .normal)
        
        btnConvertWeight?.setImage(UIImage.fontAwesomeIcon(name: .syncAlt,
                                                           style: .solid,
                                                           textColor: UIColor(hexString: Constants.smartpods_gray),
                                                           size: CGSize(width: 20, height: 20)), for: .normal)
        
        lblNameTitle?.adjustContentFontSize()
        lblEmailTitle?.adjustContentFontSize()
        lblGenderTitle?.adjustContentFontSize()
        lblYearTitle?.adjustContentFontSize()
        lblHeight?.adjustContentFontSize()
        lblWeight?.adjustContentFontSize()
        lblLifestyleTitle?.adjustContentFontSize()
        btnLifestyle?.titleLabel?.adjustContentFontSize()
        btnGender?.titleLabel?.adjustContentFontSize()
        lblEstCalorie?.adjustContentFontSize()
        lblBMI?.adjustContentFontSize()
        lblBMR?.adjustContentFontSize()
        lblCalorieCount?.adjustNumberFontSize()
        lblBMICount?.adjustNumberFontSize()
        lblBMRCount?.adjustNumberFontSize()
        btnSave?.titleLabel?.adjustContentFontSize()
        
        btnCalorie?.titleLabel?.adjustContentFontSize()
        btnBMI?.titleLabel?.adjustContentFontSize()
        btnBMR?.titleLabel?.adjustContentFontSize()
        
        
        txtFirstname?.adjustContentFontSize()
        txtLastname?.adjustContentFontSize()
        txtGender?.adjustContentFontSize()
        txtYear?.adjustContentFontSize()
        txtHeight?.adjustContentFontSize()
        txtWeight?.adjustContentFontSize()
        txtLifestyle?.adjustContentFontSize()
        txtDepartment?.adjustContentFontSize()
        
        txtHeight?.keyboardType = .numbersAndPunctuation
        txtHeight?.smartQuotesType = .no
        txtHeight?.delegate = self
        txtHeight?.addDoneOnKeyboardWithTarget(self, action: #selector(handleKeyboardDismiss(textField:)))
        txtWeight?.addDoneOnKeyboardWithTarget(self, action: #selector(calculateWeight(textField:)))
        
        
    }
    
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
    }
        
    override func bindViewModelAndCallbacks() {
        self.viewModel = UserViewModel()
        self.profileViewModel = ProfileSettingsViewModel()
        
        if self.viewModel?.department == nil {
            self.viewModel?.getDepartmentLists({ (object) in
                if object is Departments {
                    let _object = object as! Departments
                    self.departments = _object
                   
                }
                
            })
        }
        
        profileViewModel?.forceLogout = { [weak self] () in
            self?.logoutUser(useGuest: false)
        }
        
        viewModel?.alertMessage = { [weak self](title: String, message: String, tag: Int) in
            self?.displayStatusNotification(title: message, style: .danger)
        }

        viewModel?.showIndicator = { [weak self] (show: Bool) in
            self?.showActivityIndicator(show: show)
        }
        
        profileViewModel?.alertMessage = { [weak self](title: String, message: String, tag: Int) in
            
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
        
        profileViewModel?.apiCallback = { [weak self] (_ response : Any, _ status: Int) in
            if status == 6 {
                self?.showAlertWithAction(title: "generic.notice".localize(),
                                          message: "generic.invalid_session".localize(),
                                          buttonTitle: "common.ok".localize(), buttonAction: {
                                            self?.logoutUser(useGuest: false)
                                          })
            }
        }
    }
    
    func getUser() {
        
        guard !Utilities.instance.isGuest else {
            return
        }
        
        profileViewModel?.getProfileSettings(completion: { [weak self] object in
            self?.userStandingPosition = object.StandingTime1 + object.StandingTime2
        })
        
        let reachable = reachability?.isReachable ?? false
        if  reachable{
           refreshProfile()
        } else {
          requestUserObject()
        }
    }
    
    func refreshProfile() {
        viewModel?.getDepartmentLists({ (departments) in
            
        })
        
        
        viewModel?.getUserInformation(completion: { [weak self] object in
           //update box
            // refresh data
            if object is User {
                let _obejct = object as! User
                self?.updateUserObject(object: _obejct)
                //self?.requestUserObject()
                
            }
        })
    }
    
    func requestUserObject() {
        viewModel?.getLocalUserInformation(completion: { [weak self] object in
            self?.updateUserObject(object: object)
        })
    }
    
    func updateUserObject(object: User) {
        self.height = object.Height
            self.weight = object.Weight
        
            self.selectedUnitHeight = "cm"
            self.selectedUnitWeight = "kg"
            
            self.txtFirstname?.text = object.Firstname
            self.txtLastname?.text = object.Lastname
            self.txtHeight?.text = (object.Height == 0) ? "" : String(format: "%d %@",object.Height, self.selectedUnitHeight )
            self.txtWeight?.text = (object.Weight == 0) ? "" : String(format: "%.0f %@",object.Weight, self.selectedUnitWeight )
            self.txtYear?.text = (object.YearOfBirth == 0) ? "" : String(format: "%d",object.YearOfBirth)
            self.txtGender?.text = Gender(rawValue: object.Gender)?.stringRepresentation
            self.txtLifestyle?.text = LifeStyle(rawValue: object.LifeStyle)?.stringRepresentation
            self.lblBMICount?.text = String(format: "%.0f",object.BMI)
            self.lblBMRCount?.text = String(format: "%.0f",object.BMR)
            
            self.gender = object.Gender
            self.lifestyle = object.LifeStyle
            
            
            self.setUserDepartment(deptId: object.DepartmentID)
            
            self.calorieValue = 0
            self.bmiValue = object.BMI
            self.bmrValue = object.BMR
            
            self.updateUI()
        
    }
    
    func updateUI() {
        //
        self.btnBMI?.titleLabel?.text = String(format: "%.0f",bmiValue)
        self.btnBMR?.titleLabel?.text = String(format: "%.0f",bmrValue)
        calculateCalories()
    }
    
    func setUserDepartment(deptId: Int) {
        self.departmentId = deptId
        
        if self.viewModel?.department != nil {
            let _department = self.viewModel?.department?.Departments.filter({ (list) -> Bool in
                return (list).ID == deptId
            })
            
            if _department?.count ?? 0 > 0 {
                let _departmentName = _department?[0].Name
                self.txtDepartment?.text = _departmentName
            }
        }
        
    }
    
    func calculateCalories() {
        
        var calories: Double = 0.0
        let standingMinutes = self.userStandingPosition * Constants.hoursPerDayActivity
        
        if self.bmrValue >= 0 {
            calories = (self.bmrValue / (60 * 24)) * Double(standingMinutes)
        } else {
            calories = (0.095 * (Double(self.weight) + 3.1)) * Constants.kiloJoulsToKiloCalories * Double(standingMinutes)
        }
        
        self.calorieValue = calories
        self.lblCalorieCount?.text =  String(format: "%.0f",calories)
        
    }
    
    @IBAction func onBtnActions(sender: UIButton) {
        switch sender.tag {
            case 0:
                let _height = txtHeight?.text
                let _weight = txtWeight?.text
                
                var height_ = "0"
                var weight_ = "0"
                
                //convert height to cm before submitting to API
                if self.selectedUnitHeight == "ft,in" {
                    self.selectedUnitHeight = "cm"
                    let _text = _height ?? "0z"
                    let _filtered = Utilities.instance.filterRawData(raw: _text, char: [","])
                    let _measurement = _filtered.split(separator: "'")
                    let  _converted = _measurement.map { String($0) }
                    
                    let _feet = Int(_converted.item(at: 0) ?? "0") ?? 0
                    let _inches = Int(_converted.item(at: 1) ?? "0") ?? 0
                    
                    height_ = self.convertCmFromFootAndInches(_feet, inches: _inches)
                } else {
                    height_ = _height?.onlyDigitsInString ?? "0"
                }
                
                //convert weight to kg before submitting to API
                if self.selectedUnitWeight == "lbs" {
                    self.selectedUnitWeight = "kg"
                    let _current = Int(_weight?.onlyDigitsInString ?? "0")
                    weight_ = self.convertLbsFromFkgs(Double(_current ?? 0))
                } else {
                    weight_ = _weight?.onlyDigitsInString ?? "0"
                }
                
                let _params = ["Firstname": txtFirstname?.text ?? "",
                               "Lastname": txtLastname?.text ?? "",
                               "Weight":  self.weight, //weight_.onlyDigitsInString,
                               "Height": self.height, //height_.onlyDigitsInString,
                               "YearOfBirth": txtYear?.text ?? "",
                               "Gender": Gender(rawValue: self.gender)?.genderParameter ?? "0",
                               "LifeStyle": String(format: "%d",self.lifestyle),
                               "DepartmentID": String(format: "%d",self.departmentId)] as [String : Any]
                
                viewModel?.updateUserInformation(params: _params , completion: { [weak self] (object,success)  in
                    self?.displayNotificationMessage(title: "success.title".localize(), subTitle: "success.profile_updated".localize(), style: .success)
                    self?.requestUserObject()
                })
                
                break
            
            case 1:
                self.displayAlert(title: "calorie.title".localize(), message: "calorie.content".localize())
            case 2:
                let controller = BMIInfoController.instantiateFromStoryboard(storyboard: "Home") as! BMIInfoController

                let alert = UIAlertController(style: .alert, title: "Body Mass Index")
                controller.preferredContentSize.height = CGFloat(300)
                alert.setValue(controller, forKey: "contentViewController")
                alert.addAction(title: "OK", style: .cancel)
                
            
                Threads.performTaskInMainQueue {
                    //self.presentPanModal(controller)
                    alert.show()
                }
            case 3:
                self.displayAlert(title: "bmr.title".localize(), message: "bmr.content".localize())
            case 10:
                showActionSheet(type: .GENDER)
                break
            case 11:
                showActionSheet(type: .LIFESTYLE)
            case 12:
                showActionSheet(type: .HEIGHT)
                break
            case 13:
                showActionSheet(type: .WEIGHT)
                break
            case 14:
                self.chooseAndUpdateDepartmentList(shouldUpdate: false) { (object) in
                    self.departmentId = object.ID
                    self.setUserDepartment(deptId: object.ID)
                }
            default:
                break
        }
    }

    func showActionSheet(type: ActionSheetType) {
        
        let alert = UIAlertController(style: .actionSheet, title: "userProfile.action_sheet_title".localize())
        alert.setTitle(font: UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_text_size_small) ?? UIFont(), color: UIColor(hexString: Constants.smartpods_gray))

        switch type {
            case .GENDER:
                
                alert.addAction(title: Gender.MALE.stringRepresentation, style: .default) { [weak self] action in
                    self?.txtGender?.text = Gender.MALE.stringRepresentation
                    self?.gender = Gender.MALE.rawValue
                }
                alert.addAction(title: Gender.FEMALE.stringRepresentation, style: .default){ [weak self] action in
                    self?.txtGender?.text = Gender.FEMALE.stringRepresentation
                    self?.gender = Gender.FEMALE.rawValue
                }
            break
            case .LIFESTYLE:
                alert.addAction(title: LifeStyle.Sedentary.stringRepresentation, style: .default) { [weak self] action in
                    self?.txtLifestyle?.text = LifeStyle.Sedentary.stringRepresentation
                    self?.lifestyle = LifeStyle.Sedentary.rawValue
                }
                
                alert.addAction(title: LifeStyle.ModeratelyActive.stringRepresentation, style: .default) { [weak self] action in
                    self?.txtLifestyle?.text = LifeStyle.ModeratelyActive.stringRepresentation
                    self?.lifestyle = LifeStyle.ModeratelyActive.rawValue
                }
                
                alert.addAction(title: LifeStyle.VeryActive.stringRepresentation, style: .default) { [weak self] action in
                    self?.txtLifestyle?.text = LifeStyle.VeryActive.stringRepresentation
                    self?.lifestyle = LifeStyle.VeryActive.rawValue
                }
            break
            case .HEIGHT:
                
                alert.addAction(title: "Centimeters", style: .default) { [weak self] action in
                    self?.selectedUnitHeight = "cm"
                    let _current  = Double(Int(self?.height ?? 0))
                    let heightInCm = Measurement(value: Double(_current ), unit: UnitLength.centimeters)
                    print(heightInCm.heightOnFeetsAndInches ?? "")
                    self?.txtHeight?.text = LengthFormatters.imperialLengthFormatter.string(fromValue: heightInCm.value, unit: LengthFormatter.Unit.centimeter)
                }
                alert.addAction(title: "Feet and Inches", style: .default){ [weak self] action in
                    self?.selectedUnitHeight = "ft,in"
                    let _current  = Double(Int(self?.height ?? 0))
                    let heightInCm = Measurement(value: Double(_current), unit: UnitLength.centimeters)
                    let convertedToFeet = heightInCm.converted(to: .feet)
                    self?.txtHeight?.text = self?.feetToFeetInches(convertedToFeet.value)
                }

            break
            case .WEIGHT:
                alert.addAction(title: "Kilogram", style: .default) { [weak self] action in
                    if self?.selectedUnitWeight == "lbs" {
                        self?.selectedUnitWeight = "kg"
                        let _current  = self?.weight
                        let weightInKg = Measurement(value: _current ?? 0, unit: UnitMass.kilograms)
                        self?.txtWeight?.text = MassFormatter().string(fromValue: weightInKg.value, unit: .kilogram)
                    }
                }
                alert.addAction(title: "Pounds", style: .default){ [weak self] action in
                    if self?.selectedUnitWeight == "kg" {
                         self?.selectedUnitWeight = "lbs"
                        
                        let _current  = self?.weight
                        let weightInKg = Measurement(value: _current ?? 0, unit: UnitMass.kilograms)
                        let convertToPounds = weightInKg.converted(to: .pounds)
                        
                        self?.txtWeight?.text = MassFormatter().string(fromValue: convertToPounds.value.roundToDecimal(0), unit: .pound)
                     }
                }
            break
        }
        
        alert.addAction(title: "common.cancel".localize(), style: .cancel)
        alert.show()
    }
    
    func calculateUserHeight(unit: String, data: String) -> String {
        if unit == "ft,in" {
            self.selectedUnitHeight = "cm"
            let _text = data
            let _filtered = Utilities.instance.filterRawData(raw: _text, char: [","])
            let _measurement = _filtered.split(separator: "'")
            let  _converted = _measurement.map { String($0) }
            
            let _feet = Int(_converted.item(at: 0) ?? "0") ?? 0
            let _inches = Int(_converted.item(at: 1) ?? "0") ?? 0
            print("_measurement: ", _measurement)
            return self.convertCmFromFootAndInches(_feet, inches: _inches)
        } else {
            self.selectedUnitHeight = "ft,in"
            let _current = Int(data.onlyDigitsInString )
            let a = Measurement(value: Double(_current ?? 0), unit: UnitLength.centimeters)
            print(a.heightOnFeetsAndInches ?? "")
            return self.convertFootAndInchesFromCm(Double(_current ?? 0))
        }
    }
    
    func calculateUserWeight(unit: String, data: String) -> String {
        if unit == "lbs" {
            self.selectedUnitWeight = "kg"
            let _current = Int(data.onlyDigitsInString)
            return self.convertKgFromlbs(Double(_current ?? 0))
        } else {
            self.selectedUnitWeight = "lbs"
            let _current = Int(data.onlyDigitsInString)
            return self.convertLbsFromFkgs(Double(_current ?? 0))
        }
    }
    
    func feetToFeetInches(_ value: Double) -> String {
      let formatter = MeasurementFormatter()
      formatter.unitOptions = .providedUnit
      formatter.unitStyle = .short

      let rounded = value.rounded(.towardZero)
      let feet = Measurement(value: rounded, unit: UnitLength.feet)
      let inches = Measurement(value: value - rounded, unit: UnitLength.feet).converted(to: .inches)
      let inchValue = inches.value.roundTo0f()
      return ("\(formatter.string(from: feet)) \(inchValue)\("\"")")
    }
    
    func convertFootAndInchesFromCm(_ cms: Double) -> String {

          let feet = cms * 0.0328084
          let feetShow = Int(floor(feet))
          let feetRest: Double = ((feet * 100).truncatingRemainder(dividingBy: 100) / 100)
          let inches = Int(floor(round(feetRest * 12)))
        
          return "\(feetShow)',\(inches)''"
    }
    
    func convertCmFromFootAndInches(_ feet: Int, inches: Int) -> String {
        let feet = Double(feet) * 30.48
        let inches = Double(inches) * 2.54
        //let cm = (feet + inches) - 1
        let cm = (feet + inches)
        return String(format: "%.0f cm", cm)

    }
    
    func convertLbsFromFkgs(_ kg: Double) -> String {

        let lbs = kg * 2.205
        return String(format: "%.2f lbs", lbs)
    }
    
    func convertKgFromlbs(_ lbs: Double) -> String {

          let kg = Int(lbs / 2.205) / 100
          return String(format: "%d kg", kg)
    }
    
    @objc func handleKeyboardDismiss(textField: UITextField) {
            let _height = txtHeight?.text ?? ""
            var hasFtChar = false

            guard _height.isEmpty == false else {
                return
            }
        
            guard _height.contains("'") || _height.contains("\"") else {
                //input is full number centimeter
                let _current = Double(_height.digits) ?? 0
                let centimeter = Measurement(value: _current, unit: UnitLength.centimeters)
                self.height = Int(centimeter.value)
                self.txtHeight?.text = LengthFormatters.imperialLengthFormatter.string(fromValue: centimeter.value, unit: LengthFormatter.Unit.centimeter)
                view.endEditing(true)
                return
            }
            
            let firstFilter = _height.removeCharacters(charSet: [" "])
            var splitStrings = [Substring]()
            
            if (_height.contains("'")) {
                hasFtChar = true
                splitStrings = firstFilter.split(separator: "'")
            } else {
                splitStrings = firstFilter.split(separator: "\"")
            }
            
            print("split1:", splitStrings)
            
            guard splitStrings.count > 0 else {
                return
            }
            
            //inches height
            let feetValue = hasFtChar ? Double("\(splitStrings.item(at: 0) ?? "0")".withoutSpecialCharacters.replacingOccurrences(of: "\"", with: "")) ?? 0.0 : 0.0
            let inchesValue = Double("\(hasFtChar ? splitStrings.item(at: 1) ?? "0" : splitStrings.item(at: 0) ?? "0")".withoutSpecialCharacters.replacingOccurrences(of: "\"", with: "")) ?? 0.0

            let _feet = Measurement(value: feetValue, unit: UnitLength.feet)
            let _inches = Measurement(value: inchesValue, unit: UnitLength.inches)
            
            let measurement = _feet.converted(to: .centimeters).value + _inches.converted(to: .centimeters).value
            self.height = Int(measurement)
                
            view.endEditing(true)
    }
    
    @objc func calculateWeight(textField: UITextField){
        let raw = txtWeight?.text ?? ""
        let _weight = raw.filterString(characters: "0123456789.")
        guard _weight.isEmpty == false else {
            view.endEditing(true)
            return
        }
        
        if selectedUnitWeight.contains("kg") {
            let _current  = Double(_weight.digits) ?? 0
            let weightInKg = Measurement(value: _current, unit: UnitMass.kilograms)
            self.weight = weightInKg.value
            self.txtWeight?.text = MassFormatter().string(fromValue: weightInKg.value, unit: .kilogram)
            view.endEditing(true)
        } else {
            let _current  = Double(_weight.digits) ?? 0
            let weightInKg = Measurement(value: _current, unit: UnitMass.pounds)
            let convertToPounds = weightInKg.converted(to: .kilograms)
            self.weight = convertToPounds.value
            self.txtWeight?.text = MassFormatter().string(fromValue: weightInKg.value, unit: .pound)
            view.endEditing(true)
        }
    }
    
}

extension UserProfileController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}
