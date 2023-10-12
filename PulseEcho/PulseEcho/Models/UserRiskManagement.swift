//
//  UserRiskManagement.swift
//  PulseEcho
//
//  Created by Joseph on 2020-04-09.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation

struct UserRiskManagement {
    var id: Int64?
    var Email: String
    var Level: Int
    var Progress: Double

}

extension UserRiskManagement: Hashable {}

extension UserRiskManagement: Codable {
    // Update a user id after it has been inserted in the database.
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
    init(params: [String: Any]) {
        self.Email = params["Email"] as? String ?? ""
        self.Level = params["Level"] as? Int ?? 0
        self.Progress = params["Progress"] as? Double ?? 0.0
   }
}
