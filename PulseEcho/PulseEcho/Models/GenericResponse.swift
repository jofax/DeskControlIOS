//
//  GenericResponse.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-28.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation

enum LOGIN_RESULT_CODE: Int {
    case Succeeded = 0
    case RequiresEmailVerification = 1
    case AccountIsLocked = 2
    case FailedVerifyUser = 3
    case InvalidOrganizationOrDesk = 4
    case Unknown = 5
}

struct GenericResponse {
    var Success: Bool
    var ResultCode: Int
    var Message: String
}

extension GenericResponse: Codable {
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
        self.ResultCode = params["ResultCode"] as? Int ?? -1
        self.Message = params["Message"] as? String ?? ""
    }
}

struct ResponseMessage {
    var title: String
    var message: String
}

extension ResponseMessage: Codable {
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case message = "message"
    }
    
    init(content: [String: String]) {
        self.title = content["title"] ?? ""
        self.message = content["message"] ?? ""
    }
}
