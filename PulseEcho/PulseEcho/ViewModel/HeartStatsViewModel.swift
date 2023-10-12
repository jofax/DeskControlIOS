//
//  HeartStatsViewModel.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-08.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import CoreLocation

class HeartStatsViewModel: BaseViewModel {
    var geotifications: [GeoLocator] = []
    var locationManager = LocationService()
    
    override init() {
        super.init()
        locationManager.locationDelegate = self
    }
    
    // MARK: Loading and saving functions
    func loadAllGeotifications() {
        geotifications.removeAll()
        //let email = Utilities.instance.getUserEmail()
      
//        let allGeotifications = dataHelper.getAllFacilityLocation(email)
//        geotifications.append(contentsOf: allGeotifications)
//        LocationService.shared.startUpdatingLocation()
//        _ = geotifications.map { locationManager.startMonitoring(geotification: $0) }
    }
    
}

extension HeartStatsViewModel: LocationServiceDelegate {
    func locationHandleUserNotification(for region: CLRegion!) {
        
    }
    
    func locationError(title: String, message: String) {
        alertMessage?(title,message,0)
    }
}
