//
//  UserService.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-29.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import Moya
import Alamofire

/**
 User service abstract network layer for interfacing the web service.
*/

public enum UserService {
    case getUser([String: Any])
    case updateUser([String: Any])
    case getDepartments([String: Any])
}

extension UserService: TargetType {
    public var baseURL: URL {
      //return URL(string: Environment.instance.endpoint())!
        return API_ENDPOINT.baseURL
    }
    
    public var path: String {
        switch self {
        case .getUser:
            return API.settings + API.clientSelect
        case .updateUser:
            return API.settings + API.clientUpdate
        case .getDepartments:
            return API.configuration + API.listDepartments

        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getUser, .updateUser, .getDepartments:
            return .post
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .getUser(let params), .updateUser(let params), .getDepartments(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return requestHeaders()
    }
    
}

