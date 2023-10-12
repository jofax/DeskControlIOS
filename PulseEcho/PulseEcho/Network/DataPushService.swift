//
//  DataPushService.swift
//  PulseEcho
//
//  Created by Joseph on 2021-04-30.
//  Copyright © 2021 Smartpods. All rights reserved.
//

import Foundation
import Moya
import Alamofire

/**
 AuthToken service abstract network layer for interfacing the web service.
*/

public enum DataPushService {
    case pushData(Data)
}

extension DataPushService: TargetType {
    public var baseURL: URL {
        return API_ENDPOINT.baseURL
    }
    
    public var path: String {
        switch self {
        case .pushData:
            return API.dataResults + API.queue
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .pushData:
            return .post
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .pushData(let object):
            return .requestData(object)
        }
    }
    
    public var headers: [String : String]? {
        return ["Content-Type" : "application/octet-stream"]
    }
    
}

extension DataPushService {
    public var urlRequest: URLRequest {
        let defaultURL: URL
        if path.isEmpty {
            defaultURL = baseURL
        } else {
            defaultURL = baseURL.appendingPathComponent(path)
        }

        let endpoint = MoyaProvider.defaultEndpointMapping(for: self)
        do {
            return try endpoint.urlRequest()
        } catch {
            return URLRequest(url: defaultURL)
        }
    }
}
