//
//  UserRiskAssessment.swift
//  PulseEcho
//
//  Created by Joseph on 2020-04-09.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import Moya
import Alamofire

/**
 User risk assessment service abstract network layer for interfacing the web service.
*/

public enum UserRiskAssessmentService {
    case getUserRiskAssessment([String: Any])
}

extension UserRiskAssessmentService: TargetType {
    public var baseURL: URL {
      //return URL(string: Environment.instance.endpoint())!
        return API_ENDPOINT.baseURL
    }
    
    public var path: String {
        switch self {
        case .getUserRiskAssessment:
            return API.settings + API.clientUserRiskAssessment
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getUserRiskAssessment:
            return .post
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .getUserRiskAssessment(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return requestHeaders()
    }
    
}
