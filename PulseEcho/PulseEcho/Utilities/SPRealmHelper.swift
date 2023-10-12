//
//  SPRealmHelper.swift
//  PulseEcho
//
//  Created by Joseph on 2020-06-01.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import RealmSwift
import KeychainSwift
import CommonCrypto

/// Realm persistent store class
let realmQueue = DispatchQueue(label: "SPRealmHelper")
class RealmError: Error {
    init() {}
}
class SPRealmHelper {
    var device_id: String = ""
    init() { }

    
    static func saveObject<T: Object>(from dict: [String:Any], primaryKey: String, callbackQueue: DispatchQueue = .main, onCompletion: @escaping (Result<T, Error>) -> Void) {
        realmQueue.async {
            do {
                let realm = try Realm(configuration: getRealmForUser(username: primaryKey))
                if realm.isInWriteTransaction {
                    realm.create(T.self, value: dict)
                } else {
                    realm.beginWrite()
                    realm.create(T.self, value: dict, update: .modified)
                    try realm.commitWrite()
                }
                callbackQueue.async {
                    guard let realm = try? Realm(), let object = realm.object(ofType: T.self, forPrimaryKey: primaryKey) else {
                        onCompletion(.failure(RealmError()))
                        return
                    }
                    onCompletion(.success(object))
                }
            }
            catch {
                callbackQueue.async {
                    onCompletion(.failure(error))
                }
            }
        }
    }
    
    static func update<T: Object>(_ user: String, _ object: T, operation: @escaping (T) -> Void) -> T {
        let group = DispatchGroup()
        let threadSafeReference = ThreadSafeReference(to: object)
        group.enter()
        var result: ThreadSafeReference<T>!
        realmQueue.async {
            let realm = try! Realm(configuration: getRealmForUser(username: user))
            let object = realm.resolve(threadSafeReference)!
            if realm.isInWriteTransaction {
                operation(object)
            } else {
                realm.beginWrite()
                operation(object)
                try! realm.commitWrite()
            }
            result = ThreadSafeReference(to: object)
            group.leave()
        }
        group.wait()
        return try! Realm().resolve(result)!
    }
    
    func updateUser(_ object: Any, _ user: String) -> Bool {

        var success: Bool = false
        if object is User {
            let _user = object as! User
            let realm = try! Realm(configuration: getRealmForUser(username: user))

            let users = realm.objects(User.self).filter("Email == %@", user)

            if let userObj = users.first {
                try! realm.write {
                    userObj.AcknowledgedWaiver = _user.AcknowledgedWaiver
                    userObj.DepartmentID = _user.DepartmentID
                    userObj.Firstname = _user.Firstname
                    userObj.Gender = _user.Gender
                    userObj.JobDescription = _user.JobDescription
                    userObj.Language = _user.Language
                    userObj.Lastname = _user.Lastname
                    userObj.YearOfBirth = _user.YearOfBirth
                    userObj.LogoutWhenNotDetected = _user.LogoutWhenNotDetected
                    userObj.LifeStyle = _user.LifeStyle
                    userObj.Height = _user.Height
                    userObj.Weight = _user.Weight
                    userObj.HeartsTotal = _user.HeartsTotal
                    userObj.HeartsToday = _user.HeartsToday
                    userObj.BMI = _user.BMI
                    userObj.BMR = _user.BMR
                    userObj.AvgHoursFillHeart = _user.AvgHoursFillHeart
                    userObj.AcknowledgedWaiver = _user.AcknowledgedWaiver
                    userObj.WatchedSafetyVideo = _user.WatchedSafetyVideo
                    userObj.StepType = _user.StepType
                    userObj.TaskBarNotification = _user.TaskBarNotification
                    userObj.AutoLogin = _user.AutoLogin
                    userObj.AcknowledgedWaiverDate = _user.AcknowledgedWaiverDate
                    userObj.IsImperial = _user.IsImperial
                    
                    realm.add(userObj, update: .modified)
                    realm.refresh()

                    success = true
                }

            }
        }

        return success
    }
    
    func updateUserObjectWithParams(_ user :String,
                                    _ data: [String: Any],
                                    _ completion: @escaping (_ Data: User) -> Void) {
    
        
        let realm = try! Realm(configuration: getRealmForUser(username: user))
        
        try! realm.write {
            realm.create(User.self, value: data, update: .modified)
            realm.refresh()
         }
    }
    
    func userExists(_ user: String) -> Bool {
        //let realm = try! Realm(configuration: getRealmForUser(username: user))
        //return (realm.object(ofType: User.self, forPrimaryKey: user) != nil) ? true : false
        
        
        guard let realm = Realm.safeInit(email: user) else {
            // Track Error
            return false
        }
        let state = realm.objects(User.self).filter("Email = %@", user)

         guard state.count > 0 else {
             return false
         }
        realm.refresh()
        return true
    }
    
    
    func getUser(_ user: String) -> User {
        autoreleasepool {
            let realm = try! Realm(configuration: getRealmForUser(username: user))
            let users = realm.objects(User.self)
            
            guard users.count > 0 else {
                return User()
            }
            
            return users[0]
        }

    }
    
    // Profile Settings
    func saveProfileSettings(_ object: Any, _ user: String) -> Bool {
        var success: Bool = false
        
        if object is ProfileSettings {
          let _profile = object as! ProfileSettings
          let realm = try! Realm(configuration: getRealmForUser(username: user))
          
            //check if profile exist
           if self.profileExists(user) {
                return self.updateProfileSettings(_profile, user)
           } else {
            
            if !_profile.Email.isEmpty {
                try! realm.write() {
                   realm.add(_profile)
                   realm.refresh()
                   success = true
                }
            }
           }
           
        }
        
        return success
    }
    
    func updateProfileSettings(_ object: Any, _ user: String) -> Bool {
        var success: Bool = false
        if object is ProfileSettings {
            let _profile = object as! ProfileSettings
            let realm = try! Realm(configuration: getRealmForUser(username: user))
            
            let newProfile = _profile.createNewProfileObject()
            
            try! realm.write {
               realm.add(newProfile, update: .modified)
               realm.refresh()
               success  = true
             }
        }
        
        return success
        
    }
    
    func updateUserProfileSettings(_ object: [String: Any], _ user: String) -> ProfileSettings {
            var _profileSettings: ProfileSettings?
            let realm = try! Realm(configuration: getRealmForUser(username: user))
            let profileSettings = realm.objects(ProfileSettings.self).filter("Email == %@", user)

            if let profileObj = profileSettings.first {
                do {
                    try realm.write {
                        
                        if let _profileId = object["ProfileID"] as? Int{
                            profileObj.ProfileID  = _profileId
                        }
                        
                        if let _serial = object["SerialNumber"] as? String {
                            profileObj.SerialNumber = _serial
                        }
                        
                        if let _standTime1 = object["StandingTime1"] as? Int {
                            profileObj.StandingTime1 = _standTime1
                        }
                        
                        if let _standTime2 = object["StandingTime2"] as? Int {
                            profileObj.StandingTime2 = _standTime2
                        }
                        
                        if let _profile = object["ProfileSettingType"] as? Int {
                            profileObj.ProfileSettingType = _profile
                        }
                       
                        if let _sitPosition = object["SittingPosition"] as? Int {
                            profileObj.SittingPosition = _sitPosition
                        }
                        
                        if let _standPosition = object["StandingPosition"] as? Int {
                            profileObj.StandingPosition = _standPosition
                        }
                        
                        if let _isInteractive = object["IsInteractive"] as? Bool {
                            profileObj.IsInteractive = _isInteractive
                        }
                        
                        realm.add(profileObj, update: .modified)
                        realm.refresh()
                        
                        _profileSettings = profileObj
                    }
                } catch {
                    print("updateUserProfileSettings exception")
                }

            
        }

        return _profileSettings ?? ProfileSettings()
        
    }
    
    func getProfileSettings(_ user: String) -> ProfileSettings {
        autoreleasepool {
            let realm = try! Realm(configuration: getRealmForUser(username: user))
            let users =  realm.objects(ProfileSettings.self).filter("Email == %@", user)
        
            guard users.count > 0 else {
                return ProfileSettings()
            }
        
            return users[0]
        }
    }
    
    func profileExists(_ user: String) -> Bool {
//        let realm = try! Realm(configuration: getRealmForUser(username: user))
//        let object = realm.objects(ProfileSettings.self).filter("Email = %@", user).count
//        return object > 0 ? true : false
        
        guard let realm = Realm.safeInit(email: user) else {
            // Track Error
            return false
        }
        let state = realm.objects(ProfileSettings.self).filter("Email = %@", user)

         guard state.count > 0 else {
             return false
         }
        realm.refresh()
        return true
    }
    
    //App states
    
    func saveAppStates(_ object: Any, device: String, email: String){
        
        uuid { (deviceId) in
            self.device_id = deviceId
            
            autoreleasepool {
                let realm = try! Realm(configuration: getRealmForUser(username: email))
                
                if object is UserAppStates {
                   let _state = object as! UserAppStates
                   
                    guard _state.Email.isEmpty == false else {
                        return
                    }
                    
                    //check if user exist
                    if self.serialExists(deviceId, _state.SerialNumber, email) {
                        self.updateAppState(_state, email: email)
                    } else {
                        try! realm.write() {
                           realm.add(_state)
                        }
                    }
                }
            }
            
        }
    }
    
    func appStateExists(_ user: String) -> Bool {
//        let realm = try! Realm(configuration: getRealmForUser(username: user))
//        let object = realm.object(ofType: UserAppStates.self, forPrimaryKey: user)
//        return object != nil
        
        guard let realm = Realm.safeInit(email: user) else {
            // Track Error
            return false
        }
        let state = realm.objects(UserAppStates.self).filter("Email = %@", user)

         guard state.count > 0 else {
             return false
         }
        realm.refresh()
        return true
        
        
    }
    
    func updateAppState(_ object: Any, email: String) {
        autoreleasepool {
            if object is UserAppStates {
             let _appstate = object as! UserAppStates
            
                do {
                   
                   let realm = try! Realm(configuration: getRealmForUser(username: email))
                   try! realm.write {
                      realm.add(_appstate, update: .modified)
                      realm.refresh()
                    }
                    
                } catch let error as NSError {
                   print("updateAppState error: ", error)
                }
            }
        }
    }
    
    func updateUserAppState(_ data: UserAppStates, _ email: String) {
        autoreleasepool {
            do {
               
               let realm = try! Realm(configuration: getRealmForUser(username: email))
               try! realm.write {
                    realm.add(data, update: .modified)
                    realm.refresh()
                }
                
            } catch let error as NSError {
               print("updateAppState error: ", error)
            }
        }
    }
    
    func updateUserAppStateWithParams(_ object: [String: Any], _ user: String) {
            let realm = try! Realm(configuration: getRealmForUser(username: user))
            let appState = realm.objects(UserAppStates.self).filter("Email == %@", user)
        
            if let appStateObj = appState.first {
                do {
                    try realm.write {
                        
                        if let _deviceID = object["DeviceId"] as? String{
                            appStateObj.DeviceId  = _deviceID
                        }
                        
                        if let _serial = object["SerialNumber"] as? String {
                            appStateObj.SerialNumber = _serial
                        }
                        
                        if let _userID = object["UserId"] as? Int {
                            appStateObj.UserId = _userID
                        }
                        
                        if let _userVM = object["UserVM"] as? String {
                            appStateObj.UserVM = _userVM
                        }
                        
                        if let _userDeskMode = object["UserDeskMode"] as? String {
                            appStateObj.UserDeskMode = _userDeskMode
                        }
                       
                        if let _interactivePopUp = object["InteractivePopUpShowed"] as? Bool {
                            appStateObj.InteractivePopUpShowed = _interactivePopUp
                        }
                        
                        if let _safetyPopUp = object["SafetyPopUpShowed"] as? Bool {
                            appStateObj.SafetyPopUpShowed = _safetyPopUp
                        }
                        
                        if let _bleuuid = object["BLEUUID"] as? String {
                            appStateObj.BLEUUID = _bleuuid
                        }
                        
                        if let _orgCode = object["OrgCode"] as? String {
                            appStateObj.OrgCode = _orgCode
                            appStateObj.HasOrgCode = _orgCode.isEmpty ? false : true
                        }
                        
                        if let _sessionExpiry = object["SessionExpiryDated"] as? String {
                            appStateObj.SessionExpiryDated = _sessionExpiry
                        }
                        
                        if let _sessionDated = object["SessionDated"] as? String {
                            appStateObj.SessionDated = _sessionDated
                        }
                        
                        if let _sesssionKey = object["SessionKey"] as? String {
                            appStateObj.SessionKey = _sesssionKey
                        }
                        
                        if let _renewalKey = object["RenewalKey"] as? String {
                            appStateObj.RenewalKey = _renewalKey
                        }
                        
                        if let _datePurge = object["DateDataBeenPurge"] as? Int64 {
                            appStateObj.DateDataBeenPurge = _datePurge
                        }
                        
                        if let _localDateExpiry = object["LocalDataExpiry"] as? Int64 {
                            appStateObj.LocalDataExpiry = _localDateExpiry
                        }
                        
                        realm.add(appStateObj, update: .modified)
                        realm.refresh()
                        
                    }
                } catch {
                    print("updateUserAppStateWithParams exception")
                }

            
        }
    }

    func serialExists(_ deviceId: String, _ serial: String, _ email: String) -> Bool {
        autoreleasepool {
            let realm = try! Realm(configuration: getRealmForUser(username: email))
            let _serialCount = realm.objects(UserAppStates.self).filter("Email = %@", email).count
            return _serialCount > 0 ? true : false
        }
    }

    func getAppState(_ email: String) -> UserAppStates {
        guard let realm = Realm.safeInit(email: email) else {
            // Track Error
            return UserAppStates()
        }
        let state = realm.objects(UserAppStates.self).filter("Email = %@", email)

         guard state.count > 0 else {
             return UserAppStates()
         }
        realm.refresh()
        return state[0]
    }
    
    // User location
    
    func saveFacilityLocation(_ object: Any, _ user: String) -> Bool {
        autoreleasepool {
            let realm = try! Realm(configuration: getRealmForUser(username: user))
            var success: Bool = false
            if object is GeoLocator {
               let _location = object as! GeoLocator
                try! realm.write() {
                   realm.add(_location)
                   success = true
                }
            }
            return success
        }
    }
    
    func locationExist(_ location: Location, _ email: String) -> Bool {
        autoreleasepool {
            let realm = try! Realm(configuration: getRealmForUser(username: email))
            let _locationCount = realm.objects(GeoLocator.self).filter("facilityLocation = %@", location).count
            return _locationCount > 0 ? true : false
        }
    }
    
    func getAllFacilityLocation(_ email: String) -> [GeoLocator] {
        
        autoreleasepool {
            let realm = try! Realm(configuration: getRealmForUser(username: email))
            let _result = realm.objects(GeoLocator.self)
            
            var locations = [GeoLocator]()
            for item in _result {
                locations.append(item)
            }
            
            return locations
        }
        
    }
    
    //Pulse Boxes
    
    func pulseDeviceExists(_ email: String) -> Bool {
        autoreleasepool {
            let realm = try! Realm(configuration: getRealmForUser(username: email))
            let _devicesCount = realm.objects(PulseDevices.self).filter("Email = %@", email).count
            return _devicesCount > 0 ? true : false
        }
    }
    
    func getPulseDevice(_ email: String)  throws -> PulseDevices {
        guard let realm = Realm.safeInit(email: email) else {
            return PulseDevices()
        }
        let state = realm.objects(PulseDevices.self).filter("Email = %@", email)

         guard state.count > 0 else {
             return PulseDevices()
         }
        realm.refresh()
        return state[0]
    }
    
    func savePulseObject(_ object: Any, _ user: String) -> Bool {
        autoreleasepool {
            let realm = try! Realm(configuration: getRealmForUser(username: user))
            var success: Bool = false
            if object is PulseDevices {
               let bleData = object as! PulseDevices
                try! realm.write() {
                   realm.add(bleData)
                   success = true
                }
            }
            return success
        }
    }
    
    func updatePulseObject(_ object: [String: Any], _ user: String) -> Bool {
        //allow to add new pulse device by serial
        var success: Bool = false
            let realm = try! Realm(configuration: getRealmForUser(username: user))
            let devices = realm.objects(PulseDevices.self).filter("Email == %@", user)

            if let deviceObj = devices.first {
                do {
                    try realm.write {
                        
                        if let _identifier = object["Identifier"] as? String{
                            deviceObj.Identifier  = _identifier
                        }
                        
                        if let _serial = object["Serial"] as? String {
                            deviceObj.Serial = _serial
                        }
                        
                        if let _name = object["PeripheralName"] as? String {
                            deviceObj.PeripheralName = _name
                        }
                        
                        if let _profile = object["UserProfile"] as? String {
                            deviceObj.UserProfile = _profile
                        }
                       
                        if let _userDisconnect = object["DisconnectedByUser"] as? Bool {
                            deviceObj.DisconnectedByUser = _userDisconnect
                        }
                        
                        if let _state = object["State"] as? Int {
                            deviceObj.State = _state
                        }
                        
                        realm.add(deviceObj, update: .modified)
                        realm.refresh()
                        
                        success = true
                    }
                } catch {
                    print("updatePulseDeviceObject exception")
                }

            
        }

        return success
    }
    
    func retrievePulseObject(_ user :String,
                             _ completion: @escaping (_ Data: PulseDevices,
                                                      _ isContain :Bool) -> Void){
        autoreleasepool {
            let realm = try! Realm()
            let data = realm.object(ofType: PulseDevices.self, forPrimaryKey: user)
            
            if data != nil{
                completion((data ?? PulseDevices()), true)
            }else{
                completion(PulseDevices(), false)
            }
        }
        
    }
    
    func getDeviceConnectedIdentifier(_ email: String) -> String {
//        autoreleasepool {
//             let realm = try! Realm(configuration: getRealmForUser(username: email))
//             let state = realm.objects(PulseDevices.self).filter("Email = %@", email)
//
//             guard state.count > 0 else {
//                return ""
//             }
//
//            return state[0].Identifier
//        }
        
        guard let realm = Realm.safeInit(email: email) else {
            // Track Error
            return ""
        }
        let state = realm.objects(PulseDevices.self).filter("Email = %@", email)

         guard state.count > 0 else {
             return ""
         }
        realm.refresh()
        return state[0].Identifier
        
    }
    
    func getDeviceintentionallyDisconnect() -> Bool {
        autoreleasepool {
             let email = Utilities.instance.getLoggedEmail()
             let realm = try! Realm(configuration: getRealmForUser(username: email))
             let state = realm.objects(PulseDevices.self).filter("Email = %@", email)
             
             guard state.count > 0 else {
                return false
             }
             
            return state[0].DisconnectedByUser
        }
    }
    
    /**
     Profile Settings
        
     */
    
    func retrieveSavedProfile(_ user :String,
                              _ completion: @escaping (_ Data: ProfileSettings,
                                                       _ isContain :Bool) -> Void){
        autoreleasepool {
            let realm = try! Realm()
            let data = realm.object(ofType: ProfileSettings.self, forPrimaryKey: user)
            
            if data != nil{
                completion((data ?? ProfileSettings()), true)
            }else{
                completion(ProfileSettings(), false)
            }
        }
        
    }
    
    /**
        PulseData Push
     */
    
    func retrievePulseDataPush(_ user :String,
                               _ serial: String,
                               _ completion: @escaping (_ Data: PulseDataPush,
                                                      _ isContain :Bool) -> Void){
        
        guard let realm = Realm.safeInit(email: user) else {
            return
        }
        let data = realm.objects(PulseDataPush.self).filter("Serial = %@", serial)

        if let deviceObj = data.first {
            completion(deviceObj, true)
        } else {
            completion(PulseDataPush(), false)
        }
                
    }
    
    func credentialsExist(email: String, serial: String) -> Bool {
        autoreleasepool {
            let realm = try! Realm(configuration: getRealmForUser(username: email))
            let _credentialsCount = realm.objects(PulseDataPush.self).filter("Serial = %@", serial).count
            return _credentialsCount > 0 ? true : false
        }
    }
    
    func savePushCredentials(_ user: String, _ serial: String, _ hearts: PulseDataPush) -> Bool{
        autoreleasepool {
            let realm = try! Realm(configuration: getRealmForUser(username: user))
            var success: Bool = false
            try! realm.write() {
               realm.add(hearts)
               success = true
            }
            return success
        }
    }
    
    func updatePushCredentials(_ object: [String: Any], _ user: String, _ serial: String) -> Bool {
        var success: Bool = false
            let realm = try! Realm(configuration: getRealmForUser(username: user))
            let devices = realm.objects(PulseDataPush.self).filter("Serial == %@", serial)
        
            if let deviceObj = devices.first {
                do {
                    try realm.write {
                        
                        if let _serial = object["Serial"] as? String {
                            deviceObj.Serial = _serial
                        }
                        
                        if let _email = object["Email"] as? String {
                            deviceObj.Email = _email
                        }
                        
                        if let _aes = object["AESKey"] as? String {
                            deviceObj.AESKey = _aes
                        }
                       
                        if let _aesiv = object["AESIV"] as? String {
                            deviceObj.AESIV = _aesiv
                        }
                        
                        realm.add(deviceObj, update: .modified)
                        realm.refresh()
                        
                        success = true
                    }
                } catch {
                    print("updatePushCredentials exception")
                }
        }

        return success
    }
    
    /**
     Desk Activity
     */
    
    func saveDeskActivity(_ user: String, _ hearts: DeskActivity) -> Bool{
        autoreleasepool {
            let realm = try! Realm(configuration: getRealmForUser(username: user))
            var success: Bool = false
            try! realm.write() {
               realm.add(hearts)
               success = true
            }
            return success
        }
    }
    
}

func uuid(completionHandler: @escaping (String) -> ()) {
    if let uuid = UIDevice.current.identifierForVendor?.uuidString {
        completionHandler(uuid)
    }
    else {
        // If the value is nil, wait and get the value again later. This happens, for example, after the device has been restarted but before the user has unlocked the device.
        // https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor?language=objc
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            uuid(completionHandler: completionHandler)
        }
    }
}

extension Realm {
    static func safeInit(email: String) -> Realm? {
        do {
            let realm = try Realm(configuration: getRealmForUser(username: email))
            return realm
        }
        catch {
            print("REALM STORAGE INITIALIZATION ERROR")
        }
        return nil
    }

    func safeWrite(_ block: () -> ()) {
        do {
            // Async safety, to prevent "Realm already in a write transaction" Exceptions
            if !isInWriteTransaction {
                try write(block)
            }
        } catch {
            print("REALM STORAGE WRITE ERROR")
            
        }
    }
}
