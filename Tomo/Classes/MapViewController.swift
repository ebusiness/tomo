//
//  MapViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/16.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class MapViewController: BaseViewController {
    
    static let PostAnnotationViewIdentifier = "PostAnnotationView"
    let locationManager = CLLocationManager()
    var allAnnotationMapView: MKMapView!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var interestToggleButton: UIButton!
    @IBOutlet weak var buildingToggleButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allAnnotationMapView = MKMapView(frame: CGRectZero)
        
        decorateButton(interestToggleButton)
        decorateButton(buildingToggleButton)
        decorateButton(currentLocationButton)
        
        manager.getObjectsAtPath("/mapnews", parameters: nil, success: { (operation, result) -> Void in
            
            for annotation in result.array() {
                if let annotation = annotation as? PostAnnotation {
                    let post = annotation.post
                    if let lat = post.coordinate?.get(0), log = post.coordinate?.get(1) {
                        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: log)
                    }
                }
            }
            
            self.allAnnotationMapView.addAnnotations(result.array())
            self.updateVisibleAnnotations()
//            self.mapView.addAnnotations(result.array())
        }) { (operation, err) -> Void in
            println(err)
        }
        
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func setupMapping() {
        
        let userMapping = RKObjectMapping(forClass: UserEntity.self)
        userMapping.addAttributeMappingsFromDictionary([
            "_id": "id",
            "nickName": "nickName",
            "photo_ref": "photo"
            ])
        
        let postMapping = RKObjectMapping(forClass: PostEntity.self)
        postMapping.addAttributeMappingsFromDictionary([
            "_id": "id",
            "contentText": "content",
            "coordinate": "coordinate",
            "createDate": "createDate"
            ])
        
        let ownerRelationshipMapping = RKRelationshipMapping(fromKeyPath: "_owner", toKeyPath: "owner", withMapping: userMapping)
        postMapping.addPropertyMapping(ownerRelationshipMapping)
        
        let postAnnotationMapping = RKObjectMapping(forClass: PostAnnotation.self)
        let postRelationshipMapping = RKRelationshipMapping(fromKeyPath: nil, toKeyPath: "post", withMapping: postMapping)
        postAnnotationMapping.addPropertyMapping(postRelationshipMapping)
        
        let responseDescriptor = RKResponseDescriptor(mapping: postAnnotationMapping, method: .GET, pathPattern: "/mapnews", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        
        manager.addResponseDescriptor(responseDescriptor)
        
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
        
        if mapView != self.mapView {
            return nil
        }
        
        if let annotation = annotation as? PostAnnotation {
            var annotationView = PostAnnotationView(annotation: annotation, reuseIdentifier: MapViewController.PostAnnotationViewIdentifier)
//            annotationView.canShowCallout = true
            
            return annotationView
        } else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        updateVisibleAnnotations()
    }
    
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        
        for view in views {
            
            if let annotation = view.annotation as? PostAnnotation {
                
                if (annotation.clusterAnnotation != nil) {
                    let actualCoordinate = annotation.coordinate
                    let containerCoordinate = annotation.clusterAnnotation!.coordinate
                    
                    annotation.clusterAnnotation = nil
                    annotation.coordinate = containerCoordinate
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        annotation.coordinate = actualCoordinate
                    })
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
//        if let annotation = view.annotation as? PostAnnotation {
//            
//            let postViewController = Util.createViewControllerWithIdentifier("PostView", storyboardName: "Home") as! PostViewController
//            
//            postViewController.post = annotation.post!
//            
//            presentViewController(postViewController, animated: true, completion: nil)
//            
//        }
    }

}

// MARK: Private function
extension MapViewController {
    
    private func decorateButton(button: UIButton) {
        button.backgroundColor = UIColor.whiteColor()
        button.layer.cornerRadius = interestToggleButton.frame.width / 2
        button.layer.borderColor = UIColor.orangeColor().CGColor
        button.layer.borderWidth = 1
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
    
    private func updateVisibleAnnotations() {
        
        // This value to controls the number of off screen annotations are displayed.
        // A bigger number means more annotations, less chance of seeing annotation views pop in but decreased performance.
        // A smaller number means fewer annotations, more chance of seeing annotation views pop in but better performance.
        let marginFactor = 0.0;
        
        // Adjust this roughly based on the dimensions of your annotations views.
        // Bigger numbers more aggressively coalesce annotations (fewer annotations displayed but better performance).
        // Numbers too small result in overlapping annotations views and too many annotations on screen.
        let bucketSize = 160.0;
        
        // find all the annotations in the visible area + a wide margin to avoid popping annotation views in and out while panning the map.
        let visibleMapRect = mapView.visibleMapRect
        let adjustedVisibleMapRect = MKMapRectInset(visibleMapRect, -marginFactor * visibleMapRect.size.width, -marginFactor * visibleMapRect.size.height)
        
        // determine how wide each bucket will be, as a MKMapRect square
        let leftCoordinate = mapView.convertPoint(CGPointZero, toCoordinateFromView: mapView)
        let rightCoordinate = mapView.convertPoint(CGPointMake(CGFloat(bucketSize), CGFloat(0.0)), toCoordinateFromView: mapView)
        
        // determine how wide each bucket will be, as a MKMapRect square
        let gridSize = MKMapPointForCoordinate(rightCoordinate).x - MKMapPointForCoordinate(leftCoordinate).x
        var gridMapRect = MKMapRectMake(0, 0, gridSize, gridSize)
        
        // condense annotations, with a padding of two squares, around the visibleMapRect
        let startX = floor(MKMapRectGetMinX(adjustedVisibleMapRect) / gridSize) * gridSize
        let startY = floor(MKMapRectGetMinY(adjustedVisibleMapRect) / gridSize) * gridSize
        let endX = floor(MKMapRectGetMaxX(adjustedVisibleMapRect) / gridSize) * gridSize
        let endY = floor(MKMapRectGetMaxY(adjustedVisibleMapRect) / gridSize) * gridSize
        
        // for each square in our grid, pick one annotation to show
        gridMapRect.origin.y = startY
        while (MKMapRectGetMinY(gridMapRect) <= endY) {
            
            gridMapRect.origin.x = startX
            while (MKMapRectGetMinX(gridMapRect) <= endX) {
                
                var allAnnotationsInBucket = allAnnotationMapView.annotationsInMapRect(gridMapRect)
                let visibleAnnotationsInBucket = mapView.annotationsInMapRect(gridMapRect)
                
                if let allAnnotationsInBucket = allAnnotationsInBucket {
                    
                    var allAnnotations = Array(allAnnotationsInBucket) as! [PostAnnotation]
                    
                    if let annotationForGrid = annotationInGrid(gridMapRect, usingAnnotations: allAnnotations) as? PostAnnotation {
                        
                        allAnnotations.remove(annotationForGrid)
                
                        // give the annotationForGrid a reference to all the annotations it will represent
                        annotationForGrid.containedAnnotations = allAnnotations
                        
                        mapView.addAnnotation(annotationForGrid)
                        
                        if let view = mapView.viewForAnnotation(annotationForGrid) as? PostAnnotationView {
                            view.updateBadge()
                        }
            
                        
                        for annotation in allAnnotations {
                            
                            // give all the other annotations a reference to the one which is representing them
                            annotation.clusterAnnotation = annotationForGrid
                            annotation.containedAnnotations = nil
                            
                            // remove annotations which we've decided to cluster
                            if visibleAnnotationsInBucket.contains(annotation) {
                                
                                let actualCoordinate = annotation.coordinate
                                
                                UIView.animateWithDuration(0.3, animations: { () -> Void in
                                    annotation.coordinate = annotation.clusterAnnotation!.coordinate
                                }, completion: { [unowned self, annotation, actualCoordinate](finished) -> Void in
                                    annotation.coordinate = actualCoordinate
                                    self.mapView.removeAnnotation(annotation)
                                })
                                
                            }
                        }
                    }
                }
                
                gridMapRect.origin.x += gridSize
            }
            
            gridMapRect.origin.y += gridSize
        }
    }
    
    private func annotationInGrid(gridMapRect: MKMapRect, usingAnnotations annotations: Array<NSObject>) -> NSObject? {
        
        let visibleAnnotationsInBucket = mapView.annotationsInMapRect(gridMapRect)
        
        for annotation in annotations {
            if visibleAnnotationsInBucket.contains(annotation) {
                return annotation
            }
        }
        
        return annotations.first
    }
}
