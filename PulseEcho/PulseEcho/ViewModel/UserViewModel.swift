//
//  UserViewModel.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-29.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import Moya
import RealmSwift

class UserViewModel: BaseViewModel {
    
    //CLASS VARIABLES
    var provider: MoyaProvider<UserService>?
    var deskProvider: MoyaProvider<DeskService>?
    var department: Departments?
    var userProfileSettings = ProfileSettingsViewModel()
    
    override init() {
        super.init()
        
    }
    
    override func cancelCurrentRequest() {
        //provider?.session.session.invalidateAndCancel()
        //deskProvider?.session.session.invalidateAndCancel()
    }
    
    /**
    Request user information from web service.
    - Parameter String email
    - Parameter Closure  completion
    - Returns: none
    */
    
    func requestUserInformation(_ email: String , _ completion: @escaping (( _ response: [String: Any]) -> Void)) {
        cancelCurrentRequest()
        provider = MoyaProvider<UserService>(requestClosure: MoyaProvider<UserService>.endpointRequestResolver(),
                                             session: smartpodsManager(withSSL: true),
                                             plugins: getMoyaPlugins())
        
            
        let parameters = addTokenToParameter(params: ["email": email])
            provider?.request(.getUser(parameters)) { [weak self] result in
                self?.enableState?(true)
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        completion(rawJson)
                       
                    } catch {
                        //self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                        print("requestUserInformation error | info: \(Utilities.instance.loginfo())")
                        if response.statusCode == 401 {
                            self?.apiCallback?(error, 6)
                        } else {
                            self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                            print("requestProfileSettings error | info: \(Utilities.instance.loginfo())")
                        }
                    }
                    
                case .failure(let error):
                    //self?.alertMessage?("generic.error_title".localize(),error.errorDescription ?? "",0)
                    print("requestUserInformation error: \(error.errorDescription) | info: \(Utilities.instance.loginfo())")
                    
                }
            }
    }
    
    /**
    Request to update user information to web service.
    - Parameter [String:Any] paramters
    - Parameter Closure  response
    - Returns: none
    */
    
    func requestUpdateUserInformation(_ parameters:[String:Any],
                                      _ completion: @escaping (( _ response: [String: Any]) -> Void)) {
        cancelCurrentRequest()
        provider = MoyaProvider<UserService>(requestClosure: MoyaProvider<UserService>.endpointRequestResolver(),
                                             session: smartpodsManager(withSSL: true),
                                             plugins:getMoyaPlugins())
            let final_params = addTokenToParameter(params: parameters)
            provider?.request(.updateUser(final_params)) { [weak self] result in
                self?.enableState?(true)
                
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        print("result is: ", result)
                        completion(rawJson)
                       
                    } catch {
                        self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                        print("requestUpdateUserInformation error | info: \(Utilities.instance.loginfo())")
                    }
                    
                case .failure(let error):
                    self?.alertMessage?("generic.error_title".localize(),error.errorDescription ?? "",0)
                    print("requestUpdateUserInformation error :\(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                    
                }
            }
    }
    
    /**
    Get user information.
    - Parameter none
    - Returns: none
    */
    
    func getUserInformation(completion: @escaping ((_ object: Any) -> Void)) {
        
        let email = Utilities.instance.getUserEmail()
        _ = requestUserInformation(email, { [weak self] (object) in
            guard !object.isEmpty else {
                completion(object)
                return
            }
            let _user = object["User"] as? [String:Any] ?? [String:Any]()
            let _other_response = GenericResponse(success: object["Success"] as? Bool ?? false,
                                                  code: object["ResultCode"] as? Int ?? -1,
                                                  message: object["Message"] as? String ?? "")
            guard _other_response.Success else {
                if _other_response.Message.isEmpty {
                    self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                    print("getUserInformation error | info: \(Utilities.instance.loginfo())")
                } else {
                    self?.alertMessage?("generic.error_title".localize(),_other_response.Message,0)
                    print("getUserInformation error: \(_other_response.Message) | info: \(Utilities.instance.loginfo())")
                }

                return
            }

            if self?.dataHelper.userExists(email) == false {
                SPRealmHelper.saveObject(from: _user, primaryKey: email) { (result: Result<User, Error>) in
                    switch result {
                    case .success:
                        completion(result)

                    case .failure: break
                    }
                }
            } else {
                let result = User(params: _user)
                _ = self?.dataHelper.updateUser(result, result.Email)
                completion(result)

            }
            
            
            
        })
    }

    /**
     Retrieve user information in local database.
     - Parameter none
     - Returns: User object
     */
    
    func getLocalUserInformation(completion: @escaping ((_ object: User) -> Void)){
        let email = Utilities.instance.getUserEmail()
        completion(dataHelper.getUser(email))
    }
    
    /**
     Update user information.
     - Parameter [Strings: Any] params
     - Parameter Closure completion
     - Returns: none
     */
    
    func updateUserInformation(params: [String: Any], completion: @escaping ((_ object: User, _ success: Bool) -> Void)) {
        let email = Utilities.instance.getUserEmail()
        var _params = params
        
        let now = Date()
        let dateFortmatter = DateFormatter()
        dateFortmatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        let dateNow = dateFortmatter.string(from: now)
        print("dateNow: ", dateNow)
        
        let localUser = dataHelper.getUser(email)
            _params["Email"] = email
            _params["Language"] = localUser.Language
            _params["AcknowledgedWaiver"] = localUser.AcknowledgedWaiver
            _params["WatchedSafetyVideo"] = localUser.WatchedSafetyVideo
            _params["StepType"] = localUser.StepType
            _params["JobDescription"] = localUser.JobDescription
            _params["LogoutWhenNotDetected"] = localUser.LogoutWhenNotDetected
            _params["TaskBarNotification"] =  false
            _params["AutoLogin"] =  false
            _params["AcknowledgedWaiverDate"] = dateNow
            _params["IsImperial"] =  false
    
        let parameters = ["User": _params]
        print("updateUserInformation parameters: ", parameters)
        
        _ = requestUpdateUserInformation(parameters, { [weak self] object in
        
                guard !object.isEmpty else {
                    return
                }

                let _user = object["User"] as? [String:Any] ?? [String:Any]()
                let _other_response = GenericResponse(success: object["Success"] as? Bool ?? false,
                                                      code: object["ResultCode"] as? Int ?? -1,
                                                      message: object["Message"] as? String ?? "")
                guard _other_response.Success else {
                   if _other_response.Message.isEmpty {
                       self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                        print("updateUserInformation error: \(_other_response.Message) | info: \(Utilities.instance.loginfo())")
                   } else {
                       self?.alertMessage?("generic.error_title".localize(),_other_response.Message,0)
                        print("updateUserInformation error: \(_other_response.Message) | info: \(Utilities.instance.loginfo())")
                   }

                   return
                }

               let result = User(params: _user)
               _ = self?.dataHelper.updateUser(result, email)
                     
                completion(result, _other_response.Success)
            
        })
    }
    
    /**
    Request to set user connected to device
    - Parameter String serial number
    - Parameter Bool  connected
    - Returns: none
    */
    
    func requestSetDeviceConnected(_ parameters:[String:Any],
                                   _ completion: @escaping (( _ response: [String: Any]) -> Void)) {
        cancelCurrentRequest()
        deskProvider = MoyaProvider<DeskService>(requestClosure: MoyaProvider<DeskService>.endpointRequestResolver(),
                                                 session: smartpodsManager(withSSL: true),
                                                 plugins: getMoyaPlugins())
            let final_params = addTokenToParameter(params: parameters)
            deskProvider?.request(.deviceConnect(final_params)) { [weak self] result in
                self?.enableState?(true)
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        
                        //let generic = GenericResponse(params: rawJson)
                        //completion(generic)
                        completion(rawJson)
                       
                    } catch {
                        self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                    }
                    
                case .failure(let error):
                    self?.alertMessage?("generic.error_title".localize(),error.errorDescription ?? "",0)
                    
                }
        }
    }
    
    /**
       Request to get list of available departments
       - Parameter String serial number
       - Parameter Bool  connected
       - Returns: none
       */
       
       func getDepartmentLists(_ completion: @escaping (( _ response: Any) -> Void)) {
           cancelCurrentRequest()
           provider = MoyaProvider<UserService>(requestClosure: MoyaProvider<UserService>.endpointRequestResolver(),
                                                session: smartpodsManager(withSSL: true),
                                                plugins: getMoyaPlugins())
            let final_params = addTokenToParameter(params: [:])
               provider?.request(.getDepartments(final_params)) { [weak self] result in
                   self?.enableState?(true)
                   switch result {
                   case .success(let response):
                       do {
                           let filteredResponse = try response.filterSuccessfulStatusCodes()
                           let json = try filteredResponse.mapJSON()
                           let rawJson = json as? [String: Any] ?? [String: Any]()
                           let departments = Departments(params: rawJson)
                           self?.department = departments
                        
                            if departments.Success {
                                completion(departments)
                            } else {
                                completion([String: Any]())
                            }
                          
                       } catch {
                           //self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                        print("getDepartmentLists error | info: \(Utilities.instance.loginfo())")
                       }
                       
                   case .failure(let error):
                        print(error)
                        print("getDepartmentLists error: \(error.errorDescription) | info: \(Utilities.instance.loginfo())")
                       
                   }
           }
       }
    
    func saveHeartsAccumulated() {
        var serial = Utilities.instance.getObjectFromUserDefaults(key: "serialNumber") as? String ?? ""
        let email = Utilities.instance.getLoggedEmail()
        let hearts_saved = 1.0
        let timestamp = Utilities.instance.getCurrentMillis()
        var identifier = UserDefaults.standard
            .object(forKey: peripheralIdDefaultsKey) as? String ?? ""
        
        if let peripheral = SPBluetoothManager.shared.state.peripheral {
            if identifier.isEmpty {
                identifier = peripheral.identifier.uuidString
            }
        }
        
        let _desk_activity = ["id": String(format: "%d", Utilities.instance.getCurrentMillis()),
                              "Serial":serial,
                              "Identifier":identifier,
                              "Email":email,
                              "HeartSaved":hearts_saved,
                              "Timestamp":timestamp] as [String : Any]
        
        self.saveDeskActivity(email: email, data: _desk_activity)
    }
}
