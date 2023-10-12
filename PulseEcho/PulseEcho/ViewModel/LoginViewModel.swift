//
//  LoginViewModel.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-07.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Moya
import Alamofire
import RealmSwift
import KeychainSwift

class LoginViewModel: BaseViewModel {
    
    let keychain = KeychainSwift()
    var provider: MoyaProvider<LoginService>?
    var userViewModel = UserViewModel()
    var userProfileSettings = ProfileSettingsViewModel()
    var loginResponse:((_ object: Any, _ user: User) -> Void)?
    var loginResponseWithNoOrgCode:((_ object: Login, _ user: String) -> Void)?
    
    /**
     Request login from backend.
     - Parameter String username
     - Parameter String password
     - Returns: Closure response
     */
    
    func requestLogin(_ username: String, _ password: String, _ closure: @escaping ((_ object: Any, _ user: User) -> Void)) {
        provider = MoyaProvider<LoginService>(session: smartpodsManager(withSSL: true),
                                                  plugins: getMoyaPlugins())
        
        var parameters = [String:String]()
        let serial =  Utilities.instance.getStringFromUserDefaults(key: "serialNumber")
        
            parameters = ["Email": username,
                          "Password":password]
        
        provider?.request(.loginUser(parameters)) { [weak self] result in
            self?.enableState?(true)
            switch result {
            case .success(let response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    let loginResult = try JSONDecoder().decode(Login.self, from: filteredResponse.data)
                    
                    let json = try filteredResponse.mapJSON()
                    let rawJson = json as? [String: Any] ?? [String: Any]()
                    let _user:[String:Any] = rawJson["User"] as? [String: Any] ?? [String: Any]()
                    let _settings = rawJson["Settings"] as? [String: Any] ?? [String:Any]()
                    let _orgCode = rawJson["OrgCode"] as? String ?? ""
                    let _orgName = rawJson["OrgName"] as? String ?? ""
                    let user = User(params: _user)
                    
                    guard !loginResult.SessionKey.isEmpty else {
                        self?.loginResponse?(loginResult,user)
                        return
                    }
                    
                    if (loginResult.ResultCode == 0 && loginResult.Success){
                        
                        Utilities.instance.saveObjectsInDefaults(objects: [["key":Constants.email,
                                                                            "value":username]])

                        Utilities.instance.saveDefaultValueForKey(value: CURRENT_LOGGED_USER.Cloud.rawValue, key: Constants.current_logged_user_type)
                        let appState = UserAppStates()
                        
                        appState.BLEUUID = SPBluetoothManager.shared.SPBLEUUID
                        appState.Email = username
                        appState.SerialNumber = serial
                        appState.SessionKey = loginResult.SessionKey
                        appState.SessionDated = loginResult.SessionDated
                        appState.OrgCode = _orgCode
                        appState.OrgName = _orgName
                        appState.HasOrgCode = _orgCode.isEmpty ? false : true
                        appState.SessionExpiryDated = loginResult.SessionExpiryDated
                        appState.RenewalKey = loginResult.RenewalKey
                        
                        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                            appState.DeviceId = uuid
                            self?.dataHelper.saveAppStates(appState, device: uuid, email: username)
                        }
                        
                        
                        if self?.dataHelper.userExists(username) == false {
                            SPRealmHelper.saveObject(from: _user, primaryKey: username) { (result: Result<User, Error>) in
                                switch result {
                                case .success: break
                                case .failure: break
                                }
                            }
                        }
                        

                    }
                    
                    
                    guard !_orgCode.isEmpty else {
                        self?.loginResponseWithNoOrgCode?(loginResult,username)
                        print("_orgCode is empty ")
                        return
                    }
                        
                    self?.syncronizeDataAfterLogin(loginResult: loginResult,
                                             user: _user,
                                             settings: _settings,
                                             username: username,
                                             serial: serial,
                                             orgCode: _orgCode)
                    
                    Threads.performTaskAfterDealy(2.0) {
                        self?.loginResponse?(loginResult,user)
                        closure(loginResult,user)
                    }
                } catch {
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        let _user:[String:Any] = rawJson["User"] as? [String: Any] ?? [String: Any]()
                        let loginResult =  Login(params: rawJson)
                        let user = User(params: _user)
                        
                        let message = rawJson["Message"] as? String ?? ""
                        let genericResponse = GenericResponse(params: rawJson)
                        
                        if loginResult.Success == false {
                            self?.loginResponse?(loginResult,user)
                            closure(loginResult,user)
                            
                        } else {
                            self?.alertMessage?("generic.error_title".localize(),message,0)
                        }
                        
                    } catch {
                       self?.alertMessage?("generic.error_title".localize(),"generic.server_error".localize(),0)
                    }
                }
                
                
            case .failure(let error):
                self?.alertMessage?("generic.error_title".localize(),error.errorDescription ?? "",0)
            }
        }
    }
    
    func syncronizeDataAfterLogin(loginResult: Login,
                               user: [String:Any],
                               settings: [String:Any],
                               username: String,
                               serial: String,
                               orgCode: String) {
        
        if settings.count > 0 {
            let profile_settings = ProfileSettings(params: settings)
            
            self.userProfileSettings.updateRecordinTable(object: profile_settings)
            self.synchronizeConfigurations?(false, profile_settings)
            
        } else {
            
            let profileSettingsViewModel = ProfileSettingsViewModel()
            let SPCommand = PulseCommands()
            profileSettingsViewModel.getProfileSettingsWithCredentials(email: username,
                                                                       sessionDate: loginResult.SessionDated,
                                                                       sessionKey: loginResult.SessionKey,
                                                                       completion: { (profile) in
                if profile.ProfileSettingType != -1 {
                    let userProfile = SPCommand.CreateVerticalProfile(settings: profile)
                    let setSit = SPCommand.GetSetDownCommand(value: Double(profile.SittingPosition))
                    let setStand = SPCommand.GetSetTopCommand(value: Double(profile.StandingPosition))
                    SPBluetoothManager.shared.pushProfileTotheBox(profile: userProfile, sit: setSit, stand: setStand)
                } else {
                    let defaultProfile = SPCommand.GenerateVerticalProfile(movements: Constants.defaultProfileSettingsMovement)
                    let setSit = SPCommand.GetSetDownCommand(value: Double(Constants.defaultSittingPosition))
                    let setStand = SPCommand.GetSetTopCommand(value: Double(Constants.defaultStandingPosition))

                    SPBluetoothManager.shared.pushProfileTotheBox(profile: defaultProfile, sit: setSit, stand: setStand)
                    self.userProfileSettings.createDefaultProfileSettings(pushToBox: false, emailAdress: username)
                }
                
            })
        }
    }
    
    func generateDefaultProfileSettings() {
        
    }
    
    /**
     Request activate user to backend.
     - Parameter String username
     - Parameter String password
     - Returns: Closure response
     */
    
    func requestActivateUser(_ email: String,
                             _ code: String,
                             _ password: String,
                             _ closure: @escaping((_ object: Any, _ user: User) -> Void)) {
        provider = MoyaProvider<LoginService>(session: smartpodsManager(withSSL: true),
                                                  plugins: getMoyaPlugins())
        
        let parameters = ["Email": email,
                          "Code":code]
    
        
        provider?.request(.activateUser(parameters)) { [weak self] result in
            self?.enableState?(true)
            switch result {
            case .success(let response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    
                    let json = try filteredResponse.mapJSON()
                    let rawJson = json as? [String: Any] ?? [String: Any]()
                    print("activateUser :", rawJson)
                    if filteredResponse.statusCode == 200 {
                        //self?.successResponse?(rawJson)
                        self?.requestLogin(email, password, closure)
                        
                    } else {
                        self?.alertMessage?("generic.error_title".localize(),"login.invalid_code".localize(),0)
                    }
                    
                } catch {
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        
                        let message = rawJson["Message"] as? String ?? ""
                        
                        self?.alertMessage?("generic.error_title".localize(),message,0)
                        print("requestActivateUser error | info: \(Utilities.instance.loginfo())")
                    } catch {
                        print("requestActivateUser error | info: \(Utilities.instance.loginfo())")
                        self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                    }
                }
                
            case .failure(let error):
                self?.alertMessage?("generic.error_title".localize(),error.errorDescription ?? "",0)
            }
        }
    }
    
    /**
     Resend activation code to registered email address.
     - Parameter String email
     - Returns: Closure response
     */
    
    func resendActivationCode(_ email: String, completion: @escaping ((_ object: Any) -> Void)) {
        provider = MoyaProvider<LoginService>(session: smartpodsManager(withSSL: true),
                                                  plugins: getMoyaPlugins())
        
        let parameters = addTokenToParameter(params: ["Email": email])
        
        provider?.request(.resendActivation(parameters)) { [weak self] result in
            self?.enableState?(true)
            switch result {
            case .success(let response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    
                    let json = try filteredResponse.mapJSON()
                    let rawJson = json as? [String: Any] ?? [String: Any]()
                    let generic = GenericResponse(params: rawJson)
                    completion(generic)
                } catch {
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        
                        let message = rawJson["Message"] as? String ?? ""
                        
                        self?.alertMessage?("generic.error_title".localize(),message,0)
                        print("resendActivationCode error | info: \(Utilities.instance.loginfo())")
                    } catch {
                        self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                        print("resendActivationCode error | info: \(Utilities.instance.loginfo())")
                    }
                }
                
            case .failure(let error):
                self?.alertMessage?("generic.error_title".localize(),error.errorDescription ?? "",0)
            }
        }
    }
    
    override func cancelCurrentRequest() {
        enableState?(true)
        provider?.session.session.invalidateAndCancel()
    }
    
    /**
    Validation for user credentials.
    - Parameter String username
    - Parameter String password
    - Returns: Bool status
    */
    
    func checkValidInput(username: String, password: String) throws -> Bool {
        guard (!username.isEmpty || !password.isEmpty) else {
            throw ValidationError.EmptyCredentials
        }
        
        guard Utilities.instance.checkEmailAddress(email: username) else {
            throw ValidationError.InvalidEmailAddress
        }
        
        guard !username.isEmpty else {
            throw ValidationError.EmailRequired
        }
        
        guard !password.isEmpty else {
            throw ValidationError.PasswordRequired
        }
        
        return true
    }
    
    /**
       Validate activation code..
       - Parameter String code
       - Returns: Bool status
       */
       
       func checkCodeInput(code: String) throws -> Bool {
           guard !code.isEmpty else {
               throw ValidationError.EmptyCode
           }

           return true
       }
    
    /**
    Initialize user login.
    - Parameter String username
    - Parameter String password
    - Returns: none
    */
    
    func intializeUserLogin(username: String, password: String, closure: @escaping ((_ object: Any, _ user: User) -> Void))  {
        do {
            let validate =  try checkValidInput(username: username, password: password)
            
            guard validate else {
                alertMessage?("generic.error_title".localize(),"generic.other_error".localize(), 0)
                return
            }
            enableState?(false)
            Threads.performTaskInMainQueue {
                self.requestLogin(username, password, closure)
            }
            
        } catch let error as ValidationError {
            alertMessage?("generic.error_title".localize(),error.description,0)
            print("intializeUserLogin error: \(error.description) | info: \(Utilities.instance.loginfo())")
        } catch {
            alertMessage?("generic.error_title".localize(),"generic.app_error".localize(), 0)
            print("intializeUserLogin error | info: \(Utilities.instance.loginfo())")
        }
    }
    
    /**
    Initialize activate user.
    - Parameter String username
    - Parameter String password
    - Returns: none
    */
    
    func initializeActivateUser(email: String, code: String, password: String, closure: @escaping((_ object: Any, _ user: User) -> Void))  {
        do {
            let validate =  try checkCodeInput(code: code)
            
            guard validate else {
                alertMessage?("generic.error_title".localize(),"generic.other_error".localize(), 0)
                return
            }
            Threads.performTaskInMainQueue {
                self.requestActivateUser(email, code, password, closure)
            }
            
        } catch let error as ValidationError {
            alertMessage?("generic.error_title".localize(),error.description,0)
            print("initializeActivateUser error: \(error.description) | info: \(Utilities.instance.loginfo())")
        } catch {
            alertMessage?("generic.error_title".localize(),"generic.app_error".localize(), 0)
            print("initializeActivateUser | info: \(Utilities.instance.loginfo())")
        }
    }
    
}
