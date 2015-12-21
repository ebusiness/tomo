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

    typealias Action = (CLLocation?) -> ()

    static let shareInstance = LocationController()

    private let locationManager = CLLocationManager()

    private var location: CLLocation?

    private var action: Action?

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

        guard self.action != nil else { return }
        
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
        stopLocationManager()
    }

}

// MARK: - private method

extension LocationController {

    private func determineStatus() -> Bool {

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

        case .Restricted:
            return false

        case .Denied:
            self.showRequestAuthorizationAlert()
            return false
        }
    }

    private func showRequestAuthorizationAlert() {

        // TODO: don't know why, have to call this on main queue, but it is on main queue already (from debug view) 
        dispatch_async(dispatch_get_main_queue()) {

            let title = "请启用定位服务"
            let message = "为了提供更好的服务，現場Tomo希望使用您的位置信息"

            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

            alert.addAction(UIAlertAction(title: "不允许", style: .Cancel) { _ in
                self.doAction()
            })

            alert.addAction(UIAlertAction(title: "设定", style: .Default) { _ in
                let url = NSURL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.sharedApplication().openURL(url)
            })

            let rootViewController = UIApplication.sharedApplication().delegate!.window!!.rootViewController
            rootViewController?.presentViewController(alert, animated: true, completion: nil)
        }
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

        guard let action = self.action else { return }

        if let location = self.location {
            action(location)
        } else {
            action(nil)
        }

        self.action = nil
    }
}

// MARK: - public method

extension LocationController {

    func doActionWithLocation(action: Action) {

        self.action = action

        guard self.determineStatus() else { return }

        self.timer = NSTimer.scheduledTimerWithTimeInterval(TomoConst.Timeout.Short, target: self, selector: Selector("stopLocationManager"), userInfo: nil, repeats: false)

        self.locationManager.startUpdatingLocation()
    }
}