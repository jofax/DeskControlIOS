//
//  Booking.swift
//  PulseEcho
//
//  Created by Joseph on 2021-05-27.
//  Copyright © 2021 Smartpods. All rights reserved.
//

import Foundation
import RealmSwift

struct DeskBookingInfo {
    var BookingId: Int
    var BookingDate: String
    var Email: String
    var IsEnabled: Bool
    var IsLoggedIn: Bool
    var Periods: [[String: Any]] = [[String: Any]]()
    var TzOffset: Int
    var UtcDateTime: String
    var IsHotelingStateEnabled: Bool
    
    
    init(params: [String: Any]) {
        self.BookingId = params["BookingId"] as? Int ?? 0
        self.BookingDate = params["BookingDate"] as? String ?? ""
        self.Email = params["Email"] as? String ?? ""
        self.IsEnabled = params["IsEnabled"] as? Bool ?? false
        self.IsLoggedIn = params["IsLoggedIn"] as? Bool ?? false
        self.TzOffset = params["TzOffset"] as? Int ?? 0
        self.UtcDateTime = params["UtcDateTime"] as? String ?? ""
        self.Periods = params["Periods"] as? [[String: Any]] ?? [[String: Any]]()
        self.IsHotelingStateEnabled = params["IsHotelingStateEnabled"] as? Bool ?? false
    }
    
}

public struct DeskBooking {
    let SerialNumber: String
    let EncryptedData: [UInt8]
    let Iv: String
}

extension DeskBooking: Codable {

 enum CodingKeys: String, CodingKey {
    case SerialNumber = "SerialNumber"
    case EncryptedData = "EncryptedData"
    case Iv = "Iv"
  }

}
