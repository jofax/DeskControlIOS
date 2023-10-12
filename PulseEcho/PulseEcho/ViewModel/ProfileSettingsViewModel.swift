//
//  ProfileSettingsViewModel.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-05.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import Moya

/**
ProfileSettingsViewModel abstract view model . Retrieves  information related to user profile settings.
*/

class ProfileSettingsViewModel: BaseViewModel {

    //CLASS VARIABLES
    var provider: MoyaProvider<ProfileSettingService>?
    var forceLogout: (() -> Void)?
    override init() {
        super.init()
        
    }
    
    override func cancelCurrentRequest() {
        //provider?.session.session.invalidateAndCancel()
    }
    
    override func updateRecordinTable(object: Any) {
       
    }
    
    override func updateRealmObject(object: [String: Any]) {
        _ =  SPRealmHelper().updateUserProfileSettings(object,
                                                       Utilities.instance.getLoggedEmail())
    }
    
    /**
    Request profile settings data from web service.
    - Parameter String email
    - Parameter String SerialNumber
    - Parameter Closure  completion
    - Returns: none
    */
    
    func requestProfileSettings(_ email: String ,
                                _ serial: String,
                                _ session: String,
                                _ dated: String,
                                _ completion: @escaping (( _ response: [String: Any]) -> Void)) {
        //cancelCurrentRequest()
        
        
        provider = MoyaProvider<ProfileSettingService>(requestClosure: MoyaProvider<ProfileSettingService>.endpointRequestResolver(),
                                                       session: smartpodsManager(withSSL: true),
                                                       plugins:getMoyaPlugins(),
                                                       trackInflights: true)
        
        
        //let parameters = addTokenToParameter(params: ["Email": email, "SerialNumber": serial])
        var parameters = [String:Any]()
        if session.isEmpty == false && dated.isEmpty == false {
            parameters = ["Email": email,
                          "SessionKey" : session,
                          "SessionDated": dated]
        } else {
            parameters = addTokenToParameter(params: ["Email": email])
        }
        
        
        //let parameters = addTokenToParameter(params: ["Email": email])
            provider?.request(.getProfileSettings(parameters)) { [weak self] result in
                self?.enableState?(true)
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        let result = GenericResponse(params: rawJson)
                        
                        if result.Success && result.ResultCode == 0 {
                            
                            if rawJson.count > 0 {
                                
                                if !email.isEmpty {
                                    let profile = ProfileSettings(params: rawJson)
                                     //self?.updateRecordinTable(object: result)
                                    if profile.SittingPosition != 0 || profile.StandingPosition != 0 {
                                        _ =  self?.dataHelper.saveProfileSettings(profile, email)
                                    }
                                    
                                }
                            }
                            
                            completion(rawJson)
                            
                        } else {
                            
                            if result.Success == false {
                                
                            } else {
                                let errorCode = Utilities.instance.responseCodeMessage(response: result)
                                self?.alertMessage?(errorCode.title, errorCode.message,result.ResultCode)
                            }

                        }
                        
                       
                    } catch {
                        print("requestUpdateProfileSettings error code : \(response.statusCode) | info: \(Utilities.instance.loginfo())")
                        
                        if response.statusCode == 401 {
                            self?.apiCallback?(error, 6)
                        } else {
                            self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                            print("requestProfileSettings error | info: \(Utilities.instance.loginfo())")
                        }
                        
                       
                    }
                    
                case .failure(let error):
                    print("requestUpdateProfileSettings error : \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                    print("requestUpdateProfileSettings error code : \(error.errorCode) | info: \(Utilities.instance.loginfo())")
                    
                    if error.errorCode == 6 {
                        self?.refreshSessionToken(completion: { (refreshed) in
                            print("refresh token requestProfileSettings:  \(refreshed)")
                            if refreshed == false {
                                Threads.performTaskAfterDealy(1) {
                                    self?.apiCallback?(error, error.errorCode)
                                }
                            }
                            
                        })
                    }
                
                }
            }
    }
    
    /**
    Request to update profile settings to web service.
    - Parameter [String:Any] paramters
    - Parameter Closure  response
    - Returns: none
    */
    
    func requestUpdateProfileSettings(_ parameters:[String:Any],
                                      _ completion: @escaping (( _ response: [String: Any]) -> Void)) {
        cancelCurrentRequest()
        provider = MoyaProvider<ProfileSettingService>(requestClosure: MoyaProvider<ProfileSettingService>.endpointRequestResolver(),
                                                       session: smartpodsManager(withSSL: true),
                                             plugins: getMoyaPlugins(), trackInflights: true)
            let final_params = addTokenToParameter(params: parameters)
        
            provider?.request(.updateProfileSettings(final_params)) { [weak self] result in
                self?.enableState?(true)
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        //let _settings = rawJson["Settings"] as? [String: Any] ?? [String:Any]()
                        
                        print("requestUpdateProfileSettings: ", rawJson)
                        
                        
                        completion(rawJson)
                       
                    } catch {
                        //self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                        print("requestUpdateProfileSettings error | info: \(Utilities.instance.loginfo())")
                        if response.statusCode == 401 {
                            self?.apiCallback?(error, 6)
                        } else {
                            self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                            print("requestProfileSettings error | info: \(Utilities.instance.loginfo())")
                        }
                    }
                    
                case .failure(let error):
                    //self?.alertMessage?("generic.error_title".localize(),error.errorDescription ?? "",0)
                    print("requestUpdateProfileSettings error : \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                    print("requestUpdateProfileSettings error code : \(error.errorCode) | info: \(Utilities.instance.loginfo())")
                    //self?.apiCallback?(error, error.errorCode)
                }
            }
     }
    
    /**
    Get profile settings.
    - Parameter none
    - Returns: none
    */
    
    func getProfileSettings(completion: @escaping ((_ object: ProfileSettings) -> Void)) {
        
        let email = Utilities.instance.getUserEmail()
    
        do {
            let serial = Utilities.instance.getObjectFromUserDefaults(key: "serialNumber") as? String ?? ""
            
           /* if !serial.isEmpty {
                self.getProfileSettingsWithSerial(serial: serial) { data in
                    completion(data)
                }
            } else {
                
                if Utilities.instance.isBLEBoxConnected() && Utilities.instance.serialKeyAvailable() {
                    self.alertMessage?("generic.error_title".localize(),"generic.no_profile_settings".localize(),0)
                }
            }*/
            
            self.getProfileSettingsWithSerial(serial: serial) { data in
                
                completion(data)
            }
            
        } catch {
            //createDefaultProfileSettings()
            print("Cannot find profile setting data.")
            let serial = Utilities.instance.getObjectFromUserDefaults(key: "serialNumber") as? String ?? ""
            
            //if !serial.isEmpty {
                self.getProfileSettingsWithSerial(serial: serial) { data in
                    completion(data)
                }
            //}
            
        }
    }
    
    /**
    Get profile settings.
    - Parameter none
    - Returns: none
    */
    
    func getProfileSettingsWithCredentials(email: String,
                                           sessionDate: String,
                                           sessionKey: String,
                                           completion: @escaping ((_ object: ProfileSettings) -> Void)) {
        
       
        do {
           _ = requestProfileSettings(email,"",
                                      sessionKey,
                                      sessionDate,
                                      { [weak self] (object) in
                                       
               guard !object.isEmpty else {
                   self?.alertMessage?("generic.error_title".localize(),"generic.unknow_error".localize(),0)
                   return
               }

               let result = ProfileSettings(params: object)
               completion(result)
               
               guard !email.isEmpty else {
                   return
               }
               
               _ = self?.dataHelper.updateProfileSettings(result, email)
               
           })
            
        } catch {
            //createDefaultProfileSettings()
            print("Cannot find profile setting data.")
            let serial = Utilities.instance.getObjectFromUserDefaults(key: "serialNumber") as? String ?? ""
            
            //if !serial.isEmpty {
                self.getProfileSettingsWithSerial(serial: serial) { data in
                    completion(data)
                }
            //}
            
        }
    }
    
    /**
    Get request profile settings with serial number.
    - Parameter String serial
    - Parameter Closure completion
    - Returns: none
    */
    
    func getProfileSettingsWithSerial(serial: String, completion: @escaping ((_ object: ProfileSettings) -> Void)) {
         let email = Utilities.instance.getUserEmail()
        _ = requestProfileSettings(email,
                                   serial,
                                   "",
                                   "",
                                   { [weak self] (object) in
                                    
            guard !object.isEmpty else {
                self?.alertMessage?("generic.error_title".localize(),"generic.unknow_error".localize(),0)
                return
            }

            let result = ProfileSettings(params: object)
            PulseDataState.instance.userProfileSittingHeight = result.SittingPosition
            PulseDataState.instance.userProfileStandingHeight = result.StandingPosition
            completion(result)
            guard !email.isEmpty else {
                return
            }
            
            _ = self?.dataHelper.updateProfileSettings(result, email)
            
        })
    }
    
    /**
     Get user profile in local database.
     - Parameter none
     - Returns: User object
     */
    
    func getLocalUserProfileInformation(email: String, completion: @escaping ((_ object: ProfileSettings) -> Void)){
        let profile = self.dataHelper.getProfileSettings(email)
        PulseDataState.instance.userProfileSittingHeight = profile.SittingPosition
        PulseDataState.instance.userProfileStandingHeight = profile.StandingPosition
        completion(profile)
//        do {
//            completion(try AppDatabase.getProfileSettings(email: email))
//            
//        } catch {
//            print("getLocalUserInformation execution error")
//            
//        }
    }
    
    /**
    Create default Profile Settings
    - Parameter none
    - Returns: none
    */
    
    func createDefaultProfileSettings(pushToBox: Bool, emailAdress: String) {
        let email = emailAdress
        
        let standingTime = Utilities.instance.defaultProfileSettingsLifestyle(type: ProfileSettingsType.Active.rawValue)
        let serial = Utilities.instance.getObjectFromUserDefaults(key: "serialNumber") as? String
        
        print("standingTime: ", standingTime)
        
        
        let profile_settings = ["settings":["email":email,
                                            "StandingTime1":standingTime["StandingTimeInMinutesPeriod1"],
                                            "StandingTime2":standingTime["StandingTimeInMinutesPeriod2"],
                                            "ProfileSettingType": ProfileSettingsType.Active.rawValue,
                                            "SittingPosition": Constants.defaultSittingPosition,
                                            "StandingPosition": Constants.defaultStandingPosition,
                                            "IsInteractive":false]]
        
        print("createDefaultProfileSettings: ", profile_settings)
        
        self.requestUpdateProfileSettings(profile_settings) { object in
            if pushToBox {
                self.synchronizeConfigurations?(true, object)
            }
        }
        
    }
      
}
