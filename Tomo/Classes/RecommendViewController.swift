//
//  RecommendViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/10/26.
//  Copyright © 2015 e-business. All rights reserved.
//

import UIKit

final class RecommendViewController: UIViewController {

    @IBOutlet weak fileprivate var recommendGroupCollectionView: UICollectionView!
    @IBOutlet weak fileprivate var mapView: MKMapView!
    @IBOutlet weak fileprivate var maskView: UIView!
    @IBOutlet weak fileprivate var searchBar: UISearchBar!
    @IBOutlet weak fileprivate var searchBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var activityIndicator: UIActivityIndicatorView!

    fileprivate var currentAnnotationView: MKAnnotationView?
    fileprivate var currentSelectedIndexPath: IndexPath?

    var exitAction: (() -> Void)?

    fileprivate let itemSize: CGSize = {
        let height = UIScreen.main.bounds.height * 0.3 - 8
        let width = height / 4 * 3
        return CGSize(width: width, height: height)
    }()

    fileprivate var recommendGroups: [GroupEntity]? {
        didSet {
//
//            let firstItemIndex = IndexPath(row: 0, section: 0)
//            var removeIndex: [IndexPath] = []
//            var insertIndex: [IndexPath] = []
//
//            oldValue?.forEach { _ in
//                removeIndex.append(IndexPath(row: removeIndex.count, section: 0))
//            }
//
//            if self.recommendGroups == nil { self.recommendGroups = [] }
//
//            if let primaryGroup = me.primaryGroup {
//                self.recommendGroups = self.recommendGroups?.filter { $0.id != primaryGroup.id }
//                self.recommendGroups?.insert(primaryGroup, at: 0)
//            }
//            self.recommendGroups?.forEach { _ in
//                insertIndex.append(IndexPath(row: insertIndex.count, section: 0))
//            }
//
//            self.recommendGroupCollectionView.performBatchUpdates({
//                self.recommendGroupCollectionView.deleteItems(at: removeIndex)
//                self.recommendGroupCollectionView.insertItems(at: insertIndex)
//            }) { _ in
//                self.recommendGroupCollectionView.scrollToItem(at: firstItemIndex, at: .left, animated: true)
//            }
        }
    }

    override func viewDidLoad() {

        super.viewDidLoad()

//        if let primaryGroup = me.primaryGroup {
//            self.maskView.alpha = 0
//            self.selectGroup(group: primaryGroup)
//        }
//        LocationController.shareInstance.doActionWithLocation {
//            self.getRecommendInfo(location: $0)
//        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - interal methodes

extension RecommendViewController {

    fileprivate func getRecommendInfo(location: CLLocation?) {

        var parameters = Router.Group.FindParameters(category: .all)
        parameters.type = .station

        if let location = location {
            parameters.coordinate = [location.coordinate.latitude, location.coordinate.longitude]
        } else {
            parameters.coordinate = TomoConst.Geo.Tokyo.Coordinate
        }

        self.activityIndicator.startAnimating()

        Router.Group.find(parameters: parameters).response {

            self.activityIndicator.stopAnimating()

            if $0.result.isFailure { return }
            self.recommendGroups = GroupEntity.collection($0.result.value!)
        }
    }

    @IBAction func searchButtonTapped(_ sender: Any) {

        if let presentedViewController = self.presentedViewController {
            presentedViewController.dismiss(animated: true, completion: nil)
        }

        UIView.animate(withDuration: TomoConst.Duration.Short, animations: {
            self.searchBarBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
            }) { _ in
                self.searchBar.becomeFirstResponder()
        }
    }

    @IBAction func exitButtonTapped(_ sender: Any) {
        if let exitAction = exitAction {
            exitAction()
            return
        }
        Router.Signout().response { _ in

            UserDefaults.standard.removeObject(forKey: "deviceToken")

            UserDefaults.standard.removeObject(forKey: "email")
            UserDefaults.standard.removeObject(forKey: "password")

            me = nil
            let main = Util.createViewController(storyboardName: "Main", id: nil)
            Util.changeRootViewController(from: self, to: main)

        }
    }
}

// MARK: - UICollectionViewDataSource

extension RecommendViewController: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recommendGroups?.count ?? 0
    }

    // swiftlint:disable:next line_length
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let defaultCell = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath)

        guard let cell = defaultCell as? GroupRecommendCollectionViewCell else { return defaultCell }

        cell.group = self.recommendGroups![indexPath.item]

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension RecommendViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard self.currentSelectedIndexPath != indexPath else { return }
        guard let group = recommendGroups?[indexPath.row] else { return }

        self.currentSelectedIndexPath = indexPath

        self.selectGroup(group: group)

        guard self.maskView.alpha > 0 else { return }

        UIView.animate(withDuration: TomoConst.Duration.Short, animations: {
            self.maskView.alpha = 0
        })
    }

    fileprivate func selectGroup(group: GroupEntity) {
        let annotation = GroupAnnotation()
        annotation.group = group

        if let presentedViewController = self.presentedViewController as? GroupPopoverViewController {
            presentedViewController.groupAnnotation = annotation
        }

        let unit = MKMetersPerMapPointAtLatitude(annotation.coordinate.latitude)

        let point = MKMapPointForCoordinate(annotation.coordinate)
        let origin = MKMapPoint(x: point.x - 1500 / unit, y: point.y - 2100 / unit)
        let rect = MKMapRect(origin: origin, size: MKMapSize(width: 3000 / unit, height: 3000 / unit))

        self.mapView.setVisibleMapRect(rect, animated: true)

        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
    }
}

// MARK: - MKMapViewDelegate

extension RecommendViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard let annotation = annotation as? GroupAnnotation else {
            return nil
        }

        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "identifier")

        if let annotationView = annotationView as? AggregatableAnnotationView {
            annotationView.annotation = annotation
            annotationView.setupDisplay()
        } else {
            annotationView = AggregatableAnnotationView(annotation: annotation, reuseIdentifier: "identifier")
        }

        self.currentAnnotationView = annotationView

        return annotationView
    }
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if let presentedViewController = self.presentedViewController {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

        guard let annotationView = self.currentAnnotationView else { return }

        let vc = Util.createViewController(storyboardName: "Main", id: "GroupPopoverViewController") as? GroupPopoverViewController

        vc?.modalPresentationStyle = .popover
        vc?.popoverPresentationController!.delegate = self
        vc?.groupAnnotation = annotationView.annotation as? GroupAnnotation
//        vc?.preferredContentSize = CGSize(width: 300, height: 200)

        self.present(vc!, animated: true, completion: nil)

        if let pop = vc?.popoverPresentationController {
            pop.passthroughViews = [self.view]
            pop.permittedArrowDirections = .down
            pop.sourceView = annotationView
            pop.sourceRect = annotationView.bounds
        }

    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let _ = self.presentedViewController {
            return
        }
        self.mapView(mapView, regionDidChangeAnimated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RecommendViewController: UICollectionViewDelegateFlowLayout {
    // swiftlint:disable:next line_length
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
}

// MARK: - UISearchBarDelegate

extension RecommendViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        self.hideSearchBar()

        guard let text = searchBar.text, !text.isEmpty else { return }

        LocationController.shareInstance.doActionWithLocation {
            self.currentSelectedIndexPath = nil
            self.searchGroupWith(keyword: text, location: $0)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        self.hideSearchBar()

        guard let text = searchBar.text, text.isEmpty else { return }

        LocationController.shareInstance.doActionWithLocation {
            self.currentSelectedIndexPath = nil
            self.getRecommendInfo(location: $0)
        }
    }

    private func hideSearchBar() {

        self.searchBar.resignFirstResponder()

        UIView.animate(withDuration: TomoConst.Duration.Short, animations: {
            self.searchBarBottomConstraint.constant = -TomoConst.UI.NavigationBarHeight
            self.view.layoutIfNeeded()
        })
    }

    private func searchGroupWith(keyword: String, location: CLLocation?) {

        var parameters = Router.Group.FindParameters(category: .discover)
        parameters.type = .station
        parameters.name = keyword

        if let location = location {
            parameters.coordinate = [location.coordinate.latitude, location.coordinate.longitude]
        } else {
            parameters.coordinate = TomoConst.Geo.Tokyo.Coordinate
        }

        self.activityIndicator.startAnimating()

        Router.Group.find(parameters: parameters).response {

            self.activityIndicator.stopAnimating()

            guard $0.result.isSuccess else {
                let alert = UIAlertController(title: "没有找到相关的结果", message: "请试着用其他关键字检索一下吧", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.recommendGroups = GroupEntity.collection($0.result.value!)
        }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension RecommendViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
}
