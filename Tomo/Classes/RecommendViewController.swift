//
//  RecommendViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/10/26.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class RecommendViewController: UIViewController {

    @IBOutlet weak var recommendGroupCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    fileprivate var currentAnnotationView: MKAnnotationView?
    fileprivate var currentSelectedIndexPath: IndexPath?
    
    var exitAction: (()->())?

    fileprivate let itemSize: CGSize = {
        let height = UIScreen.main.bounds.height * 0.3 - 8
        let width = height / 4 * 3
        return CGSize(width: width, height: height)
    }()

    fileprivate var recommendGroups: [GroupEntity]? {
        didSet {

            let firstItemIndex = IndexPath(row: 0, section: 0)
            var removeIndex: [IndexPath] = []
            var insertIndex: [IndexPath] = []

            if let oldValue = oldValue {
                for _ in oldValue {
                    removeIndex.append(IndexPath(row: removeIndex.count, section: 0))
                }
            }
            if let primaryStation = me.primaryStation {
                self.recommendGroups?.insert(primaryStation, at: 0)
            }
            if let newValue = self.recommendGroups {
                for _ in newValue {
                    insertIndex.append(IndexPath(row: insertIndex.count, section: 0))
                }
            }

            self.recommendGroupCollectionView.performBatchUpdates({
                self.recommendGroupCollectionView.deleteItems(at: removeIndex)
                self.recommendGroupCollectionView.insertItems(at: insertIndex)
            }) { _ in
                self.recommendGroupCollectionView.scrollToItem(at: firstItemIndex, at: .left, animated: true)
            }
        }
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        
        if let primaryStation = me.primaryStation {
            self.maskView.alpha = 0
            self.selectGroup(group: primaryStation)
        }
        LocationController.shareInstance.doActionWithLocation {
            self.getRecommendInfo(location: $0)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - interal methodes

extension RecommendViewController {

    fileprivate func getRecommendInfo(location: CLLocation?) {

        var parameters = Router.Group.FindParameters(category: .discover)
        parameters.type = .station

        if let location = location {
            parameters.coordinate = [location.coordinate.longitude, location.coordinate.latitude]
        } else {
            parameters.coordinate = TomoConst.Geo.CoordinateTokyo
        }

        self.activityIndicator.startAnimating()

        Router.Group.Find(parameters: parameters).response {

            self.activityIndicator.stopAnimating()

            if $0.result.isFailure { return }
            self.recommendGroups = GroupEntity.collection(json: $0.result.value!)
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

            Defaults.remove(key: "openid")
            Defaults.remove(key: "deviceToken")

            Defaults.remove(key: "email")
            Defaults.remove(key: "password")

            me = nil
            let main = Util.createViewControllerWithIdentifier(id: nil, storyboardName: "Main")
            Util.changeRootViewController(from: self, to: main)

        }
    }
}

// MARK: - UICollectionViewDataSource

extension RecommendViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recommendGroups?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath as IndexPath) as! GroupRecommendCollectionViewCell
        
        let group = self.recommendGroups![indexPath.item]
        
        cell.coverImageView.sd_setImage(with:NSURL(string: group.cover) as URL!, placeholderImage: TomoConst.Image.DefaultGroup)
        cell.nameLabel.text = group.name
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension RecommendViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard self.currentSelectedIndexPath != indexPath else { return }
        guard let group = recommendGroups?[indexPath.row] else { return }

        self.currentSelectedIndexPath = indexPath
        
        if let presentedViewController = self.presentedViewController {
            presentedViewController.dismiss(animated: true, completion: nil)
        }

        self.selectGroup(group: group)
        
        guard self.maskView.alpha > 0 else { return }
        
        UIView.animate(withDuration: TomoConst.Duration.Short, animations: {
            self.maskView.alpha = 0
        })
    }

    fileprivate func selectGroup(group: GroupEntity) {
        guard let latitude = group.coordinate?[1] else { return }
        guard let longitude = group.coordinate?[0] else { return }

        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        let unit = MKMetersPerMapPointAtLatitude(latitude)

        let point = MKMapPointForCoordinate(coordinate)
        let origin = MKMapPoint(x: point.x - 1500/unit, y: point.y - 2100/unit)
        let rect = MKMapRect(origin: origin, size: MKMapSize(width: 3000/unit, height: 3000/unit))

        self.mapView.setVisibleMapRect(rect, animated: true)

        let annotation = GroupAnnotation()
        annotation.group = group
        annotation.coordinate = coordinate

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

        var stationAnnotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: "identifier")

        if stationAnnotationView == nil {
            stationAnnotationView = StationAnnotationView(annotation: annotation, reuseIdentifier: "identifier")
        } else {
            stationAnnotationView?.annotation = annotation
        }

        (stationAnnotationView as! StationAnnotationView).setupDisplay()

        self.currentAnnotationView = stationAnnotationView

        return stationAnnotationView
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

        guard let annotationView = self.currentAnnotationView else { return }
        
        let vc = Util.createViewControllerWithIdentifier(id: "GroupPopoverViewController", storyboardName: "Main") as! GroupPopoverViewController
        
        vc.modalPresentationStyle = .popover
        vc.presentationController?.delegate = self
        
        vc.groupAnnotation = annotationView.annotation as! GroupAnnotation

        self.present(vc, animated: true, completion: nil)
        
        if let pop = vc.popoverPresentationController {
            pop.passthroughViews = [self.view]
            pop.permittedArrowDirections = .down
            pop.sourceView = annotationView
            pop.sourceRect = annotationView.bounds
        }

    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.mapView(mapView, regionDidChangeAnimated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RecommendViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
}

// MARK: - UISearchBarDelegate

extension RecommendViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        self.hideSearchBar()

        guard let text = searchBar.text, text.characters.count > 0 else { return }

        LocationController.shareInstance.doActionWithLocation {
            self.currentSelectedIndexPath = nil
            self.searchGroupWith(keyword: text, location: $0)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        self.hideSearchBar()

        guard let text = searchBar.text, text.characters.count == 0 else { return }

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
            parameters.coordinate = [location.coordinate.longitude, location.coordinate.latitude]
        } else {
            parameters.coordinate = TomoConst.Geo.CoordinateTokyo
        }

        self.activityIndicator.startAnimating()

        Router.Group.Find(parameters: parameters).response {

            self.activityIndicator.stopAnimating()

            guard $0.result.isSuccess else {
                let alert = UIAlertController(title: "没有找到相关的结果", message: "请试着用其他关键字检索一下吧", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.recommendGroups = GroupEntity.collection(json: $0.result.value!)
        }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension RecommendViewController: UIAdaptivePresentationControllerDelegate {
    @nonobjc func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - GroupRecommendCollectionViewCell

final class GroupRecommendCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var coverImageView: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 5
        self.contentView.clipsToBounds = true
    }

}

// MARK: - GroupPopoverViewController

final class GroupPopoverViewController: UIViewController {

    var groupAnnotation: GroupAnnotation! {
        didSet {
            if self.isViewLoaded {
                self.setupDisplay()
            }
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var joinButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDisplay()
    }

    @IBAction func joinButtonTapped(_ sender: Any) {
        
        guard let delegate = UIApplication.shared.delegate else { return }
        guard let window = delegate.window else { return }
        guard let rootViewController = window?.rootViewController else { return }

        Router.Group.Join(id: groupAnnotation.group.id).response {

            guard $0.result.isSuccess else { return }
            me.primaryStation = self.groupAnnotation.group

            var param = Router.Setting.MeParameter()
            param.primaryStation = self.groupAnnotation.group.id

            Router.Setting.UpdateUserInfo(parameters: param).response {

                guard $0.result.isSuccess else { return }
                
                if let rvc = self.presentationController?.delegate as? RecommendViewController
                    ,let exitAction = rvc.exitAction {
                        me.primaryStation = self.groupAnnotation.group
                        self.dismiss(animated: true) { _ in
                            exitAction()
                        }
                        return
                }

                Util.changeRootViewController(from: rootViewController, to: TabBarController())
            }
        }
    }
    
    private func setupDisplay() {
        
        self.joinButton.layer.borderColor = UIColor.white.cgColor
        self.joinButton.layer.borderWidth = 1
        self.joinButton.layer.cornerRadius = 2
        
        guard let group = groupAnnotation.group else { return }
        self.nameLabel.text = group.name
        self.introLabel.text = group.introduction
        self.coverImageView.sd_setImage(with: URL(string: group.cover), placeholderImage: TomoConst.Image.DefaultGroup, options: .retryFailed)
        
        guard let me = me else { return }
        
        if group.id == me.primaryStation?.id {
            self.joinButton.isHidden = true
        } else {
            self.joinButton.isHidden = false
            self.joinButton.setTitle("设置为当前现场", for: .normal)
        }
    }
}
