//
//  DeskService.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-05.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import Moya
import Alamofire

/**
 Desk service abstract network layer for interfacing the web service.
*/

public enum DeskService {
    case deviceConnect([String: Any])
    case getBookingInfo(DeskBooking)
}

extension DeskService: TargetType {
    public var baseURL: URL {
      //return URL(string: Environment.instance.endpoint())!
        return API_ENDPOINT.baseURL
    }
    
    public var path: String {
        switch self {
            case .deviceConnect:
                return API.device + API.connect
            case .getBookingInfo:
                return API.configuration + API.getBooking
        }
        
    }
    
    public var method: Moya.Method {
        switch self {
        case .deviceConnect:
            return .post
        case .getBookingInfo:
            return .post
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .deviceConnect(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getBookingInfo(let params):
            return .requestJSONEncodable(params)
        }
    }
    
    public var headers: [String : String]? {
        return requestHeaders()
    }
    
}

