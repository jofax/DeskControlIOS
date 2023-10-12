//
//  Registration.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-16.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation

struct Registration {
    var Success: Bool
    var ResultCode: Int
    var Message: String
}

extension Registration: Codable {
    enum CodingKeys: String, CodingKey {
        case Success = "succeeded"
        case ResultCode = "ResultCode"
        case Message = "message"
    }
    
    init(success: Bool,
         code: Int,
         message: String) {
        self.Success = success
        self.ResultCode = code
        self.Message = message
    }
    
    init(params: [String: Any]) {
        self.Success = params["Success"] as? Bool ?? false
        self.ResultCode = params["ResultCode"] as? Int ?? 0
        self.Message = params["Message"] as? String ?? ""
    }
}
