//
//  GeoLocator.swift
//  PulseEcho
//
//  Created by Joseph on 2020-06-24.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import RealmSwift

enum EventType: String {
  case onEntry = "On Entry"
  case onExit = "On Exit"
}

class GeoLocator: Object {
    @objc dynamic var facilityLocation: Location?
    @objc dynamic var radius: Double = 100.0
    @objc dynamic var identifier: String = ""
    dynamic var eventType: EventType = .onEntry
    @objc dynamic var Email: String = ""
    @objc dynamic var timestamp: String = ""
  
    override static func primaryKey() -> String? {
        return "timestamp"
    }
  
    init(coordinate: Location, radius: Double, identifier: String, eventType: EventType) {
        super.init()
        let date = Date()
        self.timestamp = String(format: "%f", Double.timeStampFromDate(date: date as NSDate))
        self.facilityLocation = coordinate
        self.radius = radius
        self.identifier = identifier
        self.eventType = eventType
    }
    
    required override init() {
        
    }

}

class Location: Object {
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0

    convenience init(latitude: Double, longitude: Double) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
    }
}
