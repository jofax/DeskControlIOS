//
//  User.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-16.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {

    @objc dynamic var DepartmentID: Int = 0
    @objc dynamic var Email: String = ""
    @objc dynamic var Firstname: String = ""
    @objc dynamic var Lastname: String = ""
    @objc dynamic var YearOfBirth: Int = 0
    @objc dynamic var Gender: Int = 0
    @objc dynamic var Language: Int = 0
    @objc dynamic var AcknowledgedWaiver: Bool = false
    @objc dynamic var WatchedSafetyVideo: Bool = false
    @objc dynamic var StepType: Int = 0
    @objc dynamic var LifeStyle: Int = 0
    @objc dynamic var JobDescription: Int = 0
    @objc dynamic var LogoutWhenNotDetected: Bool = false
    @objc dynamic var Height: Int = 0
    @objc dynamic var Weight: Double = 0.0
    @objc dynamic var BMI: Double = 0.0
    @objc dynamic var BMR: Double = 0.0
    @objc dynamic var HeartsToday: Double = 0.0
    @objc dynamic var HeartsTotal: Double = 0.0
    @objc dynamic var AvgHoursFillHeart: Double = 0.0
    @objc dynamic var TaskBarNotification: Bool =  false
    @objc dynamic var AutoLogin: Bool =  false
    @objc dynamic var AcknowledgedWaiverDate: String = ""
    @objc dynamic var IsImperial: Bool =  false
    
    required override init() {}
    
    override static func primaryKey() -> String? {
        return "Email"
    }
    
    init(params: [String: Any]) {
        self.DepartmentID = params["DepartmentID"] as? Int ?? 0
        self.Email = params["Email"] as? String ?? ""
        self.Firstname = params["Firstname"] as? String ?? ""
        self.Lastname = params["Lastname"] as? String ?? ""
        self.YearOfBirth = params["YearOfBirth"] as? Int ?? 0
        self.Gender = params["Gender"] as? Int ?? 0
        self.Language = params["Language"] as? Int ?? 0
        self.AcknowledgedWaiver = params["AcknowledgedWaiver"] as? Bool ?? false
        self.WatchedSafetyVideo = params["WatchedSafetyVideo"] as? Bool ?? false
        self.StepType = params["StepType"] as? Int ?? 0
        self.LifeStyle = params["LifeStyle"] as? Int ?? 0
        self.JobDescription = params["JobDescription"] as? Int ?? 0
        self.LogoutWhenNotDetected = params["LogoutWhenNotDetected"] as? Bool ?? false
        self.Height = params["Height"] as? Int ?? 0
        self.Weight = params["Weight"] as? Double ?? 0
        self.BMI = params["BMI"] as? Double ?? 0.0
        self.BMR = params["BMR"] as? Double ?? 0.0
        
        let hearts = params["Hearts"] as? [String: Any] ?? [String:Any]()
        
        self.HeartsToday = hearts["Today"] as? Double ?? 0.0
        self.HeartsTotal = hearts["Total"] as? Double ?? 0.0
        self.AvgHoursFillHeart = hearts["AvgHoursFillHeart"] as? Double ?? 0.0
    }
    

    
    func generateUserParams() -> [String: Any] {
        return ["User":["DepartmentID":self.DepartmentID,
                        "Email": self.Email,
                        "Language": self.Language,
                        "AcknowledgedWaiver": self.AcknowledgedWaiver,
                        "WatchedSafetyVideo": self.WatchedSafetyVideo,
                        "StepType": self.StepType,
                        "JobDescription": self.JobDescription,
                        "LogoutWhenNotDetected": self.LogoutWhenNotDetected,
                        "Firstname": self.Firstname,
                        "Lastname": self.Lastname,
                        "Weight": self.Weight,
                        "Height": self.Height,
                        "YearOfBirth": self.YearOfBirth,
                        "Gender": self.Gender,
                        "LifeStyle": self.LifeStyle,
                        "TaskBarNotification": self.TaskBarNotification,
                        "AutoLogin": self.AutoLogin,
                        "AcknowledgedWaiverDate": self.AcknowledgedWaiverDate,
                        "IsImperial": self.IsImperial]]
    }
}



