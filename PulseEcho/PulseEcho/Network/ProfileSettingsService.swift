//
//  ProfileSettingsService.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-06.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import Moya
import Alamofire

/**
 Profile settings service abstract network layer for interfacing the web service.
*/

public enum ProfileSettingService {
    case getProfileSettings([String: Any])
    case updateProfileSettings([String: Any])
}

extension ProfileSettingService: TargetType {
    public var baseURL: URL {
      //return URL(string: Environment.instance.endpoint())!
        return API_ENDPOINT.baseURL
    }
    
    public var path: String {
        switch self {
        case .getProfileSettings:
            return API.settings + API.profileSettingSelect
        case .updateProfileSettings:
            return API.settings + API.profileSettingUpdate
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getProfileSettings, .updateProfileSettings:
            return .post
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .getProfileSettings(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .updateProfileSettings(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return requestHeaders()
    }
    
}

