//
//  DeskActivity.swift
//  PulseEcho
//
//  Created by Joseph on 2021-04-16.
//  Copyright © 2021 Smartpods. All rights reserved.
//

import Foundation
import RealmSwift

class DeskActivity: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var Serial: String = ""
    @objc dynamic var Identifier: String = ""
    @objc dynamic var Email: String = ""
    @objc dynamic var HeartSaved: Double = 0.0
    @objc dynamic var Timestamp: Int64 = 0
    
    
    required override init() {}

    override static func primaryKey() -> String? {
        return "id"
    }

    init(params: [String: Any]) {
        self.id = "\(Utilities.instance.getCurrentMillis())"
        self.Identifier = params["Identifier"] as? String ?? ""
        self.Serial = params["Serial"] as? String ?? ""
        self.Email = params["Email"] as? String ?? ""
        self.HeartSaved = params["Hearts_today"] as? Double ?? 0.0
        self.Timestamp = Utilities.instance.getCurrentMillis()
    }

}

