//
//  LocationController.swift
//  Tomo
//
//  Created by starboychina on 2015/10/23.
//  Copyright © 2015 e-business. All rights reserved.
//

import UIKit
import CoreLocation

final class LocationController: NSObject {

    typealias ActionWithLocation = (_ location: CLLocation?) -> Void

    typealias ActionWithPlacemark = (_ placemark: CLPlacemark?, _ location: CLLocation?) -> Void

    static let shareInstance = LocationController()

    private var placemark: CLPlacemark?

    fileprivate let locationManager = CLLocationManager()

    fileprivate let geocoder = CLGeocoder()

    fileprivate var location: CLLocation?

    fileprivate var error: Error?

    fileprivate var actionWithLocation: ActionWithLocation?

    fileprivate var timer: Timer?

    private override init () {

        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.activityType = .fitness
    }

}

// MARK: - CLLocationManagerDelegate

extension LocationController: CLLocationManagerDelegate {

    //location authorization status changed
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        guard self.actionWithLocation != nil else { return }

        switch status {

        case .authorizedWhenInUse, .authorizedAlways:
            self.locationManager.startUpdatingLocation()

        default:
            self.doAction()

        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

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

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // or save the error and stop location manager
        // TODO: do something with error
        self.error = error
        stopLocationManager()
    }

}

// MARK: - private method

extension LocationController {

    fileprivate func determineStatus(_ authRequestOnController: UIViewController?) -> Bool {

        guard CLLocationManager.locationServicesEnabled() else {
            self.locationManager.startUpdatingLocation()
            return false
        }

        switch CLLocationManager.authorizationStatus() {

        case .authorizedAlways, .authorizedWhenInUse:
            return true

        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
            return false

        case .restricted, .denied:
            if let controller = authRequestOnController {
                self.showRequestAuthorizationAlert(presentingController: controller)
            }
            return false
        }
    }

    private func showRequestAuthorizationAlert(presentingController: UIViewController) {

        let alert = UIAlertController(title: "現場Tomo需要访问您的位置", message: "为了追加位置信息，请您允许現場Tomo访问您的位置", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "不允许", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "设置", style: .default, handler: { _ in
            let url = URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.openURL(url!)
        }))

        presentingController.present(alert, animated: true, completion: nil)
    }

    func stopLocationManager() {

        self.locationManager.stopUpdatingLocation()

        if let timer = self.timer {
            timer.invalidate()
        }

        self.doAction()

        self.location = nil
    }

    fileprivate func doAction() {

        guard let action = self.actionWithLocation else { return }

        if let location = self.location {
            action(location)
        } else {
            action(nil)
        }

        self.actionWithLocation = nil
    }
}

// MARK: - public method

extension LocationController {

    // The idea is hold a function, then perform locating, invoke the function with location
    func doActionWithLocation(authRequestOnController: UIViewController? = nil, action: @escaping ActionWithLocation) {

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

        self.timer = Timer.scheduledTimer(timeInterval: TomoConst.Timeout.Short, target: self, selector: #selector(LocationController.stopLocationManager), userInfo: nil, repeats: false)

        self.locationManager.startUpdatingLocation()
    }

    func doActionWithPlacemark(authRequestOnController: UIViewController? = nil, action: @escaping ActionWithPlacemark) {

        self.doActionWithLocation(authRequestOnController: authRequestOnController) { location in

            guard let location = location else {
                action(nil, nil)
                return
            }

            self.geocoder.reverseGeocodeLocation(location) { placemarks, error in
                self.error = error
                action(placemarks?.last, location)
            }
        }
    }
}
