//
//  ResetPassword.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-28.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import Moya
import Alamofire

/**
 Reset password service abstract network layer for interfacing the web service.
*/

public enum ResetPasswordService {
    case forgotPassword([String: Any])
    case forgotPasswordComplete([String:Any])
    case resetPasswordUserLogged([String:Any])
}

extension ResetPasswordService: TargetType {
    public var baseURL: URL {
      //return URL(string: Environment.instance.endpoint())!
        return API_ENDPOINT.baseURL
    }
    
    public var path: String {
        switch self {
        case .forgotPassword:
            return API.account + API.forgotPassword
        case .forgotPasswordComplete:
            return API.account + API.forgotPasswordComplete
        case .resetPasswordUserLogged:
            return API.account + API.updatePassword
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .forgotPassword:
            return .post
        case .forgotPasswordComplete:
            return .post
        case .resetPasswordUserLogged:
            return .post
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .forgotPassword(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .forgotPasswordComplete(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .resetPasswordUserLogged(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return requestHeaders()
    }
    
}
