//
//  HomeViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/09.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class HomeViewController: UITableViewController {

    let screenHeight = UIScreen.mainScreen().bounds.height
    let loadTriggerHeight = CGFloat(88.0)
    
    var contents = [AnyObject]()
    var latestContent: AnyObject?
    var oldestContent: AnyObject?
    
    var isLoading = false
    var isExhausted = false
    
    var recommendGroups: [GroupEntity]?
    
    var postCellEstimator: ICYPostCell!
    var postImageCellEstimator: ICYPostImageCell!
    
    private let footerView: UIView = {
        let screenWidth = UIScreen.mainScreen().bounds.width
        let footerView = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: screenWidth, height: 40.0)))
        footerView.backgroundColor = Util.colorWithHexString("EFEFF4")
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        footerView.addSubview(loadingIndicator)
        loadingIndicator.sizeToFit()
        loadingIndicator.startAnimating()
        loadingIndicator.center = CGPoint(x: screenWidth / 2.0, y: 20.0)
        return footerView
    }()
    
    /// true: comment, false: cell content
//    private var selectCellOrComment = false

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.registerCell()
        
        self.setupRefreshControll()

        LocationController.shareInstance.doActionWithLocation {
            self.getRecommendInfo($0)
        }

        self.tableView.estimatedRowHeight = 300
        
        self.loadMoreContent()
    }
    
    func becomeActive() {
        self.loadNewContent()
    }

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
            
            let cell = tableView.dequeueReusableCellWithIdentifier("RecommendStationTableCell", forIndexPath: indexPath) as! RecommendStationTableCell
            cell.groups = groups
            cell.delegate = self
            cell.tableViewController = self
            cell.setup()
            return cell
            
        } else if let post = contents[indexPath.row] as? PostEntity {
            var cell: TextPostCell!
            if post.images?.count > 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("ImagePostCell") as! ImagePostCell
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("TextPostCell") as! TextPostCell
            }
            cell.post = post
//            cell.delegate = self
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
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if contents[indexPath.row] is [GroupEntity] {
//            return 330.0
//        }
//        guard let post = contents[indexPath.row] as? PostEntity else { return 0 }
//        
//        if post.contentHeight == nil {
//            if post.images?.count > 0 {
//                if postImageCellEstimator == nil {
//                    postImageCellEstimator = tableView.dequeueReusableCellWithIdentifier("ICYPostImageCellIdentifier") as! ICYPostImageCell
//                }
//                postImageCellEstimator.post = post
//                let size = postImageCellEstimator.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
//                post.contentHeight = size.height
//            } else {
//                if postCellEstimator == nil {
//                    postCellEstimator = tableView.dequeueReusableCellWithIdentifier("ICYPostCellIdentifier") as! ICYPostCell
//                }
//                postCellEstimator.post = post
//                let size = postCellEstimator.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
//                post.contentHeight = size.height
//            }
//        }
//        return post.contentHeight!
//    }

}

// MARK: UIScrollView delegate

extension HomeViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (contentHeight - screenHeight - loadTriggerHeight) < offsetY {
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
    
    private func registerCell() {
        
        let RecommendStationTableCellNib = UINib(nibName: "RecommendStationTableViewCell", bundle: nil)
        tableView.registerNib(RecommendStationTableCellNib, forCellReuseIdentifier: "RecommendStationTableCell")
        
        let ICYPostCellNib = UINib(nibName: "ICYPostCell", bundle: nil)
        tableView.registerNib(ICYPostCellNib, forCellReuseIdentifier: "ICYPostCellIdentifier")
        
        let ICYPostImageCellNib = UINib(nibName: "ICYPostImageCell", bundle: nil)
        tableView.registerNib(ICYPostImageCellNib, forCellReuseIdentifier: "ICYPostImageCellIdentifier")
    }
    
    private func setupRefreshControll() {
        if let refreshControl = self.refreshControl {
            refreshControl.tintColor = Palette.LightBlue.primaryColor
            refreshControl.addTarget(self, action: "loadNewContent", forControlEvents: UIControlEvents.ValueChanged)
        }
    }
    
    private func getRecommendInfo(location: CLLocation?) {
        
        let needToLoadStations = self.recommendGroups == nil && self.contents.find { $0 is [GroupEntity] } == nil
        
        if !needToLoadStations { return }
        
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
        if isLoading || isExhausted {
            return
        }
        
        isLoading = true
        tableView.tableFooterView = footerView

        var parameters = Router.Post.FindParameters(category: .all)
    
        if let oldestContent = oldestContent as? PostEntity {
            parameters.before = oldestContent.createDate.timeIntervalSince1970
        }
        
        Router.Post.Find(parameters: parameters).response {
            self.tableView.tableFooterView = nil
            
            if $0.result.isFailure {
                self.isLoading = false
                self.isExhausted = true
                return
            }
            
            let posts: [PostEntity]? = PostEntity.collection($0.result.value!)
            
            if let loadPosts: [AnyObject] = posts {
                self.contents += loadPosts
                
                for content in loadPosts {
                    if let content = content as? PostEntity {
                        self.simulateLayout(content)
                    }
                }
                
                self.appendRows(loadPosts.count)
                
                let visibleCells = self.tableView.visibleCells
                let visibleIndexPath = self.tableView.indexPathForCell(visibleCells.get(0)!)
                
                if let recommendStations: AnyObject = self.recommendGroups as? AnyObject {
                    let row = visibleIndexPath!.row + 1
                    self.contents.insert(recommendStations, atIndex: Int(row))
                    let stationsInsertIndexPath = NSIndexPath(forRow: row, inSection: 0)
                    self.tableView.insertRowsAtIndexPaths([stationsInsertIndexPath], withRowAnimation: .Fade)
                    self.recommendGroups = nil
                }
            }
            self.isLoading = false
        }
    }
    
    func loadNewContent() {
        
        // skip if already in loading
        if isLoading {
            return
        }
        
        isLoading = true

        var parameters = Router.Post.FindParameters(category: .all)
        
        if let latestContent = latestContent as? PostEntity {
            // TODO - This is a dirty solution
            parameters.after = latestContent.createDate.timeIntervalSince1970 + 1
        }
        
        Router.Post.Find(parameters: parameters).response {
            if $0.result.isFailure {
                self.endRefreshing()
                return
            }
            
            if let loadPosts:[PostEntity] = PostEntity.collection($0.result.value!) {
                self.contents = loadPosts + self.contents
                self.prependRows(loadPosts.count)
            }
            
            self.endRefreshing()

        }
    }
    
    private func endRefreshing() {
        
        self.isLoading = false
        self.refreshControl?.endRefreshing()
//        self.activityIndicator.stopAnimating()
//        self.activityIndicator.alpha = 0
//        self.indicatorLabel.alpha = 0
//        self.indicatorLabel.text = "向下拉动加载更多内容"
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
    
    func simulateLayout(post: PostEntity) {
        if post.contentHeight == nil && tableView != nil {
            if post.images?.count > 0 {
                if postImageCellEstimator == nil {
                    postImageCellEstimator = tableView.dequeueReusableCellWithIdentifier("ICYPostImageCellIdentifier") as! ICYPostImageCell
                }
                postImageCellEstimator.post = post
                let size = postImageCellEstimator.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                post.contentHeight = size.height
            } else {
                if postCellEstimator == nil {
                    postCellEstimator = tableView.dequeueReusableCellWithIdentifier("ICYPostCellIdentifier") as! ICYPostCell
                }
                postCellEstimator.post = post
                let size = postCellEstimator.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                post.contentHeight = size.height
            }
        }
    }
}

class TextPostCell: UITableViewCell {

    @IBOutlet weak var avatarImageVIew: UIImageView!

    @IBOutlet weak var nickNameLabel: UILabel!

    @IBOutlet weak var postDateLabel: UILabel!

    @IBOutlet weak var contentLabel: UILabel!

    @IBOutlet weak var infoLabel: UILabel!

    var post: PostEntity! {
        
        didSet {
            avatarImageVIew.sd_setImageWithURL(NSURL(string: post.owner.photo ?? ""), placeholderImage: UIImage(named: "avatar"))
            nickNameLabel.text = post.owner.nickName
            postDateLabel.text = post.createDate.relativeTimeToString()
            contentLabel.text = post.content
        }
    }

}

final class ImagePostCell: TextPostCell {

}
