//
//  AuthTokenService.swift
//  PulseEcho
//
//  Created by Joseph on 2020-06-09.
//  Copyright © 2020 Smartpods. All rights reserved.
//



import Foundation
import Moya
import Alamofire

/**
 AuthToken service abstract network layer for interfacing the web service.
*/

public enum AuthTokenService {
    case renewSessionKey([String: Any])
}

extension AuthTokenService: TargetType {
    public var baseURL: URL {
        return API_ENDPOINT.baseURL
    }
    
    public var path: String {
        switch self {
        case .renewSessionKey:
            return API.account + API.renewToken
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .renewSessionKey:
            return .post
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .renewSessionKey(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return requestHeaders()
    }
    
}

extension AuthTokenService {
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
