//
//  PulseDevices.swift
//  PulseEcho
//
//  Created by Joseph on 2020-10-06.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import RealmSwift

class PulseDevices: Object {
    @objc dynamic var Serial: String = ""
    @objc dynamic var Identifier: String = ""
    @objc dynamic var Email: String = ""
    @objc dynamic var PeripheralName: String = ""
    @objc dynamic var State: Int = 0
    @objc dynamic var UserProfile: String = ""
    @objc dynamic var DisconnectedByUser: Bool = false
    
    required override init() {}

    override static func primaryKey() -> String? {
        return "Email"
    }

    init(params: [String: Any]) {
        self.Identifier = params["Identifier"] as? String ?? ""
        self.Serial = params["Serial"] as? String ?? ""
        self.Email = params["Email"] as? String ?? ""
        self.PeripheralName = params["PeripheralName"] as? String ?? ""
        self.State = params["State"] as? Int ?? 0
        self.UserProfile = params["UserProfile"] as? String ?? ""
        self.DisconnectedByUser = params["DisconnectedByUser"] as? Bool ?? false
    }

}
