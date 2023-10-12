//
//  UserRiskManagement.swift
//  PulseEcho
//
//  Created by Joseph on 2020-04-09.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import Moya

class UserRiskManagementViewModel: BaseViewModel {
    //CLASS VARIABLES
    var provider: MoyaProvider<UserRiskAssessmentService>?
    
    override init() {
        super.init()
    }
    
    override func cancelCurrentRequest() {
        //provider?.session.session.invalidateAndCancel()
    }
    
    /**
    Request user risk assessment data
    - Parameter [String: Any] parameters
    - Parameter Closure completion handler
    - Returns: none
    */
    
    func requestUserRiskAssessment(_ completion: @escaping (( _ response: UserRiskManagement) -> Void)) {
        cancelCurrentRequest()
        provider = MoyaProvider<UserRiskAssessmentService>(requestClosure: MoyaProvider<SurveyService>.endpointRequestResolver(),
                                                           session: smartpodsManager(withSSL: true),
                                             plugins: getMoyaPlugins())
            let final_params = addTokenToParameter(params: [:])
            provider?.request(.getUserRiskAssessment(final_params)) { [weak self] result in
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        
                        guard !rawJson.isEmpty else {
                            return
                        }

                        let _other_response = GenericResponse(success: rawJson["Success"] as? Bool ?? false,
                                                              code: rawJson["ResultCode"] as? Int ?? -1,
                                                              message: rawJson["Message"] as? String ?? "")
                        guard _other_response.Success else {
                           if _other_response.Message.isEmpty {
                               self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                               print("requestUserRiskAssessment error | info: \(Utilities.instance.loginfo())")
                           } else {
                               self?.alertMessage?("generic.error_title".localize(),_other_response.Message,0)
                               print("requestUserRiskAssessment error: \(_other_response.Message) | info: \(Utilities.instance.loginfo())")
                           }

                           return
                        }
                        
                        let riskAssessment = UserRiskManagement(params: rawJson)
                        print("rawJson: ", rawJson)
                        completion(riskAssessment)
                        
                    } catch {
                        //self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                        print("requestUserRiskAssessment error | info: \(Utilities.instance.loginfo())")
                        if response.statusCode == 401 {
                            self?.apiCallback?(error, 6)
                        } else {
                            self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                            print("requestProfileSettings error | info: \(Utilities.instance.loginfo())")
                        }
                    }
                    
                case .failure(let error):
                    self?.alertMessage?("generic.error_title".localize(),error.errorDescription ?? "",0)
                    print("requestUserRiskAssessment error: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                    
                }
            }
    }
}
