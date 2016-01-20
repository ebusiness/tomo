//
//  HomeViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/09.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class HomeViewController: UITableViewController {

    var contents = [AnyObject]()
    var rowHeights = [CGFloat]()

    var latestContent: AnyObject?
    var oldestContent: AnyObject?
    
    var isLoading = false
    var isExhausted = false
    
    var recommendGroups: [GroupEntity]?

    private let footerView: UIView = {

        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        let footerSize = CGSize(width: TomoConst.UI.ScreenWidth, height: TomoConst.UI.TopBarHeight)
        let footerView = UIView(frame: CGRect(origin: CGPointZero, size: footerSize))

        footerView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        footerView.addSubview(indicator)

        indicator.center = footerView.center
        indicator.startAnimating()

        return footerView
    }()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let refreshControl = self.refreshControl {
            refreshControl.tintColor = Palette.LightBlue.lightPrimaryColor
            refreshControl.addTarget(self, action: "loadNewContent", forControlEvents: UIControlEvents.ValueChanged)
        }

        self.tableView.tableFooterView = footerView

        LocationController.shareInstance.doActionWithLocation {
            self.getRecommendInfo($0)
        }

        self.loadMoreContent()
    }
    
//    func becomeActive() {
//        self.loadNewContent()
//    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "postdetail" {
            if let post = sender as? PostEntity {
                let vc = segue.destinationViewController as! PostViewController
                vc.post = post
            }
        }
    }
    
    @IBAction func addedPost(segue: UIStoryboardSegue) {
        // exit addPostView
    }
}

// MARK: UITableView datasource

extension HomeViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let groups = contents[indexPath.item] as? [GroupEntity] {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("StationRecommendCell", forIndexPath: indexPath) as! RecommendStationTableCell
            cell.groups = groups
            cell.delegate = self
            cell.tableViewController = self
            cell.setup()
            return cell
            
        } else if let post = contents[indexPath.row] as? PostEntity {
            
            var cell: TextPostTableViewCell!
            if post.images?.count > 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("ImagePostCell") as! ImagePostTableViewCell
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("TextPostCell") as! TextPostTableViewCell
            }
            cell.post = post
            cell.delegate = self
            return cell
            
        } else {
            return UITableViewCell()
        }
        
    }
}

// MARK: UITableView delegate

extension HomeViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let post = contents[indexPath.row] as? PostEntity {
            self.performSegueWithIdentifier("postdetail", sender: post)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.rowHeights[indexPath.item]
    }

}

// MARK: UIScrollView delegate

extension HomeViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (contentHeight - TomoConst.UI.ScreenHeight) < offsetY {
            loadMoreContent()
        }
    }
}

// MARK: - Actions

extension HomeViewController {

    func discoverMoreStation() {
        performSegueWithIdentifier("modalStationSelector", sender: nil)
    }

    func synchronizeRecommendStations(newStations: [GroupEntity]) {
        for index in 0..<contents.count {
            if let _ = contents[index] as? [GroupEntity] {
                contents[index] = newStations
                break
            }
        }
    }
}

// MARK: Internal methods

extension HomeViewController {

    private func getRecommendInfo(location: CLLocation?) {

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
    
    private func loadMoreContent() {
        
        // skip if already in loading
        if self.isLoading || self.isExhausted {
            return
        }
        
        self.isLoading = true

        var parameters = Router.Post.FindParameters(category: .all)
    
        if let oldestContent = oldestContent as? PostEntity {
            parameters.before = oldestContent.createDate.timeIntervalSince1970
        }
        
        Router.Post.Find(parameters: parameters).response {

            if $0.result.isFailure {
                self.isLoading = false
                self.isExhausted = true
                return
            }
            
            let posts: [PostEntity]? = PostEntity.collection($0.result.value!)
            
            if let loadPosts: [AnyObject] = posts {

                self.contents += loadPosts

                self.rowHeights += loadPosts.map { post -> CGFloat in
                    return self.simulateLayout(post as! PostEntity)
                }

                self.appendRows(loadPosts.count)
                
                let visibleCells = self.tableView.visibleCells
                let visibleIndexPath = self.tableView.indexPathForCell(visibleCells.get(0)!)
                
                if let recommendStations: AnyObject = self.recommendGroups as? AnyObject {

                    let row = visibleIndexPath!.row + 1
                    self.contents.insert(recommendStations, atIndex: Int(row))
                    self.rowHeights.insert(362, atIndex: Int(row))
                    let stationsInsertIndexPath = NSIndexPath(forRow: row, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([stationsInsertIndexPath], withRowAnimation: .Fade)
                    self.recommendGroups = nil
                }

            }

            self.isLoading = false
        }
    }
    
    func loadNewContent() {

        var parameters = Router.Post.FindParameters(category: .all)
        
        if let latestContent = latestContent as? PostEntity {
            // TODO - This is a dirty solution
            parameters.after = latestContent.createDate.timeIntervalSince1970 + 1
        }
        
        Router.Post.Find(parameters: parameters).response {
            if $0.result.isFailure {
                self.refreshControl!.endRefreshing()
                return
            }
            
            if let loadPosts:[PostEntity] = PostEntity.collection($0.result.value!) {
                self.contents = loadPosts + self.contents
                self.prependRows(loadPosts.count)
            }
            
            self.refreshControl!.endRefreshing()

        }
    }
    
    private func appendRows(rows: Int) {
        
        let firstIndex = contents.count - rows
        let lastIndex = contents.count
        
        var indexPathes = [NSIndexPath]()
        
        for index in firstIndex..<lastIndex {
            indexPathes.push(NSIndexPath(forRow: index, inSection: 0))
        }
        
        // hold the oldest content for pull-up loading
        oldestContent = contents.last
        
        // hold the latest content for pull-down loading
        if firstIndex == 0 {
            latestContent = contents.first
        }
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPathes, withRowAnimation: .Fade)
        tableView.endUpdates()
        
    }
    
    private func prependRows(rows: Int) {
        
        var indexPathes = [NSIndexPath]()
        
        for index in 0..<rows {
            indexPathes.push(NSIndexPath(forRow: index, inSection: 0))
        }
        
        // hold the latest content for pull-up loading
        latestContent = contents.first
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths(indexPathes, withRowAnimation: .Fade)
        tableView.endUpdates()
    }
    
    func simulateLayout(post: PostEntity) -> CGFloat {

        let cell: TextPostTableViewCell

        if post.images?.count > 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("ImagePostCell") as! ImagePostTableViewCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("TextPostCell") as! TextPostTableViewCell
        }

        cell.post = post
        cell.configDisplay()

        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)

        return size.height
    }

}
