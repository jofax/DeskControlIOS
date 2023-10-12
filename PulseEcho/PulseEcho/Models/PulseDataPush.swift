//
//  DataPush.swift
//  PulseEcho
//
//  Created by Joseph on 2021-04-28.
//  Copyright © 2021 Smartpods. All rights reserved.
//

import Foundation
import RealmSwift

class PulseDataPush: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var Serial: String = ""
    @objc dynamic var Email: String = ""
    @objc dynamic var AESKey: String = ""
    @objc dynamic var AESIV: String = ""
    
    required override init() {}

    override static func primaryKey() -> String? {
        return "id"
    }

    init(params: [String: Any]) {
        self.id = "\(Utilities.instance.getCurrentMillis())"
        self.Serial = params["Serial"] as? String ?? ""
        self.Email = params["Email"] as? String ?? ""
        self.AESKey = params["AESKey"] as? String ?? ""
        self.AESIV = params["AESIV"] as? String ?? ""
    }
}
