//
//  HomeViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/07/09.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class HomeViewController: BaseTableViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var indicatorLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var locationError: NSError?
    var location: CLLocation?
    var updatingLocation = false
    
    let screenHeight = UIScreen.mainScreen().bounds.height
    let screenWidth = UIScreen.mainScreen().bounds.width
    let loadTriggerHeight = CGFloat(88.0)
    
    var contents = [AnyObject]()
    var latestContent: AnyObject?
    var oldestContent: AnyObject?
    
    var isLoading = false
    var isExhausted = false
    
    var recommendStations: [GroupEntity]?
    
    var timer: NSTimer?
    
    var postCellEstimator: ICYPostCell!
    var postImageCellEstimator: ICYPostImageCell!
    
    /// true: comment, false: cell content
    private var selectCellOrComment = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.registerCell()
        
        self.setupRefreshControll()
        
        self.setupLocationManager()
        
        self.getLocation()
        
        self.loadMoreContent()
    }
    
    override func becomeActive() {
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
        if segue.identifier == "modalStationSelector" {
            let nav = segue.destinationViewController as! UINavigationController
            let vc = nav.viewControllers[0] as! StationDiscoverViewController
            if let location = location {
                vc.location = location
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
            
            let cell = tableView.dequeueReusableCellWithIdentifier("RecommendSiteTableCell", forIndexPath: indexPath) as! RecommendSiteTableCell
            cell.groups = groups
            cell.delegate = self
            cell.setup()
            return cell
            
        } else if let stations = contents[indexPath.item] as? [GroupEntity] {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("RecommendStationTableCell", forIndexPath: indexPath) as! RecommendStationTableCell
            cell.stations = stations
            cell.delegate = self
            cell.tableViewController = self
            cell.setup()
            return cell
            
        } else if let post = contents[indexPath.row] as? PostEntity {
            var cell: ICYPostCell!
            if post.images?.count > 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("ICYPostImageCellIdentifier") as! ICYPostImageCell
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("ICYPostCellIdentifier") as! ICYPostCell
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
        //        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let post = contents[indexPath.row] as? PostEntity {
            if post.contentHeight == nil {
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
            return post.contentHeight!
        } else if contents[indexPath.row] is [StationEntity] {
            return 423.0
        } else if contents[indexPath.row] is [GroupEntity] {
            return 623.0
        }
        return 0
    }
    
}

// MARK: UIScrollView delegate

extension HomeViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        super.scrollViewDidScroll(scrollView)
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (contentHeight - screenHeight - loadTriggerHeight) < offsetY {
            loadMoreContent()
        }
        
        if offsetY < 0 {
            indicatorLabel.alpha = abs(offsetY)/64
            activityIndicator.alpha = abs(offsetY)/64
        }
    }
}

// MARK: - CLLocationManager Delegate

extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        // The location is currently unknown, but CoreLocation will keep trying
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        
        // or save the error and stop location manager
        self.locationError = error
        self.stopLocationManager()
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println(status)
        
        switch status {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            self.getLocation()
        default:
            return
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let newLocation = locations.last as! CLLocation
        
        // the location object was determine too long age, ignore it
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        // horizontalAccuracy less than 0 is invalid result, ignore it
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(DBL_MAX)
        if let location = self.location {
            distance = newLocation.distanceFromLocation(location)
        }
        
        // new location object more accurate than previous one
        if self.location == nil || self.location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            
            println("***** location updated")
            
            // accept the result
            self.locationError = nil
            self.location = newLocation
            
            // accuracy better than desiredAccuracy, stop locating
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                println("***** normal done")
                self.stopLocationManager()
            }
            
            self.getRecommendInfo()
            
            // if the location didn't changed too much
        } else if distance < 1.0 {
            
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            
            if timeInterval > 10 {
                println("***** force done")
                self.stopLocationManager()
                self.getRecommendInfo()
            }
        }
        
    }
}

// MARK: - Actions

extension HomeViewController {
    func discoverMoreStation() {
        performSegueWithIdentifier("modalStationSelector", sender: nil)
    }
    func synchronizeRecommendStations(newStations: [StationEntity]) {
        for index in 0..<contents.count {
            if let _ = contents[index] as? [StationEntity] {
                contents[index] = newStations
                break
            }
        }
    }
}

// MARK: Internal methods

extension HomeViewController {
    
    private func registerCell() {
        
        let RecommendSiteTableCellNib = UINib(nibName: "RecommendSiteTableCell", bundle: nil)
        tableView.registerNib(RecommendSiteTableCellNib, forCellReuseIdentifier: "RecommendSiteTableCell")
        
        let RecommendStationTableCellNib = UINib(nibName: "RecommendStationTableViewCell", bundle: nil)
        tableView.registerNib(RecommendStationTableCellNib, forCellReuseIdentifier: "RecommendStationTableCell")
        
        let ICYPostCellNib = UINib(nibName: "ICYPostCell", bundle: nil)
        tableView.registerNib(ICYPostCellNib, forCellReuseIdentifier: "ICYPostCellIdentifier")
        
        let ICYPostImageCellNib = UINib(nibName: "ICYPostImageCell", bundle: nil)
        tableView.registerNib(ICYPostImageCellNib, forCellReuseIdentifier: "ICYPostImageCellIdentifier")
    }
    
    private func setupRefreshControll() {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: "loadNewContent", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refresh
    }
    
    private func setupLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.activityType = .Fitness
    }
    
    private func getLocation() {
        
        if CLLocationManager.locationServicesEnabled() && locationServiceAuthorized() {
            
            if !self.updatingLocation {
                
                self.location = nil
                self.locationError = nil
                
                timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("didTimeOut"), userInfo: nil, repeats: false)
                
                self.updatingLocation = true
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    private func locationServiceAuthorized() -> Bool {
        
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            return true
        case .NotDetermined:
            self.locationManager.requestWhenInUseAuthorization()
            return false
        case .Restricted:
            return false
        case .Denied:
            return false
        }
    }
    
    private func stopLocationManager() {
        
        if updatingLocation {
            
            if let timer = self.timer {
                timer.invalidate()
            }
            
            self.locationManager.stopUpdatingLocation()
            self.updatingLocation = false
        }
    }
    
    func didTimeOut() {
        println("***** Time Out")
        self.stopLocationManager()
    }
    
    private func getRecommendInfo() {
        
        var params = Dictionary<String, AnyObject>()
        params["category"] = "discover"
        if let location = self.location {
            params["coordinate"] = [location.coordinate.longitude, location.coordinate.latitude];
        }
        
        
        let needToLoadStations = self.recommendStations == nil && self.contents.find { $0 is [StationEntity] } == nil
        
        if needToLoadStations {
            AlamofireController.request(.GET, "/map/stations", parameters: params, hideHUD: true, success: { stationData in
                self.recommendStations = StationEntity.collection(stationData)
            })
        }
    }
    
    private func loadMoreContent() {
        
        // skip if already in loading
        if isLoading || isExhausted {
            return
        }
        
        isLoading = true
        let footerView = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: screenWidth, height: 40.0)))
        footerView.backgroundColor = Util.colorWithHexString("EFEFF4")
        tableView.tableFooterView = footerView
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        footerView.addSubview(loadingIndicator)
        loadingIndicator.sizeToFit()
        loadingIndicator.startAnimating()
        loadingIndicator.center = CGPoint(x: screenWidth / 2.0, y: 20.0)
        
        
        var params = Dictionary<String, NSTimeInterval>()
        
        if let oldestContent = oldestContent as? PostEntity {
            params["before"] = oldestContent.createDate.timeIntervalSince1970
        }
        
        AlamofireController.request(.GET, "/posts", parameters: params, hideHUD: true, success: { postData in
            
            let posts: [PostEntity]? = PostEntity.collection(postData)
            
            if let loadPosts: [AnyObject] = posts {
                self.contents += loadPosts
                
                gcd.async(.Default) {
                    for content in loadPosts {
                        if let content = content as? PostEntity {
                            self.simulateLayout(content)
                        }
                    }
                    
                    
                    gcd.async(.Main) {
                        self.appendRows(loadPosts.count)
                        
                        let visibleCells = self.tableView.visibleCells()
                        let visibleIndexPath = self.tableView.indexPathForCell(visibleCells.get(0) as! UITableViewCell)
                        
                        if let recommendStations: AnyObject = self.recommendStations as? AnyObject {
                            let row = visibleIndexPath!.row + 1
                            self.contents.insert(recommendStations, atIndex: Int(row))
                            let stationsInsertIndexPath = NSIndexPath(forRow: row, inSection: 0)
                            self.tableView.insertRowsAtIndexPaths([stationsInsertIndexPath], withRowAnimation: .Fade)
                            self.recommendStations = nil
                        }
                        
                        
                        self.isLoading = false
                        self.tableView.tableFooterView = nil
                    }
                }
            }
            }) { _ in
                
                self.isLoading = false
                self.isExhausted = true
                self.tableView.tableFooterView = nil
        }
    }
    
    func loadNewContent() {
        
        // skip if already in loading
        if isLoading {
            return
        }
        
        isLoading = true
        
        activityIndicator.startAnimating()
        indicatorLabel.text = "正在加载"
        
        var params = Dictionary<String, NSTimeInterval>()
        
        if let latestContent = latestContent as? PostEntity {
            // TODO - This is a dirty solution
            params["after"] = latestContent.createDate.timeIntervalSince1970 + 1
        }
        
        AlamofireController.request(.GET, "/posts", parameters: params, hideHUD: true, success: { result in
            
            if let loadPosts:[PostEntity] = PostEntity.collection(result) {
                self.contents = loadPosts + self.contents
                self.prependRows(loadPosts.count)
            }
            
            
            
            self.endRefreshing()
            
            }) { _ in
                
                self.endRefreshing()
        }
    }
    
    private func endRefreshing() {
        
        self.isLoading = false
        self.refreshControl?.endRefreshing()
        self.activityIndicator.stopAnimating()
        self.activityIndicator.alpha = 0
        self.indicatorLabel.alpha = 0
        self.indicatorLabel.text = "向下拉动加载更多内容"
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
