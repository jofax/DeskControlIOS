//
//  UserReportsService.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-26.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import Moya
import Alamofire

/**
 User Statistics service abstract network layer for interfacing the web service.
*/

public enum UserReportService {
    case summary([String: Any])
    case deskMode([String: Any])
    case activity([String: Any])
}

extension UserReportService: TargetType {
    public var baseURL: URL {
      //return URL(string: Environment.instance.endpoint())!
        return API_ENDPOINT.baseURL
    }
    
    public var path: String {
        switch self {
        case .summary:
            return API.userReport + API.summaryReport
        case .deskMode:
            return API.userReport + API.deskModeReport
        case .activity:
            return API.userReport + API.activityReport
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .summary, .deskMode, .activity:
            return .post
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .summary(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .deskMode(let params):
                       return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .activity(let params):
                       return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return requestHeaders()
    }
    
}
