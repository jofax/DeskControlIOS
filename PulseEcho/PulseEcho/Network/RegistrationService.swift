//
//  RegistrationService.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-16.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import Moya
import Alamofire

/**
 RegistrationService abstract network layer for interfacing the web service.
*/

public enum RegistrationService {
    case registerUser([String: String])
}

extension RegistrationService: TargetType {
    public var baseURL: URL {
      //return URL(string: Environment.instance.endpoint())!
        return API_ENDPOINT.baseURL
    }
    
    public var path: String {
        switch self {
        case .registerUser:
            return API.account + API.registration
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .registerUser:
            return .post
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .registerUser(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return requestHeaders()
    }
    
}
