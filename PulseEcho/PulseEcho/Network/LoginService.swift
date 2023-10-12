//
//  LoginService.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-16.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import Moya
import Alamofire

/**
 Login service abstract network layer for interfacing the web service.
*/

public enum LoginService {
    case loginUser([String: String])
    case activateUser([String: String])
    case resendActivation([String: Any])
}

extension LoginService: TargetType {
    public var baseURL: URL {
      //return URL(string: Environment.instance.endpoint())!
        return API_ENDPOINT.baseURL
    }
    
    public var path: String {
        switch self {
        case .loginUser:
            return API.account + API.login
        case .activateUser:
            return API.account + API.activate
        case .resendActivation:
            return API.account + API.resendActivation
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .loginUser, .resendActivation:
            return .post
        case .activateUser:
            return .post
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .loginUser(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .activateUser(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .resendActivation(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return requestHeaders()
    }
    
}
