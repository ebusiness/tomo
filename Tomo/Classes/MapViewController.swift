//
//  MapViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/16.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class MapViewController: BaseViewController {
    
    let PostAnnotationViewIdentifier = "PostAnnotationView"
    let locationManager = CLLocationManager()
    var allAnnotationMapView: MKMapView!
    
    var contents = [AnyObject]()
    
    var displayDate = NSDate()
    let calendar = NSCalendar.currentCalendar()
    let unitFlag = (NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay)
    
    var zoomedIn = false
    var lastViewRegion: MKCoordinateRegion?
    
    let tokyoCenter = CLLocationCoordinate2D(latitude: 35.693889, longitude: 139.753611)
    let tokyoSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
//    let tokyoRegion = MKCoordinateRegion(center: tokyoCenter, span: tokyoSpan)
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var chooseDateButton: UIButton!
    @IBOutlet weak var nextDay: UIButton!
    @IBOutlet weak var previousDay: UIButton!
    
    @IBOutlet weak var interestToggleButton: UIButton!
    @IBOutlet weak var buildingToggleButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    @IBOutlet weak var postMapView: UIView!
    @IBOutlet weak var postMapViewHeight: NSLayoutConstraint!
    
    var postMapViewController: PostMapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupAppearance()
        
        self.allAnnotationMapView = MKMapView(frame: CGRectZero)
        
        self.loadPostAt(displayDate)
        
        self.mapView.region = MKCoordinateRegion(center: tokyoCenter, span: tokyoSpan)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let controller = segue.destinationViewController as? PostMapViewController {
            self.postMapViewController = controller
        }
    }
    
}

// MARK: Action

extension MapViewController {
    
    @IBAction func nextDay(sender: AnyObject) {
        
        let dateComponent = NSDateComponents()
        dateComponent.day = 1
        
        let nextDate = calendar.dateByAddingComponents(dateComponent, toDate: displayDate, options: NSCalendarOptions.allZeros)
        
        displayDate = nextDate!
        self.chooseDateButton.setTitle(displayDate.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle, doesRelativeDateFormatting: false), forState: .Normal)
        
        self.loadPostAt(nextDate!)
    }
    
    @IBAction func previousDay(sender: AnyObject) {
        
        let dateComponent = NSDateComponents()
        dateComponent.day = -1
        
        let previousDate = calendar.dateByAddingComponents(dateComponent, toDate: displayDate, options: NSCalendarOptions.allZeros)
        
        displayDate = previousDate!
        self.chooseDateButton.setTitle(displayDate.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle, doesRelativeDateFormatting: false), forState: .Normal)
        
        self.loadPostAt(previousDate!)
    }
    
    @IBAction func chooseDate(sender: AnyObject) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "今天", style: .Default, handler: nil))
        alert.addAction(UIAlertAction(title: "昨天", style: .Default, handler: nil))
        alert.addAction(UIAlertAction(title: "两天前", style: .Default, handler: nil))
        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
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
    
//    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
//        
//        let userCoordinate = userLocation.coordinate
//        let region = MKCoordinateRegionMakeWithDistance(userCoordinate, 1500, 1500)
//        
//        UIView.animateWithDuration(2.0, animations: { () -> Void in
//            self.mapView.setRegion(mapView.regionThatFits(region), animated: true)
//        }) { (_) -> Void in
//            self.mapView.showsUserLocation = false
//            self.turnTo3DMap(userCoordinate)
//        }
//    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView? {
        
        if mapView != self.mapView {
            return nil
        }
        
        if let annotation = annotation as? PostAnnotation {
            
            var annotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier(PostAnnotationViewIdentifier)
            
            if annotationView == nil {
                annotationView = PostAnnotationView(annotation: annotation, reuseIdentifier: PostAnnotationViewIdentifier)
            } else {
                annotationView.annotation = annotation
                (annotationView as! PostAnnotationView).setupDisplay()
            }
            
            return annotationView
        } else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        self.updateVisibleAnnotations()
    }
    
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        
        for view in views {
            
            if let annotation = view.annotation as? PostAnnotation {
                
                if (annotation.clusterAnnotation != nil) {
                    
                    // animate the annotation from it's old container's coordinate, to its actual coordinate
                    let actualCoordinate = annotation.coordinate
                    let containerCoordinate = annotation.clusterAnnotation!.coordinate
                    
                    // since it's displayed on the map, it is no longer contained by another annotation,
                    // (We couldn't reset this in -updateVisibleAnnotations because we needed the reference to it here
                    // to get the containerCoordinate)
                    annotation.clusterAnnotation = nil
                    
                    annotation.coordinate = containerCoordinate
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        annotation.coordinate = actualCoordinate
                        
                    })
                }
            }
            
            if let view = view as? PostAnnotationView {
                view.expandIntoView(self.view, finished: nil)
                view.updateBadge()
                view.updateScale()
                //                view.bounce(nil)
            }
        }
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
        if !zoomedIn {
            self.lastViewRegion = mapView.region
            self.zoomedIn = !self.zoomedIn
        }
        
        if let annotation = view.annotation as? PostAnnotation {
            
            let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 10, 10)
            
            let post = annotation.post!
            self.postMapViewController?.configDisplay(post)
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.postMapViewHeight.constant = UIScreen.mainScreen().bounds.height / 3
                self.view.layoutIfNeeded()
            }) { (finish) -> Void in
                self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
            }
        }
    }

    @IBAction func mapTapped(sender: UITapGestureRecognizer) {
        
        var tapOn = sender.locationInView(self.mapView)
        
        if self.mapView.hitTest(tapOn, withEvent: nil) is PostAnnotationView {
            return
        } else {
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.postMapViewHeight.constant = 0.0
                self.view.layoutIfNeeded()
            }) { (finish) -> Void in
                self.zoomedIn = false
                if let region = self.lastViewRegion {
                    self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
                }
            }
        }
    }

}

// MARK: Internal Methods

extension MapViewController {
    
    private func setupAppearance() {
        
        self.chooseDateButton.setTitle(NSDate().toString(dateStyle: .MediumStyle, timeStyle: .NoStyle, doesRelativeDateFormatting: false), forState: .Normal)
        
        self.nextDay.hidden = true
        
        self.postMapViewHeight.constant = 0.0
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
    
    private func loadPostAt(date: NSDate) {
        
        let todayComponents = calendar.components(unitFlag, fromDate: NSDate())
        let today = calendar.dateFromComponents(todayComponents)
        
        let requestDayComponents = calendar.components(unitFlag, fromDate: date)
        let requestDay = calendar.dateFromComponents(requestDayComponents)
        
        if today?.timeIntervalSince1970 == requestDay?.timeIntervalSince1970 {
            self.nextDay.hidden = true
        } else {
            self.nextDay.hidden = false
        }
        
        self.allAnnotationMapView.removeAnnotations(self.allAnnotationMapView.annotations)
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        AlamofireController.request(.GET, "/posts", parameters: ["category": "mapnews", "size": 50], success: { result in

            if let loadPosts:[PostEntity] = PostEntity.collection(result) {
                
                let annotations = loadPosts.map { post -> PostAnnotation in
                    let annotation = PostAnnotation()
                    annotation.post = post
                    if let lat = post.coordinate?.get(0), log = post.coordinate?.get(1) {
                        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: log)
                    }
                    return annotation
                }
                self.allAnnotationMapView.addAnnotations(annotations)
                self.updateVisibleAnnotations()
            }
            
            
        }) { err in
            
        }
    }
    
    private func updateVisibleAnnotations() {
        
        // This value to controls the number of off screen annotations are displayed.
        // A bigger number means more annotations, less chance of seeing annotation views pop in but decreased performance.
        // A smaller number means fewer annotations, more chance of seeing annotation views pop in but better performance.
        let marginFactor = 1.0;
        
        // Adjust this roughly based on the dimensions of your annotations views.
        // Bigger numbers more aggressively coalesce annotations (fewer annotations displayed but better performance).
        // Numbers too small result in overlapping annotations views and too many annotations on screen.
        let bucketSize = 120.0;
        
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
                            view.updateScale()
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
        
        // first, see if one of the annotations we were already showing is in this mapRect
        let visibleAnnotationsInBucket = mapView.annotationsInMapRect(gridMapRect)
        
        for annotation in annotations {
            if visibleAnnotationsInBucket.contains(annotation) {
                return annotation
            }
        }
        
        // otherwise, sort the annotations based on their distance from the center of the grid square,
        // then choose the one closest to the center to show
        let centerMapPoint = MKMapPoint(x: MKMapRectGetMidX(gridMapRect), y: MKMapRectGetMidY(gridMapRect))
        let sortedAnnotations = annotations.sorted { (obj1, obj2) -> Bool in
            
            let mapPoint1 = MKMapPointForCoordinate((obj1 as! MKAnnotation).coordinate)
            let mapPoint2 = MKMapPointForCoordinate((obj2 as! MKAnnotation).coordinate)
            
            let distance1 = MKMetersBetweenMapPoints(mapPoint1, centerMapPoint)
            let distance2 = MKMetersBetweenMapPoints(mapPoint2, centerMapPoint)
            
            if distance1 < distance2 {
                return true
            } else {
                return false
            }
        }
        
        return sortedAnnotations.first
    }
}
