//
//  Statistics.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-26.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import DynamicCodable

//Statistics

struct Statistics {
    var id: Int64?
    var Email: String?
    var ModePercentage: DeskModePercentage
    var UpDownPerHour: Double
    var TotalActivity: Double
    var ActivityByDesk: [DeskActivities]
    
    enum CodingKeys: String, CodingKey {
        case id
        case Email
        case ModePercentage
        case UpDownPerHour
        case TotalActivity
        case ActivityByDesk
    }
}

extension Statistics: Hashable {
    static func == (lhs: Statistics, rhs: Statistics) -> Bool {
        return lhs.id == rhs.id &&
            lhs.Email == rhs.Email &&
            lhs.ModePercentage == rhs.ModePercentage &&
            lhs.UpDownPerHour == rhs.UpDownPerHour &&
            lhs.ActivityByDesk == rhs.ActivityByDesk
    }
}
extension Statistics: Codable {
//    private enum Columns {
//        static let id = Column(CodingKeys.id)
//        static let Email = Column(CodingKeys.Email)
//        static let ModePercentage = Column(CodingKeys.ModePercentage)
//        static let UpDownPerHour = Column(CodingKeys.UpDownPerHour)
//        static let ActivityByDesk = Column(CodingKeys.ActivityByDesk)
//    }

    // Update a user id after it has been inserted in the database.
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }

    init(params: [String: Any], email :String) {
        self.Email = email
        self.UpDownPerHour = params["UpDownPerHour"] as? Double ?? 0.0
        self.TotalActivity = params["TotalActivity"] as? Double ?? 0.0
        self.ModePercentage = DeskModePercentage(params: params["ModePercentage"] as? [String : Any] ?? [String: Any](), email: email)
        self.ActivityByDesk = [DeskActivities]()
        if let activity = params["ActivityByDesk"] as? [[String:Any]] {
            for item in activity {
                self.ActivityByDesk.append(DeskActivities(params: item, email: email))
            }
        }
        
    }
}


// DeskModePercentage

struct DeskModePercentage {
    var id: Int64?
    var Email: String?
    var SemiAutomatic: Double
    var Automatic: Double
    var Manual: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case Email
        case SemiAutomatic
        case Automatic
        case Manual
    }
}
extension DeskActivities: Hashable {}
extension DeskModePercentage: Codable {
    init(params: [String: Any], email :String) {
        self.Email = email
        self.SemiAutomatic = params["SemiAutomatic"] as? Double ?? 0.0
        self.Automatic = params["Automatic"] as? Double ?? 0.0
        self.Manual = params["Manual"] as? Double ?? 0.0
        
    }
}

// DeskActivities

struct DeskActivities {
    var id: Int64?
    var Email: String?
    var SerialNumber: String
    var PercentStanding: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case Email
        case SerialNumber
        case PercentStanding
    }
}
extension DeskModePercentage: Hashable {}
extension DeskActivities: Codable{
   
    init(params: [String: Any], email :String) {
        self.Email = email
        self.SerialNumber = params["SerialNumber"] as? String ?? ""
        self.PercentStanding = params["PercentStanding"] as? Double ?? 0.0
    }
}

//Hourly Modes

struct HourlyMode {
    var id: Int64?
    var Email: String?
    var StartDate: String?
    var EndDate: String?
    var Hour: Double
    var SemiAutomatic: Double
    var Automatic: Double
    var Manual: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case Email
        case StartDate
        case EndDate
        case Hour
        case SemiAutomatic
        case Automatic
        case Manual
    }
}
extension HourlyMode: Hashable {}
extension HourlyMode: Codable {
    
    init(params: [String: Any], email :String, startDate: String, endDate: String) {
        self.Email = email
        self.StartDate = startDate
        self.EndDate = endDate
        self.Hour = params["Hour"] as? Double ?? 0.0
        self.SemiAutomatic = params["SemiAutomatic"] as? Double ?? 0.0
        self.Automatic = params["Automatic"] as? Double ?? 0.0
        self.Manual = params["Manual"] as? Double ?? 0.0
    }
}

//DailyModes

struct DailyMode {
    var id: Int64?
    var Email: String?
    var StartDate: String?
    var EndDate: String?
    var Weekday: String
    var SemiAutomatic: Double
    var Automatic: Double
    var Manual: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case Email
        case StartDate
        case EndDate
        case Weekday
        case SemiAutomatic
        case Automatic
        case Manual
    }
}

extension DailyMode: Hashable {}
extension DailyMode: Codable {
    
    init(params: [String: Any], email :String, startDate: String, endDate: String) {
        self.Email = email
        self.StartDate = startDate
        self.EndDate = endDate
        self.Weekday = params["Weekday"] as? String ?? ""
        self.SemiAutomatic = params["SemiAutomatic"] as? Double ?? 0.0
        self.Automatic = params["Automatic"] as? Double ?? 0.0
        self.Manual = params["Manual"] as? Double ?? 0.0
    }
}

//Mode Report

struct ModeReport {
    var id: Int64?
    var Email: String?
    var StartDate: String?
    var EndDate: String?
    
    var ModePercent: DeskModePercentage
    var HourlyModes: [HourlyMode]
    var DailyModes: [DailyMode]
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case Email
        case StartDate
        case EndDate
        case ModePercent
        case HourlyModes
        case DailyModes
    }
}

extension ModeReport: Hashable {}
extension ModeReport: Codable{
    
    init(params: [String: Any], email :String, startDate: String, endDate: String) {
        self.Email = email
        self.StartDate = startDate
        self.EndDate = endDate
        self.DailyModes = [DailyMode]()
        self.HourlyModes = [HourlyMode]()
       
        let modePercentage = params["ModePercent"] as? [String:Any] ?? [String: Any]()
        self.ModePercent = DeskModePercentage(params: modePercentage, email: email)
        
        if let hourly = params["HourlyModes"] as? [[String:Any]] {
            for item in hourly {
                self.HourlyModes.append(HourlyMode(params: item, email: email, startDate: startDate, endDate: endDate))
            }
        }
        
        if let daily = params["DailyModes"] as? [[String:Any]] {
            for item in daily {
                self.DailyModes.append(DailyMode(params: item, email: email, startDate: startDate, endDate: endDate))
            }
        }
    }
}
