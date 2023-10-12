//
//  Environment.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-03.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import UIKit

//class Environment: NSObject {
//    static let instance = Environment()
//    var configs: NSDictionary = NSDictionary()
//    var api_endpoint = ""
//    var env = ""
//
//    override init() {
//        let currentConfiguration = Bundle.main.object(forInfoDictionaryKey: "Config")!
//        print("currentConfiguration: \(currentConfiguration)")
//        let path = Bundle.main.path(forResource: "Environment", ofType: "plist")!
//        guard let dict = NSDictionary(contentsOfFile: path) else { return }
//        guard let dictObject = dict.object(forKey: currentConfiguration) else { return }
//        configs = dictObject as! NSDictionary
//        api_endpoint = configs.object(forKey: "APIEndpointURL") as! String
//        env = configs.object(forKey: "name") as! String
//    }
//}
//
//extension Environment {
//
//    func environmentConfig() -> String {
//       return env
//    }
//
//    func endpoint() -> String {
//        return api_endpoint
//    }
//
//}

enum Environment {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
}

enum API_ENDPOINT {
    static var env: String {
        return try! Environment.value(for: "AppEnvironment")
    }
    
    static var baseURL: URL {
        var _prefix = "https://"
        if env == "Development" {
             _prefix = "https://"
        }
        return try! URL(string: _prefix + Environment.value(for: "APIEndpointURL"))!
       
    }
    
    static var endpoint: String {
        var _prefix = "https://"
        
        if env == "Development" {
             _prefix = "https://"
        }
        
        return try! _prefix + Environment.value(for: "APIEndpointURL")
    }
    
}

enum LOGS {
    static var BLELOGS: String {
        return try! Environment.value(for: "BLEDataLogs")
    }
    
    static var BUILDTYPE: String {
        return try! Environment.value(for: "BuildType")
    }
}

enum NetworkLogs {
    static var APILogs: String {
        return try! Environment.value(for: "APILogs")
    }
    
    static var enabled: Bool {
        return APILogs.boolValue
    }
    
}

enum SchemaVersion {
    static var version: Int {
        return try! Environment.value(for: "SchemaVersion")
    }
}

enum APIVersion {
    static var version: String {
        return try! Environment.value(for: "APIVersion")
    }
}
