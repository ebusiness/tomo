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
    let loadTriggerHeight = CGFloat(88.0)
    
    var contents = [AnyObject]()
    var latestContent: AnyObject?
    var oldestContent: AnyObject?
    
    var isLoading = false
    var isExhausted = false
    
    var recommendGroups: [GroupEntity]?
    var recommendStations: [StationEntity]?
    
    var timer: NSTimer?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.registerCell()
        
        self.setupRefreshControll()
        
        self.setupTableRowHeight()
        
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
            return cell
            
        } else if let stations = contents[indexPath.item] as? [StationEntity] {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("RecommendStationTableCell", forIndexPath: indexPath) as! RecommendStationTableCell
            cell.stations = stations
            cell.delegate = self
            return cell
            
        } else if let post = contents[indexPath.row] as? PostEntity {
            
            var cell: PostCell!
            
            if post.images?.count > 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("PostImageCell", forIndexPath: indexPath) as! PostImageCell
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
            }
            
            cell.post = post
            cell.setupDisplay()
            
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
//    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        
//        if let post = contents.get(indexPath.row) as? PostEntity {
//            
//            var textHeight = 0
//            
//            if post.content.length > 150 {
//                // one character take 18 points height, 
//                // and 150 characters will take 7 rows
//                textHeight = 18 * 7
//            } else {
//                // one row have 24 characters
//                textHeight = post.content.length / 24 * 18
//            }
//            
//            if post.images?.count > 0 {
//                return CGFloat(472 + textHeight)
//            } else {
//                return CGFloat(108 + textHeight)
//            }
//        }
//        
//        return UITableViewAutomaticDimension
//    }
    
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
            
            // accept the result
            self.locationError = nil
            self.location = newLocation
            
            // accuracy better than desiredAccuracy, stop locating
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
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

// MARK: Internal methods

extension HomeViewController {
    
    private func registerCell() {
        
        var postCellNib = UINib(nibName: "PostCell", bundle: nil)
        tableView.registerNib(postCellNib, forCellReuseIdentifier: "PostCell")
        
        var postImageCellNib = UINib(nibName: "PostImageCell", bundle: nil)
        tableView.registerNib(postImageCellNib, forCellReuseIdentifier: "PostImageCell")
        
        var RecommendSiteTableCellNib = UINib(nibName: "RecommendSiteTableCell", bundle: nil)
        tableView.registerNib(RecommendSiteTableCellNib, forCellReuseIdentifier: "RecommendSiteTableCell")
        
        var RecommendStationTableCellNib = UINib(nibName: "RecommendStationTableViewCell", bundle: nil)
        tableView.registerNib(RecommendStationTableCellNib, forCellReuseIdentifier: "RecommendStationTableCell")
    }
    
    private func setupRefreshControll() {
        var refresh = UIRefreshControl()
        refresh.addTarget(self, action: "loadNewContent", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl = refresh
    }
    
    private func setupTableRowHeight() {
        self.tableView.estimatedRowHeight = 550
        self.tableView.rowHeight = UITableViewAutomaticDimension
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
            showLocationServiceDisabledAlert()
            return false
        }
    }
    
    private func showLocationServiceDisabledAlert() {
        
        let alert = UIAlertController(title: "現場Tomo需要访问您的位置", message: "为了给您提供更多更好的内容，请您允许現場Tomo访问您的位置", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "不允许", style: .Destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "好", style: .Default, handler: { _ in
            let url = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(url!)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
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
            params["coordinate"] = [location.coordinate.latitude, location.coordinate.longitude];
        }
        
        AlamofireController.request(.GET, "/groups", parameters: params, success: { groupData in
            
            self.recommendGroups = GroupEntity.collection(groupData)
            
            let visibleCells = self.tableView.visibleCells()
            let visibleIndexPath = self.tableView.indexPathForCell(visibleCells.get(0) as! UITableViewCell)
            
            let insertIndexPath = NSIndexPath(forRow: visibleIndexPath!.row + 3, inSection: 0)
            
            if let groups: AnyObject = self.recommendGroups as? AnyObject {
                self.contents.insert(groups, atIndex: Int(insertIndexPath.row))
                self.tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: .Fade)
            }
            
        }) { err in
            
        }
        
        AlamofireController.request(.GET, "/stations", parameters: params, success: { stationData in
            
            self.recommendStations = StationEntity.collection(stationData)
            
            let visibleCells = self.tableView.visibleCells()
            let visibleIndexPath = self.tableView.indexPathForCell(visibleCells.get(0) as! UITableViewCell)
            
            let insertIndexPath = NSIndexPath(forRow: visibleIndexPath!.row + 6, inSection: 0)
            
            if let stations: AnyObject = self.recommendStations as? AnyObject {
                self.contents.insert(stations, atIndex: Int(insertIndexPath.row))
                self.tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: .Fade)
            }
            
        }) { err in
                
        }
    }
    
    private func loadMoreContent() {
        
        // skip if already in loading
        if isLoading || isExhausted {
            return
        }

        isLoading = true
        
        var params = Dictionary<String, NSTimeInterval>()
        
        if let oldestContent = oldestContent as? PostEntity {
            params["before"] = oldestContent.createDate.timeIntervalSince1970
        }
        
        AlamofireController.request(.GET, "/posts", parameters: params, success: { postData in
            
            let posts: [PostEntity]? = PostEntity.collection(postData)
            
            if let loadPosts: [AnyObject] = posts {
                self.contents += loadPosts
                self.appendRows(loadPosts.count)
            }
            
//            var rowNumber = 0
//            
//            if let loadPosts: [AnyObject] = posts {
//                self.contents += loadPosts
//                rowNumber += loadPosts.count
//            }
//            
//            if let loadGroups: AnyObject = self.recommendGroups as? AnyObject {
//                
//                if rowNumber > 0 {
//                    let insertIndex = arc4random_uniform(UInt32(rowNumber/2)) + 1
//                    self.contents.insert(loadGroups, atIndex: Int(insertIndex))
//                }
//                rowNumber += 1
//            }
//            
//            if let loadStations: AnyObject = self.recommendStations as? AnyObject {
//                
//                if rowNumber > 0 {
//                    let insertIndex = arc4random_uniform(UInt32(rowNumber/2)) + 1
//                    self.contents.insert(loadStations, atIndex: Int(insertIndex))
//                }
//                rowNumber += 1
//            }
//            
//            self.appendRows(rowNumber)
            
            self.isLoading = false
            
        }) { err in
            
            self.isLoading = false
            self.isExhausted = true
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
        
        AlamofireController.request(.GET, "/posts", parameters: params, success: { result in
            
            if let loadPosts:[PostEntity] = PostEntity.collection(result) {
                self.contents = loadPosts + self.contents
                self.prependRows(loadPosts.count)
            } else {
                // the response is not post
            }
            self.endRefreshing()
            
        }) { err in
            
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
}