//
//  LocationController.swift
//  Tomo
//
//  Created by starboychina on 2015/10/23.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import CoreLocation

final class LocationController: NSObject {

    typealias ActionWithLocation = (location: CLLocation?) -> ()

    typealias ActionWithPlacemark = (placemark: CLPlacemark?, location: CLLocation?) -> ()

    static let shareInstance = LocationController()

    private let locationManager = CLLocationManager()

    private let geocoder = CLGeocoder()

    private var location: CLLocation?

    private var placemark: CLPlacemark?

    private var error: NSError?

    private var actionWithLocation: ActionWithLocation?

    private var timer: NSTimer?

    private override init () {

        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.activityType = .Fitness
    }
    
}

// MARK: - CLLocationManagerDelegate

extension LocationController: CLLocationManagerDelegate {
    
    //location authorization status changed
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        guard self.actionWithLocation != nil else { return }
        
        switch status {

        case .AuthorizedWhenInUse, .AuthorizedAlways:
            self.locationManager.startUpdatingLocation()

        default:
            self.doAction()

        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let newLocation = locations.last!
        let accuracy = newLocation.horizontalAccuracy

        // horizontalAccuracy less than 0 is invalid result, ignore it
        guard accuracy >= 0 else { return }

        // ignore the result that accuracy less than desiredAccuracy
        guard accuracy <= locationManager.desiredAccuracy else { return }

        // accept the result
        self.location = newLocation

        // stop locating
        self.stopLocationManager()
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // or save the error and stop location manager
        // TODO: do something with error
        self.error = error
        stopLocationManager()
    }

}

// MARK: - private method

extension LocationController {

    private func determineStatus(authRequestOnController: UIViewController?) -> Bool {

        guard CLLocationManager.locationServicesEnabled() else {
            self.locationManager.startUpdatingLocation()
            return false
        }

        switch CLLocationManager.authorizationStatus() {

        case .AuthorizedAlways, .AuthorizedWhenInUse :
            return true

        case .NotDetermined:
            self.locationManager.requestWhenInUseAuthorization()
            return false

        case .Restricted, .Denied:
            if let controller = authRequestOnController {
                self.showRequestAuthorizationAlert(controller)
            }
            return false
        }
    }

    private func showRequestAuthorizationAlert(presentingController: UIViewController) {

        let alert = UIAlertController(title: "現場Tomo需要访问您的位置", message: "为了追加位置信息，请您允许現場Tomo访问您的位置", preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: "不允许", style: .Destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "设置", style: .Default, handler: { _ in
            let url = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(url!)
        }))

        presentingController.presentViewController(alert, animated: true, completion: nil)
    }

    func stopLocationManager() {
        
        self.locationManager.stopUpdatingLocation()

        if let timer = self.timer {
            timer.invalidate()
        }

        self.doAction()

        self.location = nil
    }

    private func doAction() {

        guard let action = self.actionWithLocation else { return }

        if let location = self.location {
            action(location: location)
        } else {
            action(location: nil)
        }

        self.actionWithLocation = nil
    }
}

// MARK: - public method

extension LocationController {

    // The idea is hold a function, then perform locating, invoke the function with location
    func doActionWithLocation(authRequestOnController: UIViewController? = nil, action: ActionWithLocation) {

        self.actionWithLocation = action

        // If the location service authorization granted, delay the function call after locating
        guard self.determineStatus(authRequestOnController) else {

            // If the first parameter is a view controller, and location service authorization 
            // is denied, alert will be shown, and the function invokation will be delay
            // to after user make authorization change.
            if authRequestOnController == nil {

                // If the first parameter is nil, and location service authorization
                // is denied, invoke the function with no location
                self.doAction()
            }

            return
        }

        self.timer = NSTimer.scheduledTimerWithTimeInterval(TomoConst.Timeout.Short, target: self, selector: Selector("stopLocationManager"), userInfo: nil, repeats: false)

        self.locationManager.startUpdatingLocation()
    }

    func doActionWithPlacemark(authRequestOnController: UIViewController? = nil, action: ActionWithPlacemark) {

        self.doActionWithLocation(authRequestOnController) { location in

            guard let location = location else {
                action(placemark: nil, location: nil)
                return
            }

            self.geocoder.reverseGeocodeLocation(location) { placemarks, error in
                self.error = error
                action(placemark: placemarks?.last, location: location)
            }
        }
    }
}