//
//  MapViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/16.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

enum InterfaceMode: Int {
    case StationListMode
    case GroupListMode
    case PostListMode
//    case StationMode
    case GroupMode
}

final class MapViewController: UIViewController {
    
    var mode = InterfaceMode.PostListMode
    
    let pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    
    let PostAnnotationViewIdentifier = "PostAnnotationView"
    let GroupAnnotationViewIdentifier = "GroupAnnotationView"
    let StationAnnotationViewIdentifier = "StationAnnotationView"
    
    let locationManager = CLLocationManager()
    var allAnnotationMapView: MKMapView!
    
    var contents = [AnyObject]()
    
    var displayDate = NSDate()
    let calendar = NSCalendar.currentCalendar()
    let unitFlag = (NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay)
    
    var displayGroup: GroupEntity?
    
    let tokyoCenter = CLLocationCoordinate2D(latitude: 35.693889, longitude: 139.753611)
    let tokyoSpan = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var chooseDateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupAppearance()
        
        self.allAnnotationMapView = MKMapView(frame: CGRectZero)
        
//        self.loadPostAt(displayDate)
        self.showPostMode(self)
        
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
    
}

// MARK: Action

extension MapViewController {
    
    @IBAction func chooseDate(sender: AnyObject) {
        
        let vc = Util.createViewControllerWithIdentifier("TestView", storyboardName: "Map")
        
        vc.modalPresentationStyle = .Popover
        vc.popoverPresentationController?.delegate = self
        vc.preferredContentSize = CGSize(width: 150, height: 100)
        self.presentViewController(vc, animated: true, completion: nil)
        
        if let pop = vc.popoverPresentationController {
            let v = sender as! UIView
            pop.sourceView = v
            pop.sourceRect = v.bounds
            pop.permittedArrowDirections = .Down
        }

    }
    
    @IBAction func dateLabelSwiped(sender: UISwipeGestureRecognizer) {
        if sender.direction == .Left {
            self.nextDay()
        } else {
            self.previousDay()
        }
    }
    
    @IBAction func showCurrentLocation() {
        self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 10000, 10000), animated: true)
    }
    
    @IBAction func showPostMode(sender: AnyObject) {
        self.mode = .PostListMode
        self.loadContents()
    }
    
    @IBAction func showGroupMode(sender: AnyObject) {
        self.mode = .GroupListMode
        self.loadContents()
    }
    
    @IBAction func showStationMode(sender: AnyObject) {
        self.mode = .StationListMode
        self.loadContents()
    }
}

extension MapViewController: UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate {
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
}

// MARK: MapView Delegate

extension MapViewController: MKMapViewDelegate {
    
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
            }
            (annotationView as! PostAnnotationView).setupDisplay()
            
            return annotationView
            
        } else if let annotation = annotation as? GroupAnnotation {
            
            var annotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier(GroupAnnotationViewIdentifier)
            
            if annotationView == nil {
                annotationView = GroupAnnotationView(annotation: annotation, reuseIdentifier: GroupAnnotationViewIdentifier)
            } else {
                annotationView.annotation = annotation
            }
            (annotationView as! GroupAnnotationView).setupDisplay()
            
            return annotationView
            
        } else if let annotation = annotation as? StationAnnotation {
            
            var annotationView = self.mapView.dequeueReusableAnnotationViewWithIdentifier(StationAnnotationViewIdentifier)
            
            if annotationView == nil {
                annotationView = StationAnnotationView(annotation: annotation, reuseIdentifier: StationAnnotationViewIdentifier)
            } else {
                annotationView.annotation = annotation
            }
            (annotationView as! StationAnnotationView).setupDisplay()
            
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
            
            if let annotation = view.annotation as? AggregatableAnnotation {
                
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
            
            if let view = view as? AggregatableAnnotationView {
                view.setupDisplay()
            }
        }
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        if let view = view as? PostAnnotationView {
            
            let pvc = PostCallOutViewController(nibName: "PostCallOutView", bundle: nil)
            pvc.postAnnotation = view.annotation as! PostAnnotation
            
            pageViewController.preferredContentSize = pvc.view.systemLayoutSizeFittingSize(CGSize(width: 300, height: 300), withHorizontalFittingPriority: 1000, verticalFittingPriority: 250)
            pageViewController.dataSource = view
            
            self.showPopover(pvc, onView: view)
            
        } else if let view = view as? GroupAnnotationView {
            
            let groupAnnotation = view.annotation as! GroupAnnotation
            
            if groupAnnotation.containedAnnotations?.count == 0 {
                
                self.mode = .GroupMode
                self.displayGroup = groupAnnotation.group
                self.loadContents()
                
            } else {
                
                let gvc = GroupCallOutViewController(nibName: "GroupCallOutView", bundle: nil)
                gvc.groupAnnotation = view.annotation as! GroupAnnotation
                
                pageViewController.preferredContentSize = gvc.view.systemLayoutSizeFittingSize(CGSize(width: 320, height: 200), withHorizontalFittingPriority: 1000, verticalFittingPriority: 1000)
                pageViewController.dataSource = view
                
                self.showPopover(gvc, onView: view)
            }
            
        }
        
    }
}

// MARK: Internal Methods

extension MapViewController {
    
    private func setupAppearance() {
        
        self.chooseDateButton.setTitle(NSDate().toString(dateStyle: .MediumStyle, timeStyle: .NoStyle, doesRelativeDateFormatting: false), forState: .Normal)
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
    
    private func showPopover(viewController: UIViewController, onView view: UIView) {
        
        pageViewController.setViewControllers([viewController], direction: .Forward, animated: false, completion: nil)
        pageViewController.modalPresentationStyle = .Popover
        pageViewController.popoverPresentationController?.delegate = self
        
        self.presentViewController(pageViewController, animated: true, completion: nil)
        
        if let pop = pageViewController.popoverPresentationController {
            pop.backgroundColor = UIColor.whiteColor()
            pop.sourceView = view
            pop.sourceRect = view.bounds
        }
    }
    
    private func getCurrentBox() -> [Double] {
        
        let visibleRect = mapView.visibleMapRect
        
        let left = MKMapRectGetMinX(visibleRect)
        let right = MKMapRectGetMaxX(visibleRect)
        let top = MKMapRectGetMinY(visibleRect)
        let bottom = MKMapRectGetMaxY(visibleRect)
        
        let leftBottom = MKCoordinateForMapPoint(MKMapPoint(x: left, y: bottom))
        let rightTop = MKCoordinateForMapPoint(MKMapPoint(x: right, y: top))
        
        // println("[\(leftBottom.latitude),\(leftBottom.longitude)],[\(rightTop.latitude),\(rightTop.longitude)]")
        
        return [leftBottom.latitude, leftBottom.longitude, rightTop.latitude, rightTop.longitude]
    }
    
    func nextDay() {
        
        let dateComponent = NSDateComponents()
        dateComponent.day = 1
        
        let nextDate = calendar.dateByAddingComponents(dateComponent, toDate: displayDate, options: NSCalendarOptions.allZeros)
        
        displayDate = nextDate!
        self.chooseDateButton.setTitle(displayDate.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle, doesRelativeDateFormatting: false), forState: .Normal)
        
        self.loadContents()
    }
    
    func previousDay() {
        
        let dateComponent = NSDateComponents()
        dateComponent.day = -1
        
        let previousDate = calendar.dateByAddingComponents(dateComponent, toDate: displayDate, options: NSCalendarOptions.allZeros)
        
        displayDate = previousDate!
        self.chooseDateButton.setTitle(displayDate.toString(dateStyle: .MediumStyle, timeStyle: .NoStyle, doesRelativeDateFormatting: false), forState: .Normal)
        
        self.loadContents()
    }
    
    private func loadContents() {
        
        let todayComponents = calendar.components(unitFlag, fromDate: NSDate())
        let today = calendar.dateFromComponents(todayComponents)
        
        let requestDayComponents = calendar.components(unitFlag, fromDate: displayDate)
        let requestDay = calendar.dateFromComponents(requestDayComponents)
        
        self.allAnnotationMapView.removeAnnotations(self.allAnnotationMapView.annotations)
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        switch self.mode {
        case .PostListMode:
            AlamofireController.request(.GET, "/posts", parameters: ["category": "map", "day": requestDay!.timeIntervalSince1970], success: { postData in
                
                if let posts:[PostEntity] = PostEntity.collection(postData) {
                    
                    let annotations = posts.map { post -> PostAnnotation in
                        let annotation = PostAnnotation()
                        annotation.post = post
                        if let lat = post.coordinate?.get(0), log = post.coordinate?.get(1) {
                            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: log)
                        }
                        return annotation
                    }
                    self.allAnnotationMapView.addAnnotations(annotations)
                }
                self.adjustRegion()
                self.updateVisibleAnnotations()
            })
        case .GroupListMode:
            AlamofireController.request(.GET, "/groups", parameters: ["category": "map", "day": requestDay!.timeIntervalSince1970], success: { groupData in
                
                if let groups:[GroupEntity] = GroupEntity.collection(groupData) {
                    
                    let annotations = groups.map { group -> GroupAnnotation in
                        let annotation = GroupAnnotation()
                        annotation.group = group
                        if let lat = group.coordinate?.get(0), log = group.coordinate?.get(1) {
                            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: log)
                        }
                        return annotation
                    }
                    self.allAnnotationMapView.addAnnotations(annotations)
                }
                self.adjustRegion()
                self.updateVisibleAnnotations()
                
            })
        case .GroupMode:
            AlamofireController.request(.GET, "/groups/\(self.displayGroup!.id)/posts", parameters: ["category": "map"], success: { postData in
                
                if let posts:[PostEntity] = PostEntity.collection(postData) {
                    
                    let annotations = posts.map { post -> PostAnnotation in
                        let annotation = PostAnnotation()
                        annotation.post = post
                        if let lat = post.coordinate?.get(0), log = post.coordinate?.get(1) {
                            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: log)
                        }
                        return annotation
                    }
                    self.allAnnotationMapView.addAnnotations(annotations)
                }
                self.adjustRegion()
                self.updateVisibleAnnotations()
                
            })
        case .StationListMode:
            AlamofireController.request(.GET, "/stations", parameters: ["category": "mine"], success: { stationData in
                
                if let stations:[StationEntity] = StationEntity.collection(stationData) {
                    
                    let annotations = stations.map { station -> StationAnnotation in
                        let annotation = StationAnnotation()
                        annotation.station = station
                        if let lat = station.coordinate?.get(0), log = station.coordinate?.get(1) {
                            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: log)
                        }
                        return annotation
                    }
                    self.allAnnotationMapView.addAnnotations(annotations)
                }
                self.adjustRegion()
                self.updateVisibleAnnotations()
                
            })
        }
    }
    
    private func updateVisibleAnnotations() {
        
        // This value to controls the number of off screen annotations are displayed.
        // A bigger number means more annotations, less chance of seeing annotation views pop in but decreased performance.
        // A smaller number means fewer annotations, more chance of seeing annotation views pop in but better performance.
        let marginFactor = 0.0;
        
        // Adjust this roughly based on the dimensions of your annotations views.
        // Bigger numbers more aggressively coalesce annotations (fewer annotations displayed but better performance).
        // Numbers too small result in overlapping annotations views and too many annotations on screen.
        let bucketSize = 80.0;
        
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
                    
                    var allAnnotations = Array(allAnnotationsInBucket) as! [AggregatableAnnotation]
                    
                    if let annotationForGrid = annotationInGrid(gridMapRect, usingAnnotations: allAnnotations) as? AggregatableAnnotation {
                        
                        allAnnotations.remove(annotationForGrid)
                
                        // give the annotationForGrid a reference to all the annotations it will represent
                        annotationForGrid.containedAnnotations = allAnnotations
                        
                        mapView.addAnnotation(annotationForGrid)
                        
                        if let view = mapView.viewForAnnotation(annotationForGrid) as? AggregatableAnnotationView {
                            view.setupDisplay()
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
    
    private func adjustRegion() {
        
        let annotations = allAnnotationMapView.annotations
        
        if annotations.count > 0 {
            
            let horizontalSortedAnnotations = annotations.sorted { (obj1, obj2) -> Bool in
                
                let mapPoint1 = MKMapPointForCoordinate((obj1 as! MKAnnotation).coordinate)
                let mapPoint2 = MKMapPointForCoordinate((obj2 as! MKAnnotation).coordinate)
                
                if mapPoint1.x < mapPoint2.x {
                    return true
                } else {
                    return false
                }
            }
            
            let verticalSortedAnnotations = annotations.sorted { (obj1, obj2) -> Bool in
                
                let mapPoint1 = MKMapPointForCoordinate((obj1 as! MKAnnotation).coordinate)
                let mapPoint2 = MKMapPointForCoordinate((obj2 as! MKAnnotation).coordinate)
                
                if mapPoint1.y < mapPoint2.y {
                    return true
                } else {
                    return false
                }
            }
            
            let leftMostAnnotationPoint = MKMapPointForCoordinate((horizontalSortedAnnotations.first as! MKAnnotation).coordinate)
            let rightMostAnnotationPoint = MKMapPointForCoordinate((horizontalSortedAnnotations.last as! MKAnnotation).coordinate)
            let topMostAnnotationPoint = MKMapPointForCoordinate((verticalSortedAnnotations.first as! MKAnnotation).coordinate)
            let bottomMostAnnotationPoint = MKMapPointForCoordinate((verticalSortedAnnotations.last as! MKAnnotation).coordinate)
            
            let targetRect = MKMapRect(origin: MKMapPoint(x: leftMostAnnotationPoint.x, y: topMostAnnotationPoint.y), size: MKMapSize(width: rightMostAnnotationPoint.x - leftMostAnnotationPoint.x, height: bottomMostAnnotationPoint.y - topMostAnnotationPoint.y))
            
            let adjustRect = self.mapView.mapRectThatFits(targetRect, edgePadding: UIEdgeInsets(top: 120, left: 80, bottom: 120, right: 80))
            let adjustRegion = MKCoordinateRegionForMapRect(adjustRect)
            
            self.mapView.setRegion(adjustRegion, animated: true)
            
        } else {
            return
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
