//
//  AppDatabase.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-13.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import GRDB
import Foundation

/// A type responsible for initializing the application database.
///
/// See AppDelegate.setupDatabase()
struct AppDatabase {
    
    /// Creates a fully initialized database at path
    static func openDatabase(atPath path: String, migrate: Bool) throws -> DatabaseQueue {
        // Connect to the database
        let dbQueue = try DatabaseQueue(path: path)
        print("dbQueue check: ",dbQueue.path)
        return dbQueue
    }
    
    static func checkApplicationTables() {
        do {
            let users = try checkDatabaseTable(name: Constants.users_table)
            let profile_settings = try checkDatabaseTable(name: Constants.settings_table)
            let app_states = try checkDatabaseTable(name: Constants.user_app_states)
            
            print("user table exist: ", users)
            print("user settings exist: ", users)
            print("app_states exist: ", app_states)
            
            if !users {
                try createUsersTable(name: Constants.users_table)
            } else {
                try alterUserTable(name: Constants.users_table)
            }
            
            if !profile_settings {
                try createSettingsTable()
            }
            
            if !app_states {
                try createUserAppStates()
            }
            
        } catch {
           print("Application table creation error.")
        }
    }
    
    static func checkDatabaseTable(name: String) throws -> Bool {
        var check = false
        try dbQueue?.read{ db in
            check =  try db.tableExists(name)
        }
        return check
    }
    
    static func createUsersTable(name: String) throws {
        try dbQueue?.write { db in
            try db.create(table: name) { t in
                t.autoIncrementedPrimaryKey("id")
                  t.column("DepartmentID", .integer)
                  t.column("Email", .text)
                  t.column("Firstname", .text)
                  t.column("Lastname", .text)
                  t.column("YearOfBirth", .integer)
                  t.column("Gender", .integer)
                  t.column("Language", .integer)
                  t.column("AcknowledgedWaiver", .boolean)
                  t.column("WatchedSafetyVideo", .boolean)
                  t.column("StepType", .integer)
                  t.column("LifeStyle", .integer)
                  t.column("JobDescription", .integer)
                  t.column("LogoutWhenNotDetected", .integer)
                  t.column("Height", .integer)
                  t.column("Weight", .double)
                  t.column("BMI", .double)
                  t.column("HeartsToday", .double)
                  t.column("HeartsTotal", .double)
                  t.column("BMR", .double)
                  t.column("AvgHoursFillHeart", .double)
            }
        }
    }
    
    static func alterUserTable(name: String) throws {
        let tblName = "New_" + name
        var _new_user = try self.createUsersTable(name: tblName)
        
//        try dbQueue?.write { db in
//            let query = String(format: "INSERT INTO %@ SELECT * FROM %@", tblName, name)
//            let _users = try User.fetchAll(db)
//
//            try db.drop(table: name)
//            try db.rename(table: tblName, to: name)
//
//
////            for obj in _users {
////                let _userQuery = String(format:"INSERT INTO %@")
////            }
//
//        }
    }
    
    static func createSettingsTable() throws {
        try dbQueue?.write { db in
            try db.create(table: Constants.settings_table) { t in
                t.autoIncrementedPrimaryKey("id")
                  t.column("UserId", .integer)
                  t.column("SerialNumber", .text)
                  t.column("Email", .text)
                  t.column("Lastname", .text)
                  t.column("StandingTime1", .integer)
                  t.column("StandingTime2", .integer)
                  t.column("ProfileSettingType", .integer)
                  t.column("SittingPosition", .integer)
                  t.column("StandingPosition", .integer)
                  t.column("JobDescription", .integer)
                  t.column("IsInteractive", .boolean)
            }
        }
    }
    
    static func getUserCount(user: User) throws -> Int {
        var _count = 0
//        _ = try dbQueue?.write{ db -> Int? in
//            let count = try User
//                .filter(sql:"Email = ?", arguments: [user.Email])
//                .fetchCount(db)
//            print("count :",count)
//            _count = count
//            return _count
//        }
//
        return _count
    }
    
    static func getProfileSettingsCount(settings: ProfileSettings) throws -> Int {
        var _count = 0
//        _ = try dbQueue?.write{ db -> Int? in
//            let count = try ProfileSettings
//                .filter(sql:"Email = ?", arguments: [settings.Email])
//                .fetchCount(db)
//            print("count :",count)
//            _count = count
//            return _count
//        }
        
        return _count
    }
    
    static func getProfileSettingsCount(email: String) throws -> Int {
        var _count = 0
//        _ = try dbQueue?.write{ db -> Int? in
//            let count = try ProfileSettings
//                .filter(sql:"Email = ?", arguments: [email])
//                .fetchCount(db)
//            print("getProfileSettingsCount :",count)
//            _count = count
//            return _count
//        }
        
        return _count
    }
    
    static func getUser(email: String) throws -> User {
        var object = User(params: [String : Any]())
//        _ = try dbQueue?.write { db -> User in
//            let _user = try User.fetchOne(db, sql: "SELECT * FROM User WHERE Email = ?", arguments: [email])
//            //return _user
//            object = _user ?? object
//            return object
//        }
        return object
    }
    
    static func getProfileSettings(email: String) throws -> ProfileSettings {
        
        var object = ProfileSettings(params: [String : Any]())
//        _ = try dbQueue?.write { db -> ProfileSettings in
//        let _settings = try ProfileSettings.fetchOne(db, sql: "SELECT * FROM ProfileSettings WHERE Email = ?", arguments: [email])
//            object = _settings ?? object
//            return object
//        }
        return object
        
    }
    
    static func insertUser(user: User) throws {
        try dbQueue?.write{ db in
            var _user = user
            //try _user.insert(db)
        }
    }
    
    static func insertProfileSettings(settings: ProfileSettings) throws {
        try dbQueue?.write{ db in
            //var _settings = settings
            //try _settings.insert(db)
        }
    }
    
    static func updateUser(user: User) throws {
        do {
            _ = try dbQueue.write { db  in
                
//                let row = try Row.fetchOne(db, sql: "SELECT * FROM User WHERE Email = ?", arguments: [user.Email])
//                var _user = try User.fetchOne(db, sql: "SELECT * FROM User WHERE Email = ?", arguments: [user.Email])
//                _user?.AcknowledgedWaiver = user.AcknowledgedWaiver
//                _user?.DepartmentID = user.DepartmentID
//                _user?.Firstname = user.Firstname
//                _user?.Gender = user.Gender
//                _user?.JobDescription = user.JobDescription
//                _user?.Language = user.Language
//                _user?.Lastname = user.Lastname
//                _user?.YearOfBirth = user.YearOfBirth
//                _user?.LogoutWhenNotDetected = user.LogoutWhenNotDetected
//                _user?.LifeStyle = user.LifeStyle
//                _user?.Height = user.Height
//                _user?.Weight = user.Weight
//                _user?.HeartsTotal = user.HeartsTotal
//                _user?.HeartsToday = user.HeartsToday
//                _user?.BMI = user.BMI
//
////                if row?["BMR"] ?? false {
////                    _user?.BMR = user.BMR
////                }
//                _user?.BMR = user.BMR
//                _user?.AvgHoursFillHeart = user.AvgHoursFillHeart
//                _user?.AcknowledgedWaiver = user.AcknowledgedWaiver
//                _user?.WatchedSafetyVideo = user.WatchedSafetyVideo
//                _user?.StepType = user.StepType
//            try _user?.update(db)
           }
        } catch {
            print("Update user failed")
        }
    }
    
    static func updateProfileSettings(settings: ProfileSettings) throws {
        do {
//            _ = try dbQueue.write { db  in
//                var _settings = try ProfileSettings.fetchOne(db, sql: "SELECT * FROM ProfileSettings WHERE Email = ?", arguments: [settings.Email])
//                _settings?.SerialNumber = settings.SerialNumber
//                _settings?.Email = settings.Email
//                _settings?.StandingTime1 = settings.StandingTime1
//                _settings?.StandingTime2 = settings.StandingTime2
//                _settings?.ProfileSettingType = settings.ProfileSettingType
//                _settings?.SittingPosition = settings.SittingPosition
//                _settings?.StandingPosition = settings.StandingPosition
//                _settings?.IsInteractive = settings.IsInteractive
//            try _settings?.update(db)
//           }
        } catch {
            print("Update user failed")
        }
    }
    
    // User App Settings
    
    static func createUserAppStates() throws {
        try dbQueue?.write { db in
            try db.create(table: Constants.user_app_states) { t in
                t.autoIncrementedPrimaryKey("id")
                  t.column("UserId", .integer)
                  t.column("Email", .text)
                  t.column("InteractivePopUpShowed", .boolean)
                  t.column("SafetyPopUpShowed", .boolean)
                  t.column("UserVM", .text)
                  t.column("UserDeskMode", .text)
                  t.column("BLEUUID",.text)
            }
        }
    }
    
    static func getUserAppStates(email: String) throws -> UserAppStates {
        var object = UserAppStates(params: ["":""])
        _ = try dbQueue?.write { db -> UserAppStates in
            let _state = try UserAppStates.fetchOne(db, sql: "SELECT * FROM UserAppStates WHERE Email = ?", arguments: [email])
            //return _user
            object = _state ?? object
            return object
        }
        return object
    }
    
    static func insertAppState(state: UserAppStates) throws {
        try dbQueue?.write{ db in
            var _state = state
            try _state.insert(db)
        }
    }
    
    static func updateUserAppStateVM(vm: String, email: String) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: "UPDATE UserAppStates SET UserVM = :vm WHERE email = :email",
                arguments: ["vm": vm, "email": email])
            }
    }
    
    static func updateUserAppStateDeskMode(mode: String, email: String) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: "UPDATE UserAppStates SET UserDeskMode = :vm WHERE email = :email",
                arguments: ["mode": mode, "email": email])
            }
    }
    
    static func updateUserAppStateBLEUUID(uuid: String, email: String) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: "UPDATE UserAppStates SET BLEUUID = :uuid WHERE email = :email",
                arguments: ["uuid": uuid, "email": email])
            }
    }
    
    static func checkIfUserAppStateExist(email: String) throws -> Bool {
        var _exist = false
        _ = try dbQueue?.write{ db -> Bool? in
            let count = try UserAppStates
                .filter(sql:"Email = ?", arguments: [email])
                .fetchCount(db)
            print("count :",count)
            _exist = (count > 0) ? true : false
            return _exist
        }
        
        return _exist
    }
    
}
