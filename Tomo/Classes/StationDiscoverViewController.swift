//
//  StationDiscoverViewController.swift
//  Tomo
//
//  Created by eagle on 15/9/25.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class StationDiscoverViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var isLoading = false
    var isExhausted = false

    var page = 0

    // String hold the search text
    var searchText: String?

    // Array hold the search result
    var groups = [GroupEntity]()

    // Default loaction use Tokyo
    var location = TomoConst.Geo.CLLocationTokyo

    // Search bar, design it in stroyBoard looks ugly, have to make it by code
    lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.delegate = self
        bar.placeholder = "用车站名检索"
        return bar
    }()

    // CollectionView's footer view, display the indicator and search result
    var footerView: SearchResultReusableView!

    override func viewDidLoad() {

        super.viewDidLoad()

        // attach the search bar on navigation bar
        self.navigationItem.titleView = self.searchBar

        // load initial data with location
        LocationController.shareInstance.doActionWithLocation {
            self.loadInitData(location: $0)
        }
    }

}

// MARK: - Actions

extension StationDiscoverViewController {

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension StationDiscoverViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StationCell", for: indexPath) as! StationCollectionViewCell

        cell.group = self.groups[indexPath.row]

        return cell
    }

    // Make the CollectionView as two-column layout
    func collectionView(_ collectionView: UICollectionView, layout : UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (TomoConst.UI.ScreenWidth - 2.0) / 2.0
        let height = width / 3.0 * 4.0
        return CGSize(width: width, height: height)
    }

    // When cell was tapped, move to group detail
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let groupVC = Util.createViewControllerWithIdentifier(id: "GroupDetailView", storyboardName: "Group") as! GroupDetailViewController
        groupVC.group = groups[indexPath.row]

        self.navigationController?.pushViewController(groupVC, animated: true)
    }

    // Give CollectionView footer view, and hold a reference of it
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        self.footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath) as! SearchResultReusableView
        return self.footerView
    }

}

// MARK: - Internal Methods

extension StationDiscoverViewController {

    fileprivate func loadInitData(location: CLLocation?) {
        
        self.isLoading = true

        var parameters = Router.Group.FindParameters(category: .discover)
        parameters.page = self.page
        parameters.type = .station

        if let location = location {
            parameters.coordinate = [location.coordinate.longitude, location.coordinate.latitude]
            self.location = location
        } else {
            parameters.coordinate = TomoConst.Geo.CoordinateTokyo
        }

        Router.Group.Find(parameters: parameters).response {

            if $0.result.isFailure {
                self.isLoading = false
                return
            }

            if let groups: [GroupEntity] = GroupEntity.collection($0.result.value!) {
                self.groups.append(contentsOf: groups)
                self.appendCells(count: groups.count)
                self.page += 1
            }

            self.isLoading = false
        }
    }
    
    fileprivate func loadMoreData() {

        if self.isLoading || self.isExhausted || self.groups.count == 0 {
            return
        }

        self.isLoading = true
        self.startActivityIndicator()

        var parameters = Router.Group.FindParameters(category: .discover)
        parameters.page = self.page
        parameters.type = .station
        parameters.coordinate = [location.coordinate.longitude, location.coordinate.latitude]
        
        if let searchText = searchText {
            parameters.name = searchText
        }
        
        Router.Group.Find(parameters: parameters).response {

            if $0.result.isFailure {
                self.isLoading = false
                self.isExhausted = true
                self.stopActivityIndicator(withString: "没有更多的结果了")
                return
            }
            
            if let groups: [GroupEntity] = GroupEntity.collection($0.result.value!) {
                self.groups.append(contentsOf: groups)
                self.appendCells(count: groups.count)
                self.page += 1
            }

            self.isLoading = false
        }
    }
    
    fileprivate func startActivityIndicator() {
        self.footerView.activityIndicator.startAnimating()
        self.footerView.searchResultLabel.alpha = 0
    }

    fileprivate func stopActivityIndicator(withString: String?) {
        self.footerView.activityIndicator.stopAnimating()
        self.footerView.searchResultLabel.text = withString
        UIView.animate(withDuration: TomoConst.Duration.Short) {
            self.footerView.searchResultLabel.alpha = 1.0
        }
    }

    fileprivate func appendCells(count: Int) {

        let startIndex = self.groups.count - count
        let endIndex = self.groups.count

        var indexPaths = [IndexPath]()

        for i in startIndex..<endIndex {
            let indexPath = IndexPath(item: i, section: 0)
            indexPaths.append(indexPath)
        }

        self.collectionView.insertItems(at: indexPaths)
    }
}

extension StationDiscoverViewController: UISearchBarDelegate {

    // Search by user input
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        guard let text = searchBar.text, text.trimmed().characters.count > 0 else { return }

        // do nothing if the search word didn't change
        guard self.searchText != text else { return }

        // resign first responder so the keyboard disappear
        searchBar.resignFirstResponder()

        self.isLoading = true

        self.startActivityIndicator()

        // hold the search text
        self.searchText = text

        // reset page number
        self.page = 0

        // reset exhausted flag
        self.isExhausted = false

        // scroll to top for new result, check the zero contents case
        if self.groups.count > 0 {
            let firstItemIndex = IndexPath(item: 0, section: 0)
            self.collectionView.scrollToItem(at: firstItemIndex, at: .top, animated: true)
        }

        // prepare for remove all current cell for new result
        var removeIndex: [IndexPath] = []
        for _ in self.groups {
            removeIndex.append(IndexPath(item: removeIndex.count, section: 0))
        }

        // reset content
        self.groups = [GroupEntity]()
        self.collectionView.deleteItems(at: removeIndex)

        // prepare
        var parameters = Router.Group.FindParameters(category: .discover)
        parameters.name = text
        parameters.type = .station
        parameters.coordinate = [location.coordinate.longitude, location.coordinate.latitude]

        // search
        Router.Group.Find(parameters: parameters).response {

            if $0.result.isFailure {
                self.isLoading = false
                self.isExhausted = true
                self.stopActivityIndicator(withString: "没有找到与“\(self.searchText!)”相关的结果")
                return
            }

            if let groups: [GroupEntity] = GroupEntity.collection($0.result.value!) {
                self.groups = groups
                self.appendCells(count: groups.count)
                self.page += 1
            }

            self.isLoading = false
        }
    }
}

extension StationDiscoverViewController  {

    // Fetch more contents when scroll down to bottom
    func scrollViewDidScroll(scrollView: UIScrollView) {

        let contentHeight = scrollView.contentSize.height
        let offsetY = scrollView.contentOffset.y

        // trigger on the position of one screen height to bottom
        if (contentHeight - TomoConst.UI.ScreenHeight) < offsetY {
            loadMoreData()
        }
    }
}

final class SearchResultReusableView: UICollectionReusableView {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var searchResultLabel: UILabel!

    @IBOutlet weak var emptyResultView: UIView!

    func showActivityIndicator() {
        self.activityIndicator.startAnimating()
        UIView.animate(withDuration: TomoConst.Duration.Short) { _ in
            self.emptyResultView.alpha = 0
        }
    }

    func showSearchResultView() {
        self.activityIndicator.stopAnimating()
        UIView.animate(withDuration: TomoConst.Duration.Short) {
            self.emptyResultView.alpha = 0.0
            self.searchResultLabel.alpha = 1.0
        }
    }

    func showEmptyResultView() {
        self.activityIndicator.stopAnimating()
        UIView.animate(withDuration: TomoConst.Duration.Short) { _ in
            self.emptyResultView.alpha = 1.0
            self.searchResultLabel.alpha = 0.0
        }
    }
}
