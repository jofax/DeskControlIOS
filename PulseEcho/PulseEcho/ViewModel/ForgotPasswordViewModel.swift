//
//  ForgotPasswordViewModel.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-15.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Moya
import Alamofire

class ForgotPasswordViewModel: BaseViewModel {
    var provider: MoyaProvider<ResetPasswordService>?
    
    /**
     Request pin code to reset password from backend.
     - Parameter String email
     - Returns: none
     */
    
    func requestPinCode(_ email: String) {
        //cancel previous request
        cancelCurrentRequest()
        
        provider = MoyaProvider<ResetPasswordService>(session: smartpodsManager(withSSL: true),
                                                      plugins: getMoyaPlugins())
            
            let parameters = ["Email": email]
        
            provider?.request(.forgotPassword(parameters)) { [weak self] result in
                self?.enableState?(true)
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        let result = GenericResponse(params: rawJson)
                        
                        guard result.Success else {
                            let message = rawJson["Message"] as? String ?? ""
                            if message.isEmpty {
                                self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                            } else {
                                self?.alertMessage?("generic.error_title".localize(),message,0)
                            }
                            
                            return
                        }
                        
                        self?.successResponse?(result)
                       
                    } catch {
                        self?.alertMessage?("generic.error_title".localize(),"forgot.other_error".localize(),0)
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
     Validate pin code from backend.
     - Parameter String pin code
     - Returns: none
     */
    
    func validatePincodeFromBackend(_ pincode: String) {
        
    }
    
    /**
     Request reset password from backend.
     - Parameter String email
     - Parameter String password
     - Parameter String code
     - Returns: none
     */
    
    func requestResetPassword(_ email: String, _ password: String, _ code: String) {
        cancelCurrentRequest()
        provider = MoyaProvider<ResetPasswordService>(session: smartpodsManager(withSSL: true),
                                                        plugins: getMoyaPlugins())
            
        let parameters = ["Email": email,
                          "Password":password,
                          "ResetCode":code]
        
            provider?.request(.forgotPasswordComplete(parameters)) { [weak self] result in
                self?.enableState?(true)
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        let result = GenericResponse(params: rawJson)
                        
                        guard result.Success else {
                            let message = rawJson["Message"] as? String ?? ""
                            if message.isEmpty {
                                self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                            } else {
                                self?.alertMessage?("generic.error_title".localize(),message,0)
                            }
                            
                            return
                        }
                        
                        self?.successResponse?(result)
                       
                    } catch {
                        self?.alertMessage?("generic.error_title".localize(),"forgot.other_error".localize(),0)
                    }
                    
                    
                case .failure(let error):
                    self?.alertMessage?("generic.error_title".localize(),error.errorDescription ?? "",0)
                }
            }
    }
    
    /**
     Request reset password from backend.
     - Parameter String email
     - Parameter String password
     - Parameter String code
     - Returns: none
     */
    
    func requestResetPasswordUserLogged(_ email: String,
                                        _ password: String,
                                        _ old_password: String,
                                        _ completion: @escaping ((_ object: [String:Any]) -> Void)) {
        cancelCurrentRequest()
        provider = MoyaProvider<ResetPasswordService>(requestClosure: MoyaProvider<ResetPasswordService>.endpointRequestResolver(),
                                                      session: smartpodsManager(withSSL: true),
                                                      plugins: getMoyaPlugins())
            
        let parameters = addTokenToParameter(params: ["email": email,
                                                      "oldpswd":old_password,
                                                      "pswd":password])
        
        
            provider?.request(.resetPasswordUserLogged(parameters)) { [weak self] result in
                self?.enableState?(true)
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        completion(rawJson)
                       
                    } catch {
                        self?.alertMessage?("generic.error_title".localize(),"forgot.other_error".localize(),0)
                    }
                    
                    
                case .failure(let error):
                    self?.alertMessage?("generic.error_title".localize(),error.errorDescription ?? "",0)
                    
                }
            }
    }
    
    /**
    Validate email.
    - Parameter String email
    - Returns: Bool status
    */
    
    func validateEmail(username: String) throws -> Bool {
        
        guard Utilities.instance.checkEmailAddress(email: username) else {
            throw ValidationError.InvalidEmailAddress
        }
        
        guard !username.isEmpty else {
            throw ValidationError.EmailRequired
        }
        
        return true
    }
    
    /**
    Initialize reset password.
    - Parameter String username
    - Returns: none
    */
    
    func initializePinCodeRequest(username: String)  {
        do {
            let validate =  try validateEmail(username: username)
            
            guard validate else {
                alertMessage?("generic.error_title".localize(),"generic.other_error".localize(), 0)
                return
            }
            
            requestPinCode(username)
            
        } catch let error as ValidationError {
            alertMessage?("generic.error_title".localize(),error.description,0)
        } catch {
            alertMessage?("generic.error_title".localize(),"generic.app_error".localize(), 0)
        }
    }
    
    /**
    Validate pin code.
    - Parameter String pin code
    - Returns: Bool status
    */
    
    func validatePincode(code: String) throws -> Bool {
        
        guard !code.isEmpty else {
            throw ForgotPasswordValidationError.PincodeRequired
        }
        
        return true
    }
    
    /**
    Initialize pin code..
    - Parameter String pincode
    - Returns: none
    */
    
    func initializePinCode(pincode: String)  {
        do {
            let validate =  try validatePincode(code: pincode)
            
            guard validate else {
                alertMessage?("generic.error_title".localize(),"generic.other_error".localize(), 0)
                return
            }
            
            //API_RESPONSE?(requestLogin(username, password))
            showIndicator?(true)
            
        } catch let error as ForgotPasswordValidationError {
            alertMessage?("generic.error_title".localize(),error.description,0)
        } catch {
            alertMessage?("generic.error_title".localize(),"generic.app_error".localize(), 0)
        }
    }
    
    /**
     Validate password.
     - Parameter String password
     - Parameter String verify password
     - Parameter String code
     - Returns: Bool status
    */
    
    func validatePassword(password: String, verifyPassword: String, code: String) throws -> Bool {
        
        guard (!password.isEmpty || !verifyPassword.isEmpty || !code.isEmpty) else {
            throw ForgotPasswordValidationError.EmptyForm
        }
        
        guard password == verifyPassword else {
            throw ForgotPasswordValidationError.PasswordNotEqual
        }
        
        guard !password.isEmpty else {
            throw ForgotPasswordValidationError.PasswordRequired
        }
        
        guard !verifyPassword.isEmpty else {
            throw ForgotPasswordValidationError.VerifyPasswordRequired
        }
        
        guard !code.isEmpty else {
            throw ForgotPasswordValidationError.PincodeRequired
        }
        
        return true
    }
    
    /**
       Initialize reset password.
        - Parameter String email
        - Parameter String code
        - Parameter String password
        - Parameter String verify_password
        - Returns: none
       */
       
    func intializeResetPassword(email: String, code: String, password: String, verify_password: String)  {
           do {
                let validate =  try validatePassword(password: password, verifyPassword: verify_password, code: code)
               
               guard validate else {
                   alertMessage?("generic.error_title".localize(),"generic.other_error".localize(), 0)
                   return
               }
               
               requestResetPassword(email, password, code)
               
           } catch let error as ForgotPasswordValidationError {
               alertMessage?("generic.error_title".localize(),error.description,0)
           } catch {
               alertMessage?("generic.error_title".localize(),"generic.app_error".localize(), 0)
           }
       }
    
    
    /**
     Validate password.
     - Parameter String password
     - Parameter String verify password
     - Parameter String code
     - Returns: Bool status
    */
    
    func validateResetPasswordUserLogged(email: String, new_password: String, verify_password: String, old_password: String) throws -> Bool {
        
        guard (!email.isEmpty || !new_password.isEmpty || !verify_password.isEmpty || !old_password.isEmpty) else {
            throw ForgotPasswordValidationError.ResetPasswordEmptyForm
        }
        
        guard Utilities.instance.checkEmailAddress(email: email) else {
            throw ValidationError.InvalidEmailAddress
        }
        guard !email.isEmpty else {
            throw ValidationError.EmailRequired
        }
        
        guard new_password == verify_password else {
            throw ForgotPasswordValidationError.NewPasswordAndVerifyPasswordNotEqual
        }
        
        guard !new_password.isEmpty else {
            throw ForgotPasswordValidationError.NewPasswordRequired
        }
        
        guard !verify_password.isEmpty else {
            throw ForgotPasswordValidationError.VerifyPasswordRequired
        }
        
        guard !old_password.isEmpty else {
            throw ForgotPasswordValidationError.OldPasswordRequired
        }
        
        return true
    }
    
    /**
       Initialize reset password when user is logged in.
        - Parameter String email
        - Parameter String old_password
        - Parameter String new_password
        - Parameter String verify_password
        - Returns: none
       */
       
    func intializeResetPasswordUserLogged(email: String,
                                          old_password: String,
                                          new_password: String,
                                          verify_password: String)  {
        
           do {
                let _email = Utilities.instance.getUserEmail()
                let validate =  try validateResetPasswordUserLogged(email: _email,
                                                                    new_password: new_password,
                                                                    verify_password: verify_password,
                                                                    old_password: old_password)
               
               guard validate else {
                   alertMessage?("generic.error_title".localize(),"generic.other_error".localize(), 0)
                   return
               }
               
                requestResetPasswordUserLogged(_email,
                                                 new_password,
                                                 old_password, {[weak self] (item) in
                                                    guard !item.isEmpty else {
                                                        return
                                                    }
                                                    
                                                    let result = GenericResponse(params: item)

                                                    guard result.Success else {
                                                        let message = item["Message"] as? String ?? ""
                                                        if message.isEmpty {
                                                            self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                                                        } else {
                                                            self?.alertMessage?("generic.error_title".localize(),message,0)
                                                        }

                                                        return
                                                    }
                                                    Utilities.instance.cleanUpUserInfo()
                                                    self?.successResponse?(result)
                                                    
              })
               
           } catch let error as ForgotPasswordValidationError {
               alertMessage?("generic.error_title".localize(),error.description,0)
           } catch {
               alertMessage?("generic.error_title".localize(),"generic.app_error".localize(), 0)
           }
       }
    
}
