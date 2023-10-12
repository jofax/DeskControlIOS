//
//  Settings.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-05.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import RealmSwift

protocol Profile: ReflectedStringConvertible {
    var ProfileID: Int { get set }
    var SerialNumber: String { get set }
    var Email: String { get set }
    var StandingTime1: Int { get set }
    var StandingTime2: Int { get set }
    var ProfileSettingType: Int { get set }
    var SittingPosition: Int { get set }
    var StandingPosition: Int { get set }
    var IsInteractive: Bool { get set }
}

struct ProfileSettingsData: Profile {
    var ProfileID: Int
    var SerialNumber: String
    var Email: String
    var StandingTime1: Int
    var StandingTime2: Int
    var ProfileSettingType: Int
    var SittingPosition: Int
    var StandingPosition: Int
    var IsInteractive: Bool
    
    init() {
        self.ProfileID = 0
        self.SerialNumber = ""
        self.Email = ""
        self.StandingTime1 = 0
        self.StandingTime2 = 0
        self.ProfileSettingType = -1
        self.SittingPosition = 0
        self.StandingPosition = 0
        self.IsInteractive = false
    }
    
    init(data: ProfileSettings) {
        ProfileID = data.ProfileID
        SerialNumber = data.SerialNumber
        Email = data.Email
        StandingTime1 = data.StandingTime1
        StandingTime2 = data.StandingTime2
        ProfileSettingType = data.ProfileSettingType
        SittingPosition = data.SittingPosition
        StandingPosition = data.StandingPosition
        IsInteractive = data.IsInteractive
    }
    
    func generateProfileParameters() -> [String: Any] {
       return ["settings":["Email":self.Email,
                           "StandingTime1":self.StandingTime1,
                           "StandingTime2":self.StandingTime2,
                           "ProfileSettingType":self.ProfileSettingType,
                           "SittingPosition":self.SittingPosition,
                           "StandingPosition":self.StandingPosition,
                           "IsInteractive":self.IsInteractive]]
       
    }
}

class ProfileSettings: Object {
    @objc dynamic var ProfileID: Int
    @objc dynamic var SerialNumber: String
    @objc dynamic var Email: String
    @objc dynamic var StandingTime1: Int
    @objc dynamic var StandingTime2: Int
    @objc dynamic var ProfileSettingType: Int
    @objc dynamic var SittingPosition: Int
    @objc dynamic var StandingPosition: Int
    @objc dynamic var IsInteractive: Bool
    
    required override init() {
        self.ProfileID = 0
        self.SerialNumber = ""
        self.Email = ""
        self.StandingTime1 = 0
        self.StandingTime2 = 0
        self.ProfileSettingType = -1
        self.SittingPosition = 0
        self.StandingPosition = 0
        self.IsInteractive = false
    }
    
    override static func primaryKey() -> String? {
        return "Email"
    }
    
    init(params: [String: Any]) {
         
         let _settings = params["Settings"] as? [String: Any]
         self.ProfileID = _settings?["ProfileID"] as? Int ?? 0
         self.SerialNumber = _settings?["SerialNumber"] as? String ?? ""
         self.Email = _settings?["Email"] as? String ?? ""
         self.StandingTime1 = _settings?["StandingTime1"] as? Int ?? 0
         self.StandingTime2 = _settings?["StandingTime2"] as? Int ?? 0
         self.ProfileSettingType = _settings?["ProfileSettingType"] as? Int ?? -1
         self.SittingPosition = _settings?["SittingPosition"] as? Int ?? 0
         self.StandingPosition = _settings?["StandingPosition"] as? Int ?? 0
         self.IsInteractive = _settings?["IsInteractive"] as? Bool ?? false
    }
     
     func generateProfileParameters() -> [String: Any] {
//         return ["settings":["SerialNumber":self.SerialNumber,
//                             "Email":self.Email,
//                             "StandingTime1":self.StandingTime1,
//                             "StandingTime2":self.StandingTime2,
//                             "ProfileSettingType":self.ProfileSettingType,
//                             "SittingPosition":self.SittingPosition,
//                             "StandingPosition":self.StandingPosition,
//                             "IsInteractive":self.IsInteractive]]
        
        return ["settings":["Email":self.Email,
                            "StandingTime1":self.StandingTime1,
                            "StandingTime2":self.StandingTime2,
                            "ProfileSettingType":self.ProfileSettingType,
                            "SittingPosition":self.SittingPosition,
                            "StandingPosition":self.StandingPosition,
                            "IsInteractive":self.IsInteractive]]
        
     }
    
    
    func createNewProfileObject() -> ProfileSettings {
        let newProfile = ProfileSettings()
        
        newProfile.Email = self.Email
        //newProfile.SerialNumber = self.SerialNumber
        newProfile.StandingTime1 = self.StandingTime1
        newProfile.StandingTime2 = self.StandingTime2
        newProfile.ProfileSettingType = self.ProfileSettingType
        newProfile.SittingPosition = self.SittingPosition
        newProfile.StandingPosition = self.StandingPosition
        newProfile.IsInteractive = self.IsInteractive
        
        return newProfile
    }
}
