//
//  Login.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-16.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation

/**
 
 Succeeded = 0,
 RequiresEmailVerification = 1,
 AccountIsLocked = 2,
 FailedVerifyUser = 3,
 InvalidOrganization = 4,
 NotRegistredDevice = 5,
 Unknown = 6
 UnknownOrgCode = 8
 */

struct Login {
    var SessionDated: String
    var SessionKey: String
    var SessionExpiryDated: String
    var RenewalKey: String
    var Success: Bool
    var ResultCode: Int
    var Message: String
}

extension Login: Decodable {
    enum CodingKeys: String, CodingKey {
        case SessionDated = "SessionDated"
        case SessionKey = "SessionKey"
        case RenewalKey = "RenewalKey"
        case Success = "Success"
        case ResultCode = "ResultCode"
        case Message = "Message"
        case SessionExpiryDated = "SessionExpiryDated"
    }
    
    init(session_date: String,
         session_key: String,
         renewal_key: String,
         success: Bool,
         result_code: Int,
         message: String,
         session_expiry: String) {
        self.SessionDated = session_date
        self.SessionKey = session_key
        self.RenewalKey = renewal_key
        self.Success = success
        self.ResultCode = result_code
        self.Message = message
        self.SessionExpiryDated = session_expiry
    }
    
    init(params: [String: Any]) {
        self.SessionDated = params["SessionDated"] as? String ?? ""
        self.SessionKey = params["SessionKey"] as? String ?? ""
        self.RenewalKey = params["RenewalKey"] as? String ?? ""
        self.Success = params["Success"] as? Bool ?? false
        self.ResultCode = params["ResultCode"] as? Int ?? 0
        self.Message = params["Message"] as? String ?? ""
        self.SessionExpiryDated = params["SessionExpiryDated"] as? String ?? ""
    }
}
