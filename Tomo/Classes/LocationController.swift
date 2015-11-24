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
    
    typealias LocationClosure = ((location: CLLocation?)->())
    
    private var timeoutTimer: NSTimer?
    //location manager
    private let locationManager = CLLocationManager()
    
    private var locationRequests = [LocationClosure]()
    
    private var location: CLLocation? { //dynamic -> KVO
        didSet {
            if let location = location {
                // accuracy better than desiredAccuracy, stop locating
                if location.horizontalAccuracy <= locationManager.desiredAccuracy {
                    stopLocationManager(location)
                } else {
                    locationRequests.forEach { locationRequest in
                        locationRequest(location: location)
                    }
                }
            }
        }
    }
    
    //window
    private let window : UIWindow? = {
        
        return UIApplication.sharedApplication().keyWindow
        
    }()
    
    static let shareInstance: LocationController = {
        return LocationController()
    }()
    
    private override init (){
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.activityType = .Fitness
    }
    
}

// MARK: - CLLocationManagerDelegate

extension LocationController: CLLocationManagerDelegate {
    
    //location authorization status changed
    internal func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
        case .AuthorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
            if let timer = timeoutTimer {
                timer.invalidate()
            }
            timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "timeout", userInfo: nil, repeats: false)
        case .Denied:
            locationRequests.removeAll()
            stopLocationManager()
        default:
            break
        }
    }
    
    internal func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        stopLocationManager()
    }
    
    internal func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last!
        
        let locationAge = -newLocation.timestamp.timeIntervalSinceNow
        
        // the location object was determine too long age, ignore it
        if locationAge > 5.0{
            return
        }
        
        // horizontalAccuracy less than 0 is invalid result, ignore it
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = self.location {
            distance = newLocation.distanceFromLocation(location)
        }
        
        // new location object more accurate than previous one
        if self.location == nil || self.location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            // accept the result
            self.location = newLocation
            
        // if the location didn't changed too much
        } else if distance < 1.0 {
            
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            
            if timeInterval > 10 {
                stopLocationManager(location)
            }
        }
    }
}

// MARK: - private method

extension LocationController {
    @objc private func timeout(){
        stopLocationManager(nil)
    }
    
    //location manager returned, call didcomplete closure
    private func stopLocationManager(location: CLLocation? = nil) {
        
        if let timer = timeoutTimer {
            timer.invalidate()
        }
        
        locationManager.stopUpdatingLocation()
        
        if let location = location {
            locationRequests.forEach { locationRequest in
                locationRequest(location: location)
            }
        }
        
        locationRequests.removeAll()
    }
    
    private func showLocationServiceDisabledAlert() {
        if let vc = self.window?.rootViewController {
            Util.alert(vc, title: "请启用定位服务", message: "设置隐私定位服务", cancel: "OK")
        }
    }
}

// MARK: - public method

extension LocationController {
    
    //ask for location permissions, fetch 1 location, and return
    func fetchWithCompletion(completion: LocationClosure) {
        //store the completion closure
        locationRequests.append(completion)
        
        if locationRequests.count > 1 { return }
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        switch authStatus {
        case .NotDetermined:
            //check for description key and ask permissions
            if (NSBundle.mainBundle().objectForInfoDictionaryKey("NSLocationWhenInUseUsageDescription") != nil) {
                locationManager.requestWhenInUseAuthorization()
            } else if (NSBundle.mainBundle().objectForInfoDictionaryKey("NSLocationAlwaysUsageDescription") != nil) {
                locationManager.requestAlwaysAuthorization()
            } else {
                fatalError("To use location in iOS8 you need to define either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription in the app bundle's Info.plist file")
            }
        case .Denied, .Restricted:
            self.showLocationServiceDisabledAlert()
        default:
            break
        }
    }
}