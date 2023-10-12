//
//  LocationService.swift
//  PulseEcho
//
//  Created by Joseph on 2020-06-25.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

protocol LocationServiceDelegate: class {
    func locationHandleUserNotification(for region: CLRegion!)
    func locationError(title: String, message: String)
}

class LocationService: NSObject, CLLocationManagerDelegate {
  static let shared = LocationService()
  weak var locationDelegate: LocationServiceDelegate?
    
    /// Activity speeds (in m/s).
    ///
    /// - minimumSpeed: Minimum speed to consider moving
    /// - runningMaxSpeed: Maximum speed to consider running
    /// - automotiveMaxSpeed: Maximum speed to consider automotive
    fileprivate let minimumSpeed = 0.3
    fileprivate let runningMaxSpeed = 7.5
    fileprivate let automotiveMaxSpeed = 69.44
    fileprivate let minumumRadius = 100.0

    /// Region radius
    fileprivate enum RegionRadius: Double {
        case tiny = 40.0
        case big = 80.0
    }
    
 // set the manager object right when it gets initialized
    let manager: CLLocationManager = {
        $0.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        $0.distanceFilter = 1.0
        $0.requestWhenInUseAuthorization()
        $0.allowsBackgroundLocationUpdates = true
        $0.startMonitoringSignificantLocationChanges()
        return $0
    }(CLLocationManager())
    
  private(set) var currentLocation: CLLocationCoordinate2D!
  private(set) var currentHeading: CLHeading!

    override init() {
    super.init()

    // delegate MUST be set while initialization
    manager.delegate = self
    manager.requestWhenInUseAuthorization()
  }
    
    // MARK: Control Mechanisms
    func startUpdatingLocation() {
        //manager.showsBackgroundLocationIndicator = false
        //manager.startUpdatingLocation()
        manager.startMonitoringSignificantLocationChanges()
        
    }
    
    func stopUpdatingLocation() {
        manager.showsBackgroundLocationIndicator = false
        manager.stopUpdatingLocation()
        manager.stopMonitoringSignificantLocationChanges()
    }
    
    func startUpdatingHeading() {
        manager.showsBackgroundLocationIndicator = false
        manager.startUpdatingHeading()
    }
    
    func stopUpdatingHeading() {
        manager.stopUpdatingHeading()
    }
    
    func isBackgroundLocationUpdatesAllowed() -> Bool {
        
        return CLLocationManager.authorizationStatus() == .authorizedAlways
        
    }

  // MARK: Location Updates
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("did update location :", locations)
    guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
    print("locations = \(locValue.latitude) \(locValue.longitude)")
    
    // If location data can be determined
        if let location = locations.last {
            currentLocation = location.coordinate
        }
  }

    func locationManager(_ manager: CLLocationManager,
                                             didFailWithError error: Error)
    {
    print("Location Manager Error: \(error)")
  }

  // MARK: Heading Updates
    func locationManager(_ manager: CLLocationManager,didUpdateHeading newHeading: CLHeading){
    currentHeading = newHeading
  }

    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
    return true
  }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
      if region is CLCircularRegion {
        locationDelegate?.locationHandleUserNotification(for: region)
      }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
      if region is CLCircularRegion {
        //locationDelegate?.locationHandleUserNotification(for: region)
        //let _region = CLCircularRegion(center: <#T##CLLocationCoordinate2D#>, radius: self.minumumRadius, identifier: <#T##String#>)
        //self.startMonitorWithRegion(region: _region)
      }
    }
    
    /**
     GEOFENCING
     **/
    func region(with geotification: GeoLocator) -> CLCircularRegion {
      let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: geotification.facilityLocation?.latitude ?? 0.0, longitude: geotification.facilityLocation?.longitude ?? 0.0)
      let region = CLCircularRegion(center: coordinate, radius: geotification.radius, identifier: geotification.identifier)
      region.notifyOnEntry = (geotification.eventType == .onEntry)
        region.notifyOnExit = (geotification.eventType == .onExit)
      return region
    }
    
    func startMonitoring(geotification: GeoLocator) {
        print("startMonitoring with locator: ", geotification.identifier)
      if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
        locationDelegate?.locationError(title: "generic.error_title".localize(), message: "geofencing.not_supported".localize())
        return
      }
      
      if CLLocationManager.authorizationStatus() != .authorizedAlways {
        locationDelegate?.locationError(title: "generic.warning".localize(), message: "geofencing.not_permitted".localize())
      }
      
      let fenceRegion = region(with: geotification)
        self.manager.startMonitoring(for: fenceRegion)
    }
    
    func startMonitorWithRegion(region: CLCircularRegion) {
        self.manager.startMonitoring(for: region)
    }

    func stopMonitoring(geotification: GeoLocator) {
        print("stopMonitoring with locator: ", geotification.identifier)
        for region in self.manager.monitoredRegions {
        guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else { continue }
            self.manager.stopMonitoring(for: circularRegion)
      }
    }
    
}
