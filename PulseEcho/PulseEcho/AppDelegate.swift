//
//  AppDelegate.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-03.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import CoreData
import Localize
import IQKeyboardManagerSwift
import KeychainSwift
import CommonCrypto
import CoreLocation
import UserNotifications
import CoreBluetooth
import RealmSwift
import Firebase

let baseController = BaseController.init()


@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
     var window : UIWindow?
    
    
    var localNotificationCenter: UNUserNotificationCenter?
    var locationManager: LocationService?
    var appLaunchOptions:  [UIApplication.LaunchOptionsKey : Any]?
    let dataTimer = SPTimeScheduler(timeInterval: 10)
    
    lazy var realm:Realm = {
        return try! Realm()
    }()
    
     func application(_ application: UIApplication,
         didFinishLaunchingWithOptions
         launchOptions: [UIApplication.LaunchOptionsKey : Any]?)
         -> Bool {
            FirebaseApp.configure()
            appLaunchOptions = launchOptions
            IQKeyboardManager.shared.enable = true
            IQKeyboardManager.shared.enableAutoToolbar = true
        
            let email = Utilities.instance.getLoggedEmail()
            if  !email.isEmpty  {
                realmMigrateLocalStorage(username: email)
                setAppEntry()
            } else {
                setAppEntry()
            }
        
           
            
            setLocalization()
            
            //UILabel.appearance().defaultFont = UIFont.systemFont(ofSize: 12)
            UITabBar.appearance().shadowImage = UIImage()
            UITabBar.appearance().backgroundImage = UIImage()
        
            //KEYCHAIN CHECK
        
            setUpApplicationKeychain()
        
            /*
         
         let schedule = Utilities.instance.getStringFromUserDefaults(key: "localScheduleSet")
         let options: UNAuthorizationOptions = [.badge, .sound, .alert]
         localNotificationCenter.requestAuthorization(options: options) { success, error in
            if let error = error {
              print("Error: \(error)")
            }
            
            if success {
             
//                guard schedule.isEmpty == false else {
//                    return
//                }
             self.scheduleLocalNotification()
            }
         }
         
         UNUserNotificationCenter.current().delegate = self
         locationManager.locationDelegate = self
         
         

         
         if let notification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            //notificationReceived(notification)
             print("app terminated: ", notification);
             let alertTest = UIAlertController(title: "Title", message: notification.description, preferredStyle: .alert)
             self.window?.rootViewController?.present(alertTest, animated: true, completion: nil)
         }
         
         **/
        dataTimer.eventHandler = {
            if LOGS.BUILDTYPE.boolValue == false {
                print("data timer Scheduler Fired | info: \(Utilities.instance.loginfo())")
            } else {
                print("data timer Scheduler Fired | info: \(Utilities.instance.loginfo())")
            }
            
            if let peripheral = SPBluetoothManager.shared.state.peripheral {
                
                guard peripheral.spDesiredService != nil else {
                    self.dataTimer.suspend()
                    return
                }
                
               print("peripheral.spDesiredService : ", peripheral.spDesiredService)
                let command = SPRequestParameters.All
                do {
                    try SPBluetoothManager.shared.sendCommand(command: command)
                    self.dataTimer.suspend()
                } catch let error as NSError {
                    print("eventHandler error sending  command: \(error.localizedDescription)")
                    SPBluetoothManager.shared.disconnect(forget: true)
                    self.dataTimer.suspend()
                } catch {
                    print("eventHandler Unable to send command")
                    SPBluetoothManager.shared.disconnect(forget: true)
                    self.dataTimer.suspend()
                }
            } else {
                self.dataTimer.suspend()
            }
        }
        
        Utilities.instance.setFirstAppLaunch()
        
        return true
     }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        //RESET BADGE FOR USER NOTIFICATION
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        //self.handleUserNotification(for: CLRegion())
        
        
        //DETECT JAILBROKEN DEVICES
        ExitOnJailbreak()
        
        // normal methods
        checkSurvey()
        
        scheduleLocalNotification()
        
        Threads.performTaskAfterDealy(2) {
            self.reconnectDeviceBLE()
        }
    }
    
    func reconnectDeviceBLE() {
        
        let email = Utilities.instance.getLoggedEmail()
        let dataHelper = SPRealmHelper()
        if  !email.isEmpty  {
            
            SPBluetoothManager.shared.heartbeatReconnectTimer()
            
            
            guard !(dataHelper.getDeviceConnectedIdentifier(email).isEmpty) else {
                //Utilities.instance.alertBlePairPopUp()
                print("getDeviceConnectedIdentifier | info: \(Utilities.instance.loginfo())")
                return
            }
            SPBluetoothManager.shared.pulseDeviceReconnectTimer()
            guard (SPRealmHelper().getDeviceintentionallyDisconnect() == false) else {
                print("reconnectDeviceBLE user should attempt to reconnect manually | info: \(Utilities.instance.loginfo())")
                return
            }
            
            SPBluetoothManager.shared.heartBeatSentCount = 0
            SPBluetoothManager.shared.desktopApphasPriority = false
            PulseDataState.instance.isDeskCurrentlyBooked = false
            if let peripheral = SPBluetoothManager.shared.state.peripheral {
                if peripheral.state == .connected {
                    SPBluetoothManager.shared.PulseHeartbeatReconnectTimer.resume()
                    print("reconnect peripheral: \(peripheral) | info: \(Utilities.instance.loginfo())")
                }
                
                guard (peripheral.identifier.uuidString == dataHelper.getDeviceConnectedIdentifier(email)) && (peripheral.state == .disconnected || peripheral.state == .disconnecting || peripheral.state == .connecting) else {


                    if peripheral.spDesiredCharacteristic != nil {
                        SPBluetoothManager.shared.getLatestProfile()
                        print("all good send the heartbeat | info: \(Utilities.instance.loginfo())")

                        SPBluetoothManager.shared.setConnected(peripheral: peripheral)
                        SPBluetoothManager.shared.heartBeatSentCount = 0
                        SPBluetoothManager.shared.PulseHeartbeatReconnectTimer.resume()
                        //SPBluetoothManager.shared.sendHeartBeat(peripheral, peripheral.spDesiredCharacteristic!)
                        repeat {
                            SPBluetoothManager.shared.sendHeartBeat(peripheral, peripheral.spDesiredCharacteristic!)
                            print("app delegate : \(SPBluetoothManager.shared.isConnected)")

                        } while (SPBluetoothManager.shared.heartBeatSentCount < SPBluetoothManager.shared.heartBeatSentLimit && SPBluetoothManager.shared.heartBeatSentCount != SPBluetoothManager.shared.heartBeatSentLimit)
                        SPBluetoothManager.shared.sendRequestAllData(peripheral, peripheral.spDesiredCharacteristic!)

                    } else {

                        SPBluetoothManager.shared.connect(peripheral: peripheral)

                    }

                    return
                }
                
                print("should attempt device reconnect when app is disconnected | info: \(Utilities.instance.loginfo())")
                
                if let peripheralIdStr = dataHelper.getDeviceConnectedIdentifier(email) as? String,
                    let peripheralId = UUID(uuidString: peripheralIdStr),
                    let previouslyConnected = SPBluetoothManager.shared.central
                        .retrievePeripherals(withIdentifiers: [peripheralId])
                        .first {
                    
                    SPBluetoothManager.shared.connect(peripheral: previouslyConnected)
                } else {
                    print("app connected and bonded | info: \(Utilities.instance.loginfo())")
                }
            } else {
                print("reconnect fail try to restore the connection with the save periphral ID | info: \(Utilities.instance.loginfo())")
                
                SPBluetoothManager.shared.PulseHeartbeatReconnectTimer.resume()
                
                if email.isEmpty == false,
                   let peripheralIdStr = dataHelper.getDeviceConnectedIdentifier(email) as? String,
                    let peripheralId = UUID(uuidString: peripheralIdStr),
                    let previouslyConnected = SPBluetoothManager.shared.central
                        .retrievePeripherals(withIdentifiers: [peripheralId])
                        .first {
                    
                    print("previouslyConnected.state: ", previouslyConnected.state.rawValue)
                    print("previouslyConnected identifier: ", peripheralIdStr)
                    print("previouslyConnected retrievePeripherals: ", previouslyConnected)

                    if previouslyConnected.state == .connected {
                        print("centralManagerDidUpdateState retrievePeripherals: \(previouslyConnected) | info: \(Utilities.instance.loginfo())")
                        
                        if let peripheral = SPBluetoothManager.shared.state.peripheral {
                            if peripheral.spDesiredCharacteristic != nil {
                                SPBluetoothManager.shared.sendHeartBeat(peripheral, peripheral.spDesiredCharacteristic!)
                                SPBluetoothManager.shared.sendRequestAllData(peripheral, peripheral.spDesiredCharacteristic!)
                            }
                        } else {
                            SPBluetoothManager.shared.connect(peripheral: previouslyConnected)
                        }
                    } else {
                        SPBluetoothManager.shared.connect(peripheral: previouslyConnected)
                    }
                }
            }
       }
    }
    
    func allowLocationService() {
        //LOCATION SERVICE
       //let locationManager = LocationService()
        /*locationManager.locationDelegate = self
       locationManager.startUpdatingHeading()*/
       //locationManager.requestAlwaysAuthorization()
        
       locationManager = LocationService()
                  
    }
    
    func allowLocalAndPushNotification() {
        localNotificationCenter = UNUserNotificationCenter.current()
        
        let schedule = Utilities.instance.getStringFromUserDefaults(key: "localScheduleSet")
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        localNotificationCenter?.requestAuthorization(options: options) { success, error in
           if let error = error {
            //log.debug("Error: \(error)")
           }
           
           if success {
            self.scheduleLocalNotification()
           }
        }
        
        UNUserNotificationCenter.current().delegate = self
        locationManager?.locationDelegate = self
        
        
        if let notification = appLaunchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
           //notificationReceived(notification)
            //log.debug("app terminated: \(notification)")
            let alertTest = UIAlertController(title: "Title", message: notification.description, preferredStyle: .alert)
            self.window?.rootViewController?.present(alertTest, animated: true, completion: nil)
        }
    }
    
    func scheduleLocalNotification() {

        localNotificationCenter?.getNotificationSettings { (settings) in
            if(settings.authorizationStatus == .authorized)
            {
                guard (Utilities.instance.typeOfUserLogged() != .None || Utilities.instance.typeOfUserLogged() != .Guest) else {
                    return
                }
                
                let now = Date()
                var components = Calendar.current.dateComponents([.month, .day, .year, .hour, .minute], from: now)
                components.setValue(08, for: Calendar.Component.hour)
                components.setValue(30, for: Calendar.Component.minute)
                //log.debug("components is: \(components)")
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: components.hour, minute: components.minute), repeats: true)
                 // print("local notification trigger date: ", trigger.nextTriggerDate() ?? "nil")

                 //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
                    
                  let content = UNMutableNotificationContent()
                  let title = "covid.title".localize()
                  let message = "covid.message".localize()
                  content.title = title
                  content.body = message

                  let uuidString = UUID().uuidString
                  // make sure you give each request a unique identifier. (nextTriggerDate description)
                  let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                self.localNotificationCenter?.add(request) { error in
                          if let error = error {
                              print(error)
                              return
                          }

                        //Utilities.instance.saveDefaultValueForKey(value: "true", key: "localScheduleSet")
                          print("scheduled")
                      }
            }
        }
        
    }
    
    /**
     Method to check available survey for the user with frequency every day. In the near future this should be handled via push notifications.
    - Parameter none
    - Returns: none.
    */
    
    func checkSurvey() {
        
        let email = Utilities.instance.getUserEmail()
        
        guard (Utilities.instance.typeOfUserLogged() != .None || Utilities.instance.typeOfUserLogged() != .Guest) else {
            return
        }
        
        guard Utilities.instance.isValidSessionToken() == true else {
            return
        }
               
               //Check if there is a pending survey get the last checked date of checking the service.
               
               let _date = Utilities.instance.getObjectFromUserDefaults(key: "survey_last_checked") as? String ?? ""

               //let email = Utilities.instance.getUserEmail()
               
               guard !email.isEmpty else {
                   return
               }
               
                guard !_date.isEmpty else {
                   
                   self.getSurvey { (response) in
                       
                       if response is Survey {
                           let _survey = response as! Survey
                           baseController.showSurvey(survey: _survey)
                       }
                       
                   }
                
//                let json = readJSONFromFile(fileName: "ASurvey")
//                let rawJson = json as? [String: Any] ?? [String: Any]()
//                let _object = rawJson["Survey"] as? [String: Any] ?? [String: Any]()
//                let _survey = Survey(params: _object)
//                baseController.showSurvey(survey: _survey)
                
                   return
               }
               
                let date_last_check = Utilities.instance.getDateFromString(date: _date)
                print("date_last_check != nil", date_last_check != nil)
        
                let today = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = DateFormatter.Style.none
                dateFormatter .dateStyle = DateFormatter.Style.short
                let dateAsString = dateFormatter.string(from: today)
                let currentDate =  dateFormatter.date(from: dateAsString)
               
               print("currentDate : ", currentDate)
               print("date_last_check : ", date_last_check)
               print("data compare:", currentDate?.isEqualTo(date_last_check ?? Date()))
               let date_compare = currentDate?.isGreaterThan(date_last_check )
        
                print("date compare check: ", date_compare)
                if date_compare ?? true {
                    Utilities.instance.saveDefaultValueForKey(value: false, key: "survery_popup_already_shown")
                   self.getSurvey { (response) in
                        if response is Survey {
                           let _survey = response as! Survey
                           baseController.showSurvey(survey: _survey)
                       }
                   }
               }
    }
    
    /**
     Request survey data from web service.
    - Parameter Closure completion
    - Returns: none.
    */
    
    func getSurvey(_ completion: @escaping (( _ response: Any) -> Void)) {
        let viewModel = SurveyViewModel()
        viewModel.requestAvailableSurvey { (object) in
            if object is Survey {
                let _survey = object as! Survey
                completion(_survey)
            } else {
                completion(object)
            }
        }
    }
    
    /**
     Local notification for detecting user via geofencing.
    - Parameter CLRegion region
    - Returns: none.
    */
    
    func handleUserNotification(for region: CLRegion!) {
        
      if UIApplication.shared.applicationState == .active {
        //Show COVID questions
         let title = "covid.title".localize()
         let message = "covid.message".localize()
        
        window?.rootViewController?.showAlert(title: title,
                                           message: message,
                                           positiveText: "common.yes".localize(),
                                           negativeText: "common.no".localize(),
                                           success: {
                                                self.showCovid19Assessment(nil)
                                           }) {
                                
                                         }

      } else {
        
        let title = "covid.title".localize()
        let message = "covid.message".localize()
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = message
          notificationContent.sound = UNNotificationSound.default
        notificationContent.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "location_change",
                                            content: notificationContent,
                                            trigger: trigger)
        /*localNotificationCenter.add(request) { error in
          if let error = error {
            print("Error: \(error)")
          }
        }*/
      }
    }
    
    /**
    Show Covid19 self assessment..
    - Parameter none
    - Returns: none.
    */
    
    func showCovid19Assessment(_ closure: COVID_QUESTIONS_DONE?) {
        
        guard (Utilities.instance.typeOfUserLogged() != .None || Utilities.instance.typeOfUserLogged() != .Guest) else {
            return
        }
        
        let json = readJSONFromFile(fileName: "covidQuestions")
        let rawJson = json as? [String: Any] ?? [String: Any]()
        let _object = rawJson["Survey"] as? [String: Any] ?? [String: Any]()
        let _covid19 = Survey(params: _object)
        
        let covid19Controller: CovidSurveyController = CovidSurveyController.instantiateFromStoryboard(storyboard: "Home") as! CovidSurveyController
        covid19Controller.assessment = _covid19
        self.window?.rootViewController?.present(covid19Controller, animated: true, completion: nil)
        
        covid19Controller.covidQuestionDone = { [weak self] () in
            if closure != nil {
                closure?()
            }
        }
    }

}

extension AppDelegate {
    
    /**
    Set application keychain value for encryption purposes.
    - Parameter none
    - Returns: none.
    */
    
    func setUpApplicationKeychain() {
        let keychain = KeychainSwift()
        let _list = keychain.allKeys
        guard !(_list.contains(Constants.app_key_access)) else {
            return
        }
        keychain.set(Constants.app_key, forKey: Constants.app_key_access)
    }
    
    /**
    Loads the main interface of the app.
    - Parameter none
    - Returns: none.
    */
    
    func setAppEntry() {
       
        
        guard Utilities.instance.typeOfUserLogged() != .None else {
            BaseController.loginController(false)
            return
        }
        
        if Utilities.instance.typeOfUserLogged() == .Guest {
            Utilities.instance.isGuest = true
            BaseController.mainController(nil)
            SPBluetoothManager.shared.startReceivingData = true
        } else {
            let email = Utilities.instance.getLoggedEmail()
            let state = SPRealmHelper().getAppState(email)
            
            if (state.OrgCode.isEmpty == true) {
                BaseController.loginController(false)
            } else {
                BaseController.mainController(nil)
                SPBluetoothManager.shared.startReceivingData = true
            }
            
            
        }
        
    }
    
    /**
    Initialize the localization of the app based on the language.
    - Parameter none
    - Returns: none.
    */
    
    func setLocalization() {
        let localize = Localize.shared
        // Set your localize provider.
        localize.update(provider: .json)
        // Set your file name
        localize.update(fileName: "lang")
        // Set your default languaje.
        localize.update(defaultLanguage: "en")
        // If you want change a user language, different to default in phone use thimethod.
       //localize.update(language: "en")
        // If you want remove storaged language use
        localize.resetLanguage()
        // The used language
        print(localize.currentLanguage)
        // List of aviable languajes
        print(localize.availableLanguages)
    }
    
    //SECURITY JAILBROKEN CHECK
    
    /**
    Check the device if its jailbroken.
    - Parameter none
    - Returns: Bool.
    */
    
    func isDeviceJailbroken() -> Bool {
       if TARGET_IPHONE_SIMULATOR != 1{
        // Check 1 : existence of files that are common for jailbroken devices
           if FileManager.default.fileExists(atPath: "/Applications/Cydia.app") ||
               FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") ||
               FileManager.default.fileExists(atPath: "/bin/bash") ||
               FileManager.default.fileExists(atPath: "/usr/sbin/sshd") ||
               FileManager.default.fileExists(atPath: "/etc/apt") ||
               FileManager.default.fileExists(atPath: "/private/var/lib/apt/") ||
               UIApplication.shared.canOpenURL(URL(string:"cydia://package/com.example.package")!) {
                   return true
           }
       
        // Check 2 : Reading and writing in system directories (sandbox violation)
       
       let stringToWrite = "Jailbreak Test"
        
       do {
            try stringToWrite.write(toFile:"/private/JailbreakTest.txt", atomically:true, encoding:String.Encoding.utf8)
                //Device is jailbroken
                return true
           } catch{
               return false
           }
       } else {
           return false
       }
    }
    
    /**
    Force application to exit if device is Jailbroken.
    - Parameter none
    - Returns: none.
    */
    
    func ExitOnJailbreak() {
        if isDeviceJailbroken() == true {
        // Exit the app if Jailbroken
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        }
    }
}

//LocationManager Delegate

extension AppDelegate: LocationServiceDelegate {
    func locationError(title: String, message: String) {
        
    }
    
    func locationHandleUserNotification(for region: CLRegion!) {
        handleUserNotification(for: region)
    }
}

//UILocalNotification Delegate methods

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        print("local notification present: ", notification.request.content.userInfo)
        print("willPresent method called")
           completionHandler([.alert, .sound])
        
       // localNotificationCenter.removeDeliveredNotifications(withIdentifiers: ["location_change"])
       // localNotificationCenter.removePendingNotificationRequests(withIdentifiers: ["location_change"])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        let application = UIApplication.shared
//
//        let alertTest = UIAlertController(title: "Title", message: "Test", preferredStyle: .alert)
//        self.window?.rootViewController?.present(alertTest, animated: true, completion: nil)
//
    //    localNotificationCenter.removeDeliveredNotifications(withIdentifiers: ["location_change"])
     //   localNotificationCenter.removePendingNotificationRequests(withIdentifiers: ["location_change"])
        
//        print("did receive notification")
//
//        if(application.applicationState == .active){
//          print("user tapped the notification bar when the app is in foreground")
//          self.showCovid19Assessment()
//        }
//
//        if(application.applicationState == .inactive)
//        {
//          self.showCovid19Assessment()
//        }
        
        self.showCovid19Assessment(nil)
        completionHandler()
        
        
    }
}

