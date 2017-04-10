//
//  MKMapView+UpdateAggregatebleAnnotations.swift
//  Tomo
//
//  Created by 李超逸 on 2017/4/7.
//  Copyright © 2017年  e-business. All rights reserved.
//

import Foundation

extension MKMapView {
    // swiftlint:disable:next function_body_length
    func updateVisibleAnnotations(candidateAnnotations: [AggregatableAnnotation]) {

        // This value to controls the number of off screen annotations are displayed.
        // A bigger number means more annotations,
        // less chance of seeing annotation views pop in but decreased performance.
        // A smaller number means fewer annotations,
        // more chance of seeing annotation views pop in but better performance.
        let marginFactor = 1.0

        // Adjust this roughly based on the dimensions of your annotations views.
        // Bigger numbers more aggressively coalesce annotations (fewer annotations displayed but better performance).
        // Numbers too small result in overlapping annotations views and too many annotations on screen.
        let bucketSize = 120.0

        // find all the annotations in the visible area 
        // + a wide margin to avoid popping annotation views in and out while panning the map.
        let adjustedVisibleMapRect = MKMapRectInset(visibleMapRect,
                                                    -marginFactor * visibleMapRect.size.width,
                                                    -marginFactor * visibleMapRect.size.height)

        // determine how wide each bucket will be, as a MKMapRect square
        let leftCoordinate = convert(CGPoint.zero, toCoordinateFrom: self)
        let rightCoordinate = convert(CGPoint(x: CGFloat(bucketSize), y: CGFloat(0.0)), toCoordinateFrom: self)

        // determine how wide each bucket will be, as a MKMapRect square
        let gridSize = MKMapPointForCoordinate(rightCoordinate).x - MKMapPointForCoordinate(leftCoordinate).x
        var gridMapRect = MKMapRectMake(0, 0, gridSize, gridSize)

        // condense annotations, with a padding of two squares, around the visibleMapRect
        let startX = floor(MKMapRectGetMinX(adjustedVisibleMapRect) / gridSize) * gridSize
        let startY = floor(MKMapRectGetMinY(adjustedVisibleMapRect) / gridSize) * gridSize
        let endX = floor(MKMapRectGetMaxX(adjustedVisibleMapRect) / gridSize) * gridSize
        let endY = floor(MKMapRectGetMaxY(adjustedVisibleMapRect) / gridSize) * gridSize

        // create all squares
        var squares = [AnnotationSquare]()
        gridMapRect.origin.y = startY
        while MKMapRectGetMinY(gridMapRect) <= endY {

            gridMapRect.origin.x = startX
            while MKMapRectGetMinX(gridMapRect) <= endX {
                squares.append(AnnotationSquare(gridMapRect))
                gridMapRect.origin.x += gridSize
            }
            gridMapRect.origin.y += gridSize
        }

        // put annotation into the proper square
        for annotation in candidateAnnotations {
            for idx in 0..<squares.count {
                if squares[idx].containsCoordinate(annotation.coordinate) {
                    squares[idx].annotations.append(annotation)
                    break
                }
            }
        }

        // show no more than one point in a single square
        for square in squares {
            guard let alreadyShown = annotations(in: square.rect) as? Set<AggregatableAnnotation> else {
                return
            }

            if let pointAnnotation = square.pointAnnotation(alreadyShown: alreadyShown) {

                let containedAnnotations = square.annotations.filter { $0 != pointAnnotation }

                // give the annotationForGrid a reference to all the annotations it will represent
                pointAnnotation.containedAnnotations = containedAnnotations

                addAnnotation(pointAnnotation)
                animateForExpand(annotation: pointAnnotation)

                for annotation in containedAnnotations {
                    animateForCollapse(annotation: annotation,
                                       cluster: pointAnnotation,
                                       alreadyShown: alreadyShown)
                }
            }
        }

        removeOutsideAnnotations()
    }

    fileprivate func animateForExpand(annotation: AggregatableAnnotation) {
        guard let clusterAnnotation = annotation.clusterAnnotation else { return }

        // animate the annotation from it's old container's coordinate, to its actual coordinate
        let actualCoordinate = annotation.coordinate
        let containerCoordinate = clusterAnnotation.coordinate

        // since it's displayed on the map, it is no longer contained by another annotation,
        // (We couldn't reset this in -updateVisibleAnnotations because we needed the reference to it here
        // to get the containerCoordinate)
        annotation.clusterAnnotation = nil

        annotation.coordinate = containerCoordinate

        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            annotation.coordinate = actualCoordinate
        })
    }

    fileprivate func animateForCollapse(annotation: AggregatableAnnotation,
                                        cluster: AggregatableAnnotation,
                                        alreadyShown: Set<AggregatableAnnotation>) {
        // give all the other annotations a reference to the one which is representing them
        annotation.clusterAnnotation = cluster
        annotation.containedAnnotations.removeAll()

        // remove annotations which we've decided to cluster
        if alreadyShown.contains(annotation) {

            let actualCoordinate = annotation.coordinate

            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                annotation.coordinate = annotation.clusterAnnotation!.coordinate
            }, completion: { [unowned self, annotation, actualCoordinate](_) -> Void in
                annotation.coordinate = actualCoordinate
                self.removeAnnotation(annotation)
            })

        }
    }

    fileprivate func removeOutsideAnnotations() {

        let allAnnotations = annotations as? [AggregatableAnnotation]
        let insideAnnotations = annotations(in: visibleMapRect) as? Set<AggregatableAnnotation>

        let _outsideAnnotations = allAnnotations?.filter { annotation -> Bool in
            if insideAnnotations?.contains(annotation) == false {
                return true
            } else {
                return false
            }
        }

        if let outsideAnnotations = _outsideAnnotations {
            // clear relations
            outsideAnnotations.forEach { outsideAnnotation in
                outsideAnnotation.clusterAnnotation = nil
                outsideAnnotation.containedAnnotations.forEach { child in
                    if child.clusterAnnotation == outsideAnnotation {
                        child.clusterAnnotation = nil
                    }

                }
                outsideAnnotation.containedAnnotations.removeAll()
            }
            // remove from map
            removeAnnotations(outsideAnnotations)
        }
    }
}

struct AnnotationSquare {
    let rect: MKMapRect
    var annotations = [AggregatableAnnotation]()
    init(_ rect: MKMapRect) {
        self.rect = rect
    }

    func containsCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let mapPoint = MKMapPointForCoordinate(coordinate)
        return MKMapRectContainsPoint(rect, mapPoint)
    }

    func pointAnnotation(alreadyShown: Set<AggregatableAnnotation>) -> AggregatableAnnotation? {
        // first, see if one of the annotations we were already showing is in this mapRect
        for annotation in annotations {
            if alreadyShown.contains(annotation) {
                return annotation
            }
        }

        // otherwise, sort the annotations based on their distance from the center of the grid square,
        // then choose the one closest to the center to show
        let centerMapPoint = MKMapPoint(x: MKMapRectGetMidX(rect), y: MKMapRectGetMidY(rect))
        let sortedAnnotations = annotations.sorted { (obj1, obj2) -> Bool in

            let mapPoint1 = MKMapPointForCoordinate(obj1.coordinate)
            let mapPoint2 = MKMapPointForCoordinate(obj2.coordinate)

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
