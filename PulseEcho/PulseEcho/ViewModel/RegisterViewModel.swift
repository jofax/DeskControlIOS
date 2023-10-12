//
//  RegisterViewModel.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-10.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Moya
import Alamofire

class RegisterViewModel: BaseViewModel {
    
    var provider: MoyaProvider<RegistrationService>?
    
    /**
     Request user registration from backend.
     - Parameter [String: Any] parameters
     - Returns: Closure response
     */
    
    func requestSignup(_ parameters: [String: String]) {
        provider = MoyaProvider<RegistrationService>(session: smartpodsManager(withSSL: true),
                                                  plugins: getMoyaPlugins())
        
        provider?.request(.registerUser(parameters)) {[weak self] result in
            self?.enableState?(true)
            switch result {
            case .success(let response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    //let registerResult = try JSONDecoder().decode(Registration.self, from: filteredResponse.data)
                    //self?.successResponse?(registerResult)
                    
                    let json = try filteredResponse.mapJSON()
                    let rawJson = json as? [String: Any] ?? [String: Any]()
                    let registerResult = Registration(params: rawJson)
                    
                    if registerResult.Success {
                        self?.successResponse?(registerResult)
                    } else {
                        let message = rawJson["Message"] as? String ?? ""
                        self?.alertMessage?("generic.error_title".localize(),message,0)
                    }
                    
                } catch {
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        
                        let message = rawJson["Message"] as? String ?? ""
                        
                        self?.alertMessage?("generic.error_title".localize(),message,0)
                    } catch {
                        self?.alertMessage?("generic.error_title".localize(),"generic.server_error".localize(),0)
                    }
                }
                
            case .failure(let error):
                self?.alertMessage?("generic.error_title".localize(),error.localizedDescription, 0)
            }
        }
    }
    
    override func cancelCurrentRequest() {
        enableState?(true)
        provider?.session.session.invalidateAndCancel()
    }
    
    /**
    Validation user input.
    - Parameter String username
    - Parameter String password
    - Parameter String verify_password
    - Returns: Bool status
    */
    
    func checkValidInput(username: String, password: String, verify_password: String) throws -> Bool {
        guard (!username.isEmpty ||
            !password.isEmpty ||
            !verify_password.isEmpty) else {
            throw RegisterValidationError.EmptyForm
        }
        
        guard Utilities.instance.checkEmailAddress(email: username) else {
            throw RegisterValidationError.InvalidEmailAddress
        }
        
        guard !username.isEmpty else {
            throw RegisterValidationError.EmailRequired
        }
        
        guard !password.isEmpty else {
            throw RegisterValidationError.PasswordRequired
        }
        
        guard !verify_password.isEmpty else  {
            throw RegisterValidationError.VerifyPasswordRequired
        }
        
        guard (password == verify_password) else {
            throw RegisterValidationError.PasswordNotEqual
        }
        
        return true
    }
    
    /**
    Initialize user signup.
    - Parameter String username
    - Parameter String password
    - Parameter String verify_password
    - Returns: none
    */
    
    func initializeUserSignup(username: String,
                              password: String,
                              verify_password: String)  {
        do {
            let validate =  try checkValidInput(username: username, password: password, verify_password: verify_password)
            
            guard validate else {
                alertMessage?("generic.error_title".localize(),"generic.other_error".localize(), 0)
                return
            }
            enableState?(false)
            Threads.performTaskInMainQueue {
                let parameters = ["Email":username,
                                  "Password":password]
                self.requestSignup(parameters)
            }
            
        } catch let error as RegisterValidationError {
            alertMessage?("generic.error_title".localize(),error.description,0)
            print("initializeUserSignup error: \(error.description) | info: \(Utilities.instance.loginfo())")
        } catch {
            alertMessage?("generic.error_title".localize(),"generic.app_error".localize(), 0)
            print("initializeUserSignup error | info: \(Utilities.instance.loginfo())")
        }
    }
}
