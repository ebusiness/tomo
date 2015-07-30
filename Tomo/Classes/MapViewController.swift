//
//  MapViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/16.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class MapViewController: BaseViewController {
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapping()
        
        RKObjectManager.sharedManager().getObjectsAtPath("/newsfeed", parameters: nil, success: { (operation, result) -> Void in
            self.mapView.addAnnotations(result.array())
        }) { (operation, err) -> Void in
            println(err)
        }

//        RKObjectManager.sharedManager().getObjectsAtPath("/newsfeed", parameters: nil,
//            success: { (_, results) -> Void in
//                if let results = results {
//                    var posts = results.array() as! [Post]
//                    self.mapView.addAnnotation(posts[0])
//                }
//            },
//            failure: { (_, error) -> Void in } )

    }
    
    override func viewDidAppear(animated: Bool) {
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        switch authStatus {
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .Denied, .Restricted:
            showLocationServiceDisabledAlert()
        default:
            return
        }
        
    }
    
}

// MARK: Action
extension MapViewController {
    
    @IBAction func showUser() {
        turnTo3DMap(mapView.userLocation.coordinate)
    }
    
    @IBAction func toggleInterest() {
        mapView.showsPointsOfInterest = !mapView.showsPointsOfInterest
    }
    
    @IBAction func toggleBuilding() {
        mapView.showsBuildings = !mapView.showsBuildings
    }
    
}

// MARK: MapView Delegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        
        let userCoordinate = userLocation.coordinate
        let region = MKCoordinateRegionMakeWithDistance(userCoordinate, 1500, 1500)
        
        UIView.animateWithDuration(2.0, animations: { () -> Void in
            self.mapView.setRegion(mapView.regionThatFits(region), animated: true)
        }) { (_) -> Void in
            self.mapView.showsUserLocation = false
            self.turnTo3DMap(userCoordinate)
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView? {
        
        if let annotation = annotation as? PostEntity {
            println(annotation)
            let annotationView = PostAnnotationView(annotation: annotation, reuseIdentifier: "PostAnnotationView")
            return annotationView
        } else {
            return nil
        }
    }
}

// MARK: Private function
extension MapViewController {
    
    private func setupMapping() {
        
        let userMapping = RKObjectMapping(forClass: UserEntity.self)
        userMapping.addAttributeMappingsFromDictionary([
            "_id": "id",
            "nickName": "nickName",
            "photo_ref": "photo"
        ])
        
        let postMapping = RKObjectMapping(forClass: PostEntity.self)
        postMapping.addAttributeMappingsFromDictionary([
            "_id": "id",
            "content": "content",
            "coordinate": "coordinateRawValue",
            "createDate": "createDate"
        ])
        
        let ownerRelationshipMapping = RKRelationshipMapping(fromKeyPath: "_owner", toKeyPath: "owner", withMapping: userMapping)
        
        postMapping.addPropertyMapping(ownerRelationshipMapping)
        
        let responseDescriptor = RKResponseDescriptor(mapping: postMapping, method: .GET, pathPattern: "/newsfeed", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        
        RKObjectManager.sharedManager().addResponseDescriptor(responseDescriptor)
        
    }
    
    private func showLocationServiceDisabledAlert() {
        
        let alert = UIAlertController(title: "请启用定位服务", message: "设置隐私定位服务", preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func turnTo3DMap(coordinate: CLLocationCoordinate2D) {
        
        let lat = coordinate.latitude
        let log = coordinate.longitude
        
        let from = CLLocationCoordinate2DMake(lat, log - 0.1)
        
        let camera = MKMapCamera(lookingAtCenterCoordinate: coordinate, fromEyeCoordinate: from, eyeAltitude: 500)
        camera.heading = CLLocationDirection.abs(0)
        
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.mapView.camera = camera
        })
        
    }
}
