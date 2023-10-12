//
//  ApiURL.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-16.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import RealmSwift
import KeychainSwift

struct API {
    static let user = "/User"
    static let account = "/Acct"
    static let registration = "/Register"
    static let login = "/Login"
    static let activate = "/Activate"
    static let userUpdate = "/Update"
    static let forgotPassword = "/ForgotPassword"
    static let forgotPasswordComplete = "/FormatPasswordComplete"
    static let updatePassword = "/UpdatePassword"
    static let settings = "/Settings"
    static let clientSelect = "/ClientUserSelect"
    static let clientUpdate = "/ClientUserUpdate"
    static let profileSettingSelect = "/UserProfileSettingsSelect"
    static let profileSettingUpdate = "/UserProfileSettingsUpdate"
    static let device = "/Device"
    static let connect = "/Connect"
    static let userReport = "/UserReport"
    static let summaryReport = "/Summary"
    static let deskModeReport = "/ModeReport"
    static let activityReport = "/ActivityReport"
    static let clientUserRiskAssessment = "/ClientUserRiskAssessment"
    static let survey = "/Survey"
    static let nextSurveyRun = "/NextSurveyRun"
    static let surveyAnswers = "/SaveSurveyAnswers"
    static let configuration = "/Configuration"
    static let listDepartments = "/ListDepartments"
    static let resendActivation = "/ResendActivation"
    static let renewToken = "/Renew"
    static let dataResults = "/Results"
    static let queue = "/Queue"
    static let getBooking = "/GetBooking"
}

/**
 A class for server trust policy for accessing secured host
 */

class CustomServerTrustPolicyManager : ServerTrustManager {

    override func serverTrustEvaluator(forHost host: String) -> ServerTrustEvaluating? {
        return DefaultTrustEvaluator(validateHost: true)
    }
    public init() {
        super.init(evaluators: [:])
    }
}

/**
 Custom network manager with SSL verification.
 - parameter Bool withSSL
 - returns Manager
*/

func getCertificate(filename: String) -> SecCertificate {
    class Locator {}
    let filePath = Bundle(for: Locator.self).path(forResource: filename, ofType: "der")!
    let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
    let certificate = SecCertificateCreateWithData(nil, data as CFData)!

    return certificate
}

public func smartpodsManager(withSSL: Bool) -> Session {

     let _base64_cert = "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"

    guard withSSL else {

//        let policies: [String: ServerTrustEvaluating] = [
//            API_ENDPOINT.baseURL.absoluteString : DisabledTrustEvaluator()
//        ]
        
        let policies: [String: ServerTrustEvaluating] = [
            API_ENDPOINT.baseURL.absoluteString : PinnedCertificatesTrustEvaluator()
        ]

        let manager = Session(
            configuration: URLSessionConfiguration.default,
            serverTrustManager: ServerTrustManager(evaluators: policies)
        )

        return manager
    }

    if let certificateData = Data(base64Encoded: _base64_cert, options: []),
        let certificate = SecCertificateCreateWithData(nil, certificateData as CFData) {
        //  use certificate to initialize PinnedCertificatesTrustEvaluator, or ...

        var trust: SecTrust?
        let policy = SecPolicyCreateBasicX509()
        let status = SecTrustCreateWithCertificates(certificate, policy, &trust)

        if status == errSecSuccess, let trust = trust,
           let _ = SecTrustCopyPublicKey(trust) {

            let _: [String: ServerTrustEvaluating] = [
                API_ENDPOINT.baseURL.absoluteString : PinnedCertificatesTrustEvaluator(certificates: [certificate],
                                                                                       acceptSelfSignedCertificates: true,
                                                                                       performDefaultValidation: true,
                                                                                       validateHost: true)
            ]

            let manager = Session(
                configuration: URLSessionConfiguration.default,
                //serverTrustManager: ServerTrustManager(evaluators: policies)
                serverTrustManager: CustomServerTrustPolicyManager()
            )

            return manager
        }
    }

    return Session(configuration: URLSessionConfiguration.default,serverTrustManager: ServerTrustManager(evaluators: [:]))
}

/**
  HTTP headers to be used when requesting to web service.
- Parameter none
- Returns: [String: String] hash values.
*/

public func requestHeaders()-> [String: String] {
    let appVer = String(format: "%d", getAppVersion())
    let apiVer = APIVersion.version
    return ["Accept" : "application/json",
            "Content-Type" : "application/json; charset=UTF-8",
            "app_version":appVer,
            "api_version":apiVer]
}

/**
  Append request parameters with session key and session date.
- Parameter [String:String] params
- Returns: [String: String] hash values.
*/

public func addTokenToParameter(params: [String: Any])-> [String: Any] {
    var parameters = params
    parameters["SessionKey"] = Utilities.instance.getToken()
    parameters["SessionDated"] = Utilities.instance.getTokenGenerate()
    //print("addTokenToParameter: ", parameters)


    return parameters
}


func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func getAppVersion() -> Int {

    if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {

        let appVersionClean = appVersion.replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range:nil)

        if let appVersionNum = Int(appVersionClean) {
            return appVersionNum
        }
    }
    return 0
}

func realmMigrateLocalStorage(username: String) {
    let keychain = KeychainSwift()
    var config = Realm.Configuration()
    // Use the default directory, but replace the filename with the username
    config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(username).realm")
    config.encryptionKey = keychain.get(Constants.app_key_access)?.data(using: .utf8, allowLossyConversion: true)
    config.schemaVersion = UInt64(SchemaVersion.version + 1)
    //let _schema = Bundle.main.buildNumber
    // config.schemaVersion = UInt64(_schema) ?? UInt64(SchemaVersion.version + 1)
    config.migrationBlock = { migration, oldSchemaVersion in
        
        if (oldSchemaVersion < SchemaVersion.version) {
            // Nothing to do!
            // Realm will automatically detect new properties and removed properties
            // And will update the schema on disk automatically
        }
    }
    Realm.Configuration.defaultConfiguration = config
}

func getRealmForUser(username: String) -> Realm.Configuration {
    let keychain = KeychainSwift()
    var config = Realm.Configuration()
    // Use the default directory, but replace the filename with the username
    config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(username).realm")
    config.encryptionKey = keychain.get(Constants.app_key_access)?.data(using: .utf8, allowLossyConversion: true)    
    //config.encryptionKey = Constants.app_key.data(using: .utf8, allowLossyConversion: true)
    // Set this as the configusration used for the default Realm
    //let _schema = Bundle.main.buildNumber
    //config.schemaVersion =  UInt64(_schema) ?? UInt64(SchemaVersion.version + 1)
    config.schemaVersion = UInt64(SchemaVersion.version + 1)
    config.migrationBlock = { migration, oldSchemaVersion in
        
        if (oldSchemaVersion < SchemaVersion.version) {
            // Nothing to do!
            // Realm will automatically detect new properties and removed properties
            // And will update the schema on disk automatically
        }
    }
    //config.deleteRealmIfMigrationNeeded = true
    Realm.Configuration.defaultConfiguration = config
    return config
}


func getRealmForDevice(deviceId: String) -> Realm.Configuration {
    let keychain = KeychainSwift()
    var config = Realm.Configuration()
    // Use the default directory, but replace the filename with the username
    config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(deviceId).realm")
    config.encryptionKey = keychain.get(Constants.app_key_access)?.data(using: .utf8, allowLossyConversion: true)
    Realm.Configuration.defaultConfiguration = config
    return config
}
