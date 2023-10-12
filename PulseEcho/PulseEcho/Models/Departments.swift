//
//  Departments.swift
//  PulseEcho
//
//  Created by Joseph on 2020-05-08.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
struct Departments {
    var Departments: [Department]
    var Success: Bool
    var ResultCode: Int
    var Message: String
}

extension Departments: Decodable {
    enum CodingKeys: String, CodingKey {
        case Departments = "Departments"
        case Success = "Success"
        case ResultCode = "ResultCode"
        case Message = "Message"
    }
    
    init(params: [String: Any]) {
        self.Departments = [Department]()
        let _departments = params["Departments"] as? [[String: Any]] ?? [[String: Any]]()
        
        for department in _departments {
            self.Departments.append(Department(params: department))
        }
        
        self.Success = params["Success"] as? Bool ?? false
        self.ResultCode = params["ResultCode"] as? Int ?? 0
        self.Message = params["Message"] as? String ?? ""
    }
}

struct Department {
    var ID: Int
    var Name: String
}

extension Department: Decodable {
    enum CodingKeys: String, CodingKey {
        case ID = "ID"
        case Name = "Name"
    }
    
    init(params: [String: Any]) {
        self.Name = params["Name"] as? String ?? ""
        self.ID = params["ID"] as? Int ?? 0
    }
}
