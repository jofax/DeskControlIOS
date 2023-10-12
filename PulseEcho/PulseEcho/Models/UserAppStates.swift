//
//  UserAppStates.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-16.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import RealmSwift

class UserAppStates: Object {
    @objc dynamic var DeviceId: String = ""
    @objc dynamic var SerialNumber: String = ""
    @objc dynamic var Email: String = ""
    @objc dynamic var UserId: Int = 0
    @objc dynamic var InteractivePopUpShowed: Bool = false
    @objc dynamic var SafetyPopUpShowed: Bool = false
    @objc dynamic var UserVM: String = ""
    @objc dynamic var UserDeskMode: String = ""
    @objc dynamic var BLEUUID: String = ""
    @objc dynamic var OrgCode: String = ""
    @objc dynamic var OrgName: String = ""
    @objc dynamic var SessionExpiryDated: String = ""
    @objc dynamic var SessionDated: String = ""
    @objc dynamic var SessionKey: String = ""
    @objc dynamic var RenewalKey: String = ""
    @objc dynamic var AutomaticControls: Bool = false
    @objc dynamic var LegacyControls: Bool = false
    
    @objc dynamic var BLECheck: Bool = false
    @objc dynamic var DateDataBeenPurge: Int64 = 0
    @objc dynamic var LocalDataExpiry: Int64 = 0
    @objc dynamic var HasOrgCode: Bool = false
    
    // need to save device vertical movement
    
    required override init() {
       self.DeviceId = ""
       self.SerialNumber = ""
       self.Email = ""
       self.UserId = 0
       self.InteractivePopUpShowed = false
       self.SafetyPopUpShowed = false
       self.UserVM = ""
       self.UserDeskMode = ""
       self.BLEUUID = ""
       self.OrgCode = ""
       self.OrgName = ""
       self.SessionExpiryDated = ""
       self.SessionDated = ""
       self.SessionKey  = ""
       self.RenewalKey  = ""
       self.AutomaticControls = false
       self.LegacyControls  = false
       self.DateDataBeenPurge = 0
       self.LocalDataExpiry  = 0
       self.HasOrgCode = false
    }

    override static func primaryKey() -> String? {
        return "Email"
    }
    
    init(params: [String: Any]) {
         self.DeviceId = params["DeviceId"] as? String ?? ""
         self.Email = params["Email"] as? String ?? ""
         self.SerialNumber = params["SerialNumber"] as? String ?? ""
         self.Email = params["Email"] as? String ?? ""
         self.UserId = params["UserId"] as? Int ?? 0
         self.UserVM = params["UserVM"] as? String ?? ""
         self.UserDeskMode = params["UserDeskMode"] as? String ?? ""
         self.InteractivePopUpShowed = params["InteractivePopUpShowed"] as? Bool ?? false
         self.SafetyPopUpShowed = params["SafetyPopUpShowed"] as? Bool ?? false
         self.BLEUUID = params["BLEUUID"] as? String ?? ""
         self.OrgCode = params["OrgCode"] as? String ?? ""
         self.OrgName = params["OrgName"] as? String ?? ""
         self.SessionExpiryDated = params["SessionExpiryDated"] as? String ?? ""
         self.SessionDated = params["SessionDated"] as? String ?? ""
         self.SessionKey  = params["SessionKey"] as? String ?? ""
         self.RenewalKey  = params["RenewalKey"] as? String ?? ""
         self.DateDataBeenPurge = params["DateDataBeenPurge"] as? Int64 ??  0
         self.LocalDataExpiry = params["LocalDataExpiry"] as? Int64 ?? 0
         self.HasOrgCode = (self.OrgCode.isEmpty) ? false : true
    }
}
