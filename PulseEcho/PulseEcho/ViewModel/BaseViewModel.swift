//
//  BaseViewModel.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-07.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Moya
import Alamofire
import KeychainSwift

/**
 PREDEFINE CLOSURES
 */

typealias INDICATOR_SHOW = (_ show: Bool) -> Void
typealias API_RESPONSE  = (_ response : Any, _ status: Int) -> Void

/**
BaseViewModel. All view models inherits this base class to use general closures and methods.
*/

class BaseViewModel: NSObject {
    
    //base closure
    var apiCallback: API_RESPONSE?
    var showIndicator: INDICATOR_SHOW?
    var doneRefresh:((_ status: Bool)-> Void)?
    var alertMessage:((_ title: String, _ message: String, _ tag: Int) -> Void)?
    var popView: (() -> Void)?
    var enableState:((_ enable: Bool) -> Void)?
    var successResponse:((_ object: Any) -> Void)?
    var synchronizeConfigurations:((_ defaultProfile: Bool, _ object: Any) -> Void)?
    var badgeView: (() -> Void)?
    
    let dataHelper = SPRealmHelper()
    
    
    /**
     Enable network request logger
    - Parameter none
    - Returns: none
    */
    
    func getMoyaPlugins() -> [PluginType] {
        if NetworkLogs.enabled {
           return  [NetworkLoggerPlugin(configuration: .init(formatter: .init(responseData: JSONResponseDataFormatter),
            logOptions: .verbose)),
                      NetworkActivityPlugin(networkActivityClosure: { [weak self] (NetworkActivityChangeType, TargetType) in
                          
                          switch NetworkActivityChangeType {
                          case .began:
                              self?.showIndicator?(true)
                              break
                          case .ended:
                              self?.showIndicator?(false)
                              break
                          }
                          
                      })]
        } else {
            return [NetworkActivityPlugin(networkActivityClosure: { [weak self] (NetworkActivityChangeType, TargetType) in
                                                                           
                                                                           switch NetworkActivityChangeType {
                                                                           case .began:
                                                                               self?.showIndicator?(true)
                                                                               break
                                                                           case .ended:
                                                                               self?.showIndicator?(false)
                                                                               break
                                                                           }
                                                                           
                                                                       })]
        }
    }
    
    /**
    Cancels current URL session request.
    - Parameter none
    - Returns: none
    */
    func cancelCurrentRequest() {}
    
    /**
     Check if table exists in the database.
    - Parameter none
    - Returns: none
    */
    
    func checkDatabaseTable() { }
    
    /**
     Update a record in a database table.
    - Parameter Any object
    - Returns: none
    */
    
    func updateRecordinTable(object: Any) { }
    
    
    /**
      Checking validity of session token.
    - Parameter none
    - Returns: Bool
    */
    
    func checkSessionToken() -> Bool {
        let tokenRefresh = false
        return tokenRefresh
    }
    
    /**
     Update a record in a Real Stacl.
    - Parameter Any object
    - Returns: none
    */
    
    func updateRealmObject(object: [String: Any]) { }
    
    /**
      Save guest account.
    */
    
    func guestUserAccount(email: String, data: [String: Any]) {
        
        guard dataHelper.userExists(email) == false else {
            return
        }
        
        SPRealmHelper.saveObject(from: data, primaryKey: email) { (result: Result<User, Error>) in
            switch result {
            case .success: break
            case .failure: break
            }
        }
    }
    
    func guestAppState(email: String, data: [String: Any]) {
        guard dataHelper.appStateExists(email) == false else {
            return
        }
        
        SPRealmHelper.saveObject(from: data, primaryKey: email) { (result: Result<UserAppStates, Error>) in
            switch result {
            case .success: break
            case .failure: break
            }
        }
    }
    
    func guestDefaultProfile(email: String, data: [String: Any]) {
        
        guard dataHelper.profileExists(email) == false else {
            return
        }
        
        PulseDataState.instance.userProfileSittingHeight = data["SittingPosition"] as? Int ?? Constants.defaultSittingPosition
        PulseDataState.instance.userProfileStandingHeight = data["StandingPosition"] as? Int ?? Constants.defaultStandingPosition
        
        SPRealmHelper.saveObject(from: data, primaryKey: email) { (result: Result<ProfileSettings, Error>) in
            switch result {
            case .success: break
            case .failure: break
            }
        }
    }
    
    /**
      Realm User account sync.
    */
    
    func userAccountSync(email: String, data: [String: Any], object: User) {
            
        dataHelper.updateUserObjectWithParams(email, data) { (user) in
            
        }
        
        if dataHelper.userExists(email) == false {
            //save guest user
            
        } else {
            //update user object for guest
            
        }
    }
    
    func saveDeskActivity(email: String, data: [String: Any]) {
        SPRealmHelper.saveObject(from: data, primaryKey: email) { (result: Result<DeskActivity, Error>) in
            switch result {
            case .success: break
            case .failure: break
            }
        }
    }
    
    func updateUserAppState(email: String, data: [String: Any]) {
        guard dataHelper.appStateExists(email) else {
            return
        }
        
        let state = dataHelper.getAppState(email)
        let newState = UserAppStates(value: state)
        newState.LocalDataExpiry = Date().currentTimeMillis()
        
        //dataHelper.updateUserAppState(newState, email)
    }
    
  /**
     Refresh session key  from backend.
   - Parameter Closure response
   - Return none
   */
       
       func refreshSessionToken(completion: @escaping ((_ response: Bool) -> Void)) {
              let dataHelper = SPRealmHelper()
              let email = Utilities.instance.getUserEmail()
              let state = dataHelper.getAppState(email)
              
              let _parameters = ["Email":email,
                                 "OrganizationCode":state.OrgCode,
                                 "RenewalKey":state.RenewalKey]
                
              let parameters = addTokenToParameter(params: _parameters)
              
              //Do a request to refresh the authtoken based on renewtoken
              MoyaProvider<AuthTokenService>(session: smartpodsManager(withSSL: true)).request(.renewSessionKey(parameters)) { result in
                  switch result {
                  case .success(let response):
                      do {
                           let json = try response.mapJSON()
                           let rawJson = json as? [String: Any] ?? [String: Any]()
                           let token = Login(params: rawJson)
                           
                           var deviceId = ""
                           if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                               deviceId = uuid
                           }
                           
                        
                        let params = ["DeviceId":deviceId,
                                      "BLEUUID":SPBluetoothManager.shared.SPBLEUUID,
                                      "SessionKey":token.SessionKey,
                                      "SessionDated":token.SessionDated,
                                      "SessionExpiryDated":token.SessionExpiryDated,
                                      "RenewalKey":token.RenewalKey]
                        dataHelper.updateUserAppStateWithParams(params, email)
                        
                          Threads.performTaskAfterDealy(1.0) {
                              completion(true)
                          }
                           
                       } catch (let error) {
                        print("refreshSessionToken refresh token error: \(error) | info: \(Utilities.instance.loginfo())")
                          completion(false)
                       }
                  case .failure(let error):
                    print("refreshSessionToken refresh token error:\(error) | info: \(Utilities.instance.loginfo())")
                      completion(false)
                  }
              }
           
           
       }
    
    func JSONResponseDataFormatter(_ data: Data) -> String {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
        } catch {
            return String(data: data, encoding: .utf8) ?? ""
        }
    }
    
    func endpointResolver() -> MoyaProvider<AuthTokenService>.RequestClosure {
        return { (endpoint, closure) in
            
            let request = try! endpoint.urlRequest()

            guard Utilities.instance.isValidSessionToken() == false else {
                closure(.success(request))
                return
            }
            
            //Do a request to refresh the authtoken based on refreshToken
            let dataHelper = SPRealmHelper()
            let email = Utilities.instance.getUserEmail()
            let state = dataHelper.getAppState(email)
            
            let _parameters = ["Email":email,
                               "OrganizationCode":state.OrgCode,
                               "RenewalKey":state.RenewalKey]
              
            let parameters = addTokenToParameter(params: _parameters)
            
            MoyaProvider<AuthTokenService>(session: smartpodsManager(withSSL: true)).request(.renewSessionKey(parameters), completion: { result  in
                switch result {
                case .success(let response):
                    do {
                        let json = try response.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        let token = Login(params: rawJson)
                        
                        
                        var deviceId = ""
                        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                            deviceId = uuid
                        }
                        
                     
                     let params = ["DeviceId":deviceId,
                                   "BLEUUID":SPBluetoothManager.shared.SPBLEUUID,
                                   "SessionKey":token.SessionKey,
                                   "SessionDated":token.SessionDated,
                                   "SessionExpiryDated":token.SessionExpiryDated,
                                   "RenewalKey":token.RenewalKey]
                     dataHelper.updateUserAppStateWithParams(params, email)
                        
                        Threads.performTaskAfterDealy(1.0) {
                             closure(.success(request))
                        }
                    } catch (let error) {
                        print("refresh token error: \(error) | info: \(Utilities.instance.loginfo())")
                        closure(.failure(MoyaError.underlying(error, nil)))
                    }
                case .failure(let error):
                    print("failuer refresh token error: \(error) | info: \(Utilities.instance.loginfo())")
                    closure(.failure(error))
                }
            })
            
        }
    }
}

extension MoyaProvider {
    static func endpointRequestResolver() -> MoyaProvider<Target>.RequestClosure {
        return { (endpoint, closure) in
            let request = try! endpoint.urlRequest()

              guard Utilities.instance.isValidSessionToken() == false else {
                  closure(.success(request))
                  return
              }

            
            let dataHelper = SPRealmHelper()
            let email = Utilities.instance.getUserEmail()
            let state = dataHelper.getAppState(email)
            
            let _parameters = ["Email":email,
                               "OrganizationCode":state.OrgCode,
                               "RenewalKey":state.RenewalKey]
              
            let parameters = addTokenToParameter(params: _parameters)
            
            //Do a request to refresh the authtoken based on renewtoken
            MoyaProvider<AuthTokenService>(session: smartpodsManager(withSSL: true)).request(.renewSessionKey(parameters)) { result in
                switch result {
                case .success(let response):
                    do {
                         let json = try response.mapJSON()
                         let rawJson = json as? [String: Any] ?? [String: Any]()
                         let loginObj = Login(params: rawJson)
                        
                        guard loginObj.Success else {
                            closure(.failure(MoyaError.underlying(ValidationError.InvalidSession, response)))
                            return
                        }
                        
//                        log.debug("endpointRequestResolver rawJSON: \(rawJson)")
//                        log.debug("endpointRequestResolver SessionKey: \(loginObj.SessionKey)")
//                        log.debug("endpointRequestResolver SessionDated: \(loginObj.SessionDated)")
//                        log.debug("endpointRequestResolver SessionExpiryDated: \(loginObj.SessionExpiryDated)")
//                        log.debug("endpointRequestResolver RenewalKey: \(loginObj.RenewalKey)")
                        
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let token = try JSONDecoder().decode(Login.self, from: filteredResponse.data)

//                        log.debug("endpointRequestResolver token SessionKey: \(token.SessionKey)")
//                        log.debug("endpointRequestResolver token SessionDated: \(token.SessionDated)")
//                        log.debug("endpointRequestResolver token SessionExpiryDated: \(token.SessionExpiryDated)")
//                        log.debug("endpointRequestResolver token RenewalKey: \(token.RenewalKey)")
                        
                        var deviceId = ""
                        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
                            deviceId = uuid
                        }
                        
                     
                         let params = ["DeviceId":deviceId,
                                       "BLEUUID":SPBluetoothManager.shared.SPBLEUUID,
                                       "SessionKey":token.SessionKey,
                                       "SessionDated":token.SessionDated,
                                       "SessionExpiryDated":token.SessionExpiryDated,
                                       "RenewalKey":token.RenewalKey]
                         dataHelper.updateUserAppStateWithParams(params, email)
                        
                         closure(.success(request))
                         
                     } catch (let error) {
                        print("endpointRequestResolver refresh token error: \(error) | info: \(Utilities.instance.loginfo())")
                         closure(.failure(MoyaError.underlying(error, nil)))
                     }
                case .failure(let error):
                    print("endpointRequestResolver refresh token failure error: \(error) | info: \(Utilities.instance.loginfo())")
                    closure(.failure(error))
                }
            }
            
        }
    }
}
