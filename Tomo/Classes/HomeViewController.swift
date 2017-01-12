//
//  HomeViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/09.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class HomeViewController: UITableViewController {

    // Array holds all cell contents
    var contents = [Any]()

    // Array holds all cell heights
    var rowHeights = [CGFloat]()

    var latestContent: Any?
    var oldestContent: Any?
    
    var isLoading = false
    var isExhausted = false
    
    var recommendGroups: [GroupEntity]?

    // Table footer view, with a loading activity indicator.
    // If set in the storyboard, table scroll will bacome very slow. don't know why.
    private let footerView: UIView = {

        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        let footerSize = CGSize(width: TomoConst.UI.ScreenWidth, height: TomoConst.UI.TopBarHeight)
        let footerView = UIView(frame: CGRect(origin: CGPoint.zero, size: footerSize))

        footerView.backgroundColor = UIColor.groupTableViewBackground
        footerView.addSubview(indicator)

        indicator.center = footerView.center
        indicator.startAnimating()

        return footerView
    }()

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Wire refresh control with loadNewContent method.
        self.refreshControl?.addTarget(self, action: #selector(HomeViewController.loadNewContent), for: UIControlEvents.valueChanged)

        // Set table view's footer.
        self.tableView.tableFooterView = footerView

        // Load recommend contents, with user location.
        LocationController.shareInstance.doActionWithLocation {
            self.getRecommendContent(location: $0)
        }

        // Load main contents
        self.loadMoreContent()
    }
}

// MARK: - Navigation

extension HomeViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postdetail" {
            if let post = sender as? PostEntity {
                let vc = segue.destination as! PostDetailViewController
                vc.post = post
            }
        }
    }

    // unwind segue implimentation
    @IBAction func didCreatePost(_ segue: UIStoryboardSegue) {
        self.loadNewContent()
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}

// MARK: - UITableView datasource

extension HomeViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // If the content is array of group, display as StationGroup recommendation.
        if let groups = contents[indexPath.item] as? [GroupEntity] {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "StationRecommendCell", for: indexPath) as! RecommendStationTableViewCell

            // Give the cell group list data, this will tirgger configDisplay
            cell.groups = groups

            // Set current navigation controller as the cell's delegate, 
            // for the navigation when post author's photo been tapped, etc.
            cell.delegate = self.navigationController

            return cell

        // If the content is a post, display as post summary.
        } else if let post = contents[indexPath.row] as? PostEntity {
            
            var cell: TextPostTableViewCell!

            // If the post has one or more images, use ImagePostTableViewCell, otherwise use the TextPostTableViewCell.
            if (post.images?.count)! > 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "ImagePostCell") as! ImagePostTableViewCell
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "TextPostCell") as! TextPostTableViewCell
            }

            // Give the cell post data, this will tirgger configDisplay
            cell.post = post

            // Set current navigation controller as the cell's delegate, 
            // for the navigation when post author's photo been tapped, etc.
            cell.delegate = self.navigationController

            return cell
            
        } else {
            return UITableViewCell()
        }
        
    }
}

// MARK: - UITableView delegate

extension HomeViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let post = contents[indexPath.row] as? PostEntity {
            self.performSegue(withIdentifier: "postdetail", sender: post)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath)  -> CGFloat {
        return self.rowHeights[indexPath.item]
    }

}

// MARK: - UIScrollView delegate

extension HomeViewController {

    // Fetch more contents when scroll down to bottom
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        // trigger on the position of one screen height to bottom
        if (contentHeight - TomoConst.UI.ScreenHeight) < offsetY {
            self.loadMoreContent()
        }
    }
}

// MARK: - Internal methods

extension HomeViewController {

    // Fetch recommend content with location. use Tokyo as default if no location provided.
    fileprivate func getRecommendContent(location: CLLocation?) {

        var parameters = Router.Group.FindParameters(category: .discover)
        parameters.type = .station

        if let location = location {
            parameters.coordinate = [location.coordinate.longitude, location.coordinate.latitude]
        } else {
            parameters.coordinate = TomoConst.Geo.CoordinateTokyo
        }
 
        Router.Group.Find(parameters: parameters).response {
            if $0.result.isFailure { return }
            self.recommendGroups = GroupEntity.collection($0.result.value!)
        }
    }

    // Fetch more content as use scroll down to the bottom of table view.
    fileprivate func loadMoreContent() {
        
        // skip if already in loading or no more contents
        if self.isLoading || self.isExhausted {
            return
        }
        
        self.isLoading = true

        var parameters = Router.Post.FindParameters(category: .all)
    
        if let oldestContent = oldestContent as? PostEntity {
            parameters.before = oldestContent.createDate.timeIntervalSince1970
        }
        
        Router.Post.Find(parameters: parameters).response {

            // Mark as exhausted when something wrong (probably 404)
            if $0.result.isFailure {
                self.isLoading = false
                self.isExhausted = true
                self.tableView.tableFooterView = nil
                return
            }
            
            let posts: [PostEntity]? = PostEntity.collection($0.result.value!)
            
            if let loadPosts: [Any] = posts {

                // total number of rows will be append to table view
                var rowNumber = loadPosts.count

                // append new contents
                self.contents += loadPosts

                // calculate the cell height for display these contents
                self.rowHeights += loadPosts.map { self.simulateLayout(post: $0 as! PostEntity) }

                // if the recommend contents arrived, insert them in the middle of new content
                if let recommendStations = self.recommendGroups {

                    var insertAt: Int

                    if let lastVisibleCell = self.tableView.visibleCells.last {
                        insertAt = self.tableView.indexPath(for: lastVisibleCell)!.row + 2
                    } else {
                        insertAt = 3
                    }

                    self.contents.insert(recommendStations, at: insertAt)
                    self.rowHeights.insert(362, at: insertAt)

                    self.recommendGroups = nil
                    rowNumber+=1
                }

                // let table view display new contents
                self.appendRows(rows: rowNumber)
            }

            self.isLoading = false
        }
    }

    // Fetch new contents as user drag down the table view while it already on the top.
    func loadNewContent() {

        var parameters = Router.Post.FindParameters(category: .all)
        
        if let latestContent = latestContent as? PostEntity {
            // TODO - This is a dirty solution
            parameters.after = latestContent.createDate.timeIntervalSince1970 + 1
        }
        
        Router.Post.Find(parameters: parameters).response {

            // stop refresh control
            self.refreshControl!.endRefreshing()

            if $0.result.isFailure {
                return
            }

            // prepend new contents
            if let loadPosts:[PostEntity] = PostEntity.collection($0.result.value!) {
                self.contents = loadPosts + self.contents
                self.rowHeights = loadPosts.map { self.simulateLayout(post: $0) } + self.rowHeights
                self.prependRows(rows: loadPosts.count)
            }
        }
    }

    // Append specific number of rows on table view
    private func appendRows(rows: Int) {
        
        let firstIndex = contents.count - rows
        let lastIndex = contents.count
        
        var indexPathes = [IndexPath]()
        
        for index in firstIndex..<lastIndex {
            indexPathes.append(IndexPath(row: index, section: 0))
        }
        
        // hold the oldest content for pull-up loading
        self.oldestContent = self.contents.last
        
        // hold the latest content for pull-down loading
        if firstIndex == 0 {
            self.latestContent = self.contents.first
        }
        
        tableView.beginUpdates()
        tableView.insertRows(at: indexPathes, with: .fade)
        tableView.endUpdates()
    }

    // Prepend specific number of rows on table view
    private func prependRows(rows: Int) {
        
        var indexPathes = [IndexPath]()
        
        for index in 0..<rows {
            indexPathes.append(IndexPath(row: index, section: 0))
        }
        
        // hold the latest content for pull-up loading
        self.latestContent = self.contents.first
        
        tableView.beginUpdates()
        tableView.insertRows(at: indexPathes, with: .fade)
        tableView.endUpdates()
    }

    // Calulate the cell height beforehand
    private func simulateLayout(post: PostEntity) -> CGFloat {

        let cell: TextPostTableViewCell

        if (post.images?.count)! > 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ImagePostCell") as! ImagePostTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "TextPostCell") as! TextPostTableViewCell
        }

        cell.post = post

        let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)

        return size.height
    }

}
