//
//  LocationManager.swift
//  The Wave
//
//  Created by Andrew Robinson on 8/16/17.
//  Copyright © 2017 XYello, Inc. All rights reserved.
//

import CoreLocation

@objc protocol LocationDelegate {
    func didUpdate(with location: CLLocation)
    @objc optional func didChange(authorizationStatus: CLAuthorizationStatus)
}

class Location: NSObject, CLLocationManagerDelegate {

    static let manager = Location()

    private var delegates = [LocationDelegate?]()
    private var clmanager = CLLocationManager()

    private(set) var lastLocation: CLLocation? {
        didSet {
            if let location = lastLocation {
                for delegate in delegates {
                    delegate?.didUpdate(with: location)
                }
            }
        }
    }

    private(set) var hasStartedLocationServices = false
    var locationAuthStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    var hasLocationAccess: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedWhenInUse
    }

    // MARK: - Public methods

    func startGatheringAndRequestPermission() {
        if !hasStartedLocationServices {
            requestLocationIfNeeded()
            startManager()
        }
    }

    func startGetheringWithoutPerissionRequest() {
        if !hasStartedLocationServices {
            startManager()
        }
    }

    func stopGathering() {
        clmanager.stopUpdatingLocation()
    }

    func add(asDelegate delegate: LocationDelegate) {
        delegates.append(delegate)
    }

    func getPlacemarkFromLastLocation(handler: @escaping (CLPlacemark?) -> ()) {
        if let lastLocation = lastLocation {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(lastLocation,
                                            completionHandler: { (placemarks, error) in
                                                if error == nil {
                                                    let firstLocation = placemarks?[0]
                                                    handler(firstLocation)
                                                } else {
                                                    handler(nil)
                                                }
            })
        }
        else {
            handler(nil)
        }
    }

    // MARK: - Private methods

    private func requestLocationIfNeeded() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            clmanager.requestWhenInUseAuthorization()
        }
    }

    private func startManager() {
        clmanager.startUpdatingLocation()
        clmanager.delegate = self
        hasStartedLocationServices = true
    }

    // MARK: - CLLocationManager delegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        for delegate in delegates {
            delegate?.didChange?(authorizationStatus: status)
        }
    }

}
