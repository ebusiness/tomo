//
//  CreatePostViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/08/19.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

final class CreatePostViewController: UIViewController {

    let screenHeight = UIScreen.mainScreen().bounds.height
    let photoCollectionViewHeight = CGFloat(216)
    let navigationBarHeight = CGFloat(64)
    let paperPadding = CGFloat(8)
    
    var group: GroupEntity?
    
    var photos: PHFetchResult?
    var newPhotos = [UIImage]()
    
    let locationManager = CLLocationManager()
    var locationError: NSError?
    var location: CLLocation?
    var updatingLocation = false
    
    let geocoder = CLGeocoder()
    var geocodeError: NSError?
    var placemark: CLPlacemark?
    var performGeocoding = false
    
    var timer: NSTimer?
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var paperViewHeight: NSLayoutConstraint!
    @IBOutlet weak var paperView: UIView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var numberBadge: UILabel!
    
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var locationButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var clearLocationButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paperView.frame.size.width = UIScreen.mainScreen().bounds.size.width - 8 * 2
        
        self.setupAppearance()
        
        self.registerForKeyboardNotifications()
        
        self.postTextView.becomeFirstResponder()
        
        self.markLocation("")
        
        locationButton.setImage(nil, forState: UIControlState.Normal)
        locationButtonWidthConstraint.constant = 0.0

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "postCreated" {
            
            if let sender: AnyObject = sender {
                
                let post = PostEntity(sender)
                post.owner = me
                
                if let homeViewController = segue.destinationViewController as? HomeViewController {
                    
                    homeViewController.contents.insert(post, atIndex: 0)
                    homeViewController.latestContent = post
                    homeViewController.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Middle)
                    
                } else if let groupDetailViewController = segue.destinationViewController as? GroupDetailViewController {
                    
                }
                
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    deinit {
        self.stopLocationManager()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

// MARK: - Internal Methods 

extension CreatePostViewController {
    
    private func setupAppearance() {

        self.navigationBar.translucent = true
        self.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationBar.barTintColor = Util.UIColorFromRGB(NavigationBarColorHex, alpha: 0.7)
        
        if let group = self.group {
            self.groupLabel.text = "发布在：\(group.name)"
        } else {
            groupLabel.text = nil
        }
        
        self.numberBadge.layer.cornerRadius = self.numberBadge.frame.height / 2
        self.numberBadge.layer.masksToBounds = true
        self.numberBadge.hidden = true
        
        self.postButton.enabled = false
        
        self.locationLabel.hidden = true
        
        self.collectionView.allowsMultipleSelection = true
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.activityType = .Fitness
        
    }
    
    private func registerForKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShown(notification: NSNotification) {
        if let info = notification.userInfo {
            
            if let keyboardHeight = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size.height {
                
                let paperViewHeight = screenHeight - navigationBarHeight - paperPadding * 2 - keyboardHeight
                self.paperViewHeight.constant = paperViewHeight

                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        
        let paperViewHeight = screenHeight - navigationBarHeight - paperPadding * 2 - photoCollectionViewHeight
        self.paperViewHeight.constant = paperViewHeight
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    private func updateNumberBadge() {
        
        let selectedPics = (self.collectionView.indexPathsForSelectedItems() ?? []).count
        
        if selectedPics > 0 {
            self.numberBadge.text = String(selectedPics)
            self.numberBadge.hidden = false
        } else {
            self.numberBadge.text = String(0)
            self.numberBadge.hidden = true
        }
    }
    
    private func updateLocationLabel() {
        
        if let placemark = self.placemark {
            
            var address = ""
            
            if let province = placemark.administrativeArea {
                address += province
            }
            
            if let city = placemark.locality {
                address += city
            }
            
            if let street = placemark.thoroughfare {
                address += street
            }
            
            if let houseNumber = placemark.subThoroughfare {
                address += houseNumber
            }
            
            self.locationLabel.text = address
            self.locationLabel.hidden = false
            clearLocationButton.hidden = false
            locationButton.setImage(nil, forState: UIControlState.Normal)
            locationButtonWidthConstraint.constant = 0.0
        } else {
            locationLabel.text = nil
            locationLabel.hidden = true
            clearLocationButton.hidden = true
            locationButton.setImage(UIImage(named: "marker"), forState: UIControlState.Normal)
            locationButtonWidthConstraint.constant = 30.0
        }
    }
    
    private func photoServiceAuthorized() -> Bool {
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .Authorized:
            return true
        case .NotDetermined:
            PHPhotoLibrary.requestAuthorization(nil)
            return false
        case .Restricted:
            return false
        case .Denied:
            showPhotoServiceDisabledAlert()
            return false
        }
    }
    
    private func showPhotoServiceDisabledAlert() {
        
        let alert = UIAlertController(title: "現場Tomo需要访问您的照片", message: "为了能够在您发表的帖子中加入照片，请您允许現場Tomo访问您的照片", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "不允许", style: .Destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "好", style: .Default, handler: { _ in
            let url = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(url!)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func cameraServiceAuthorized() -> Bool {
        
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        switch status {
        case .Authorized:
            return true
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: nil)
            return false
        case .Restricted:
            return false
        case .Denied:
            showCameraServiceDisabledAlert()
            return false
        }
    }
    
    private func showCameraServiceDisabledAlert() {
        
        let alert = UIAlertController(title: "現場Tomo需要访问您的相机", message: "为了能够拍照，请您允许現場Tomo访问您的相机", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "不允许", style: .Destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "好", style: .Default, handler: { _ in
            let url = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(url!)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
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
        
        let alert = UIAlertController(title: "現場Tomo需要访问您的位置", message: "为了追加位置信息，请您允许現場Tomo访问您的位置", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "不允许", style: .Destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "好", style: .Default, handler: { _ in
            let url = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(url!)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func didTimeOut() {
        self.stopLocationManager()
        self.updateLocationLabel()
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
    
    private func uploadMeida(completion: (imagelist: AnyObject)->()) {
        
        if let selectedIndexes = collectionView.indexPathsForSelectedItems() as? [NSIndexPath] {
            
            var imagelist = [String]()
            
            for index in selectedIndexes {
                
                let name = NSUUID().UUIDString
                let imagePath = NSTemporaryDirectory() + name
                let remotePath = Constants.postPath(fileName: name)
                
                if index.item < self.newPhotos.count {
                    let scaledImage = self.resize(self.newPhotos[index.item])
                    scaledImage.saveToPath(imagePath)
                } else {
                    
                    let asset = self.photos?[index.item - self.newPhotos.count] as? PHAsset
                    
                    var options = PHImageRequestOptions()
                    options.synchronous = true
                    options.resizeMode = PHImageRequestOptionsResizeMode.Exact
                    
                    PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFill, options: options) { (image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
                        
                        let scaledImage = self.resize(image)
                        scaledImage.saveToPath(imagePath)
                    }
                }
                
                S3Controller.uploadFile(imagePath, remotePath: remotePath, done: { (error) -> Void in
                    
                    imagelist.append(name)
                    
                    if error == nil && imagelist.count == selectedIndexes.count {
                        completion(imagelist: imagelist)
                    }
                })
                
            }
        }
        
    }
    
    private func postContent(imageList: AnyObject?) {
        
//        println(imageList)
        
        var param = Dictionary<String, AnyObject>()
        
        param["content"] = self.postTextView.text
        
        if let imageList: AnyObject = imageList {
            param["images"] = imageList
        }
        
        if let group = self.group {
            param["group"] = group.id
        }
        
        if let location = self.location {
            param["coordinate"] = [String(stringInterpolationSegment: location.coordinate.latitude),String(stringInterpolationSegment: location.coordinate.longitude)];
        }
        
        if let placemark = placemark {
            var address = ""
            
            if let province = placemark.administrativeArea {
                address += province
            }
            
            if let city = placemark.locality {
                address += city
            }
            
            if let street = placemark.thoroughfare {
                address += street
            }
            
            if let houseNumber = placemark.subThoroughfare {
                address += houseNumber
            }
            param["location"] = address
        }
        
        AlamofireController.request(.POST, "/posts", parameters: param, encoding: .JSON,
            success: { post in
            self.performSegueWithIdentifier("postCreated", sender: post)
        })
    }
    
    // TODO - refactor out
    private func resize(image: UIImage) -> UIImage {
        
        let imageData = UIImageJPEGRepresentation(image, 1)!
        
        // if the image smaller than 1MB, do nothing
        if !(imageData.length/1024/1024 > 1) {
            return image.normalizedImage()
        }
        
        // modify this value to change result size
        let resizeFactor:CGFloat = 1
        
        // based on iPhone6 plus screen
        let widthBase = UIScreen.mainScreen().bounds.size.width * resizeFactor
        let heigthBase = UIScreen.mainScreen().bounds.size.height * resizeFactor
        
        return image.scaleToFitSize( CGSizeMake(widthBase, heigthBase) ).normalizedImage()
    }
}

// MARK: - Actions

extension CreatePostViewController {
    
    @IBAction func cancel(sender: AnyObject) {
        self.postTextView.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func post(sender: AnyObject) {
        
        Util.showHUD()
        
        if (collectionView.indexPathsForSelectedItems() ?? []).count > 0 {
            self.uploadMeida(postContent)
        } else {
            self.postContent(nil)
        }
    }
    
    @IBAction func choosePhoto() {
        
        if (photoServiceAuthorized() && self.photos?.count <= 0) {
            
            let assetCollection = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumUserLibrary, options: nil)
            
            if let assetCollection = assetCollection.firstObject as? PHAssetCollection {
                
                let options = PHFetchOptions()
                
                let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
                let predicate = NSPredicate(format: "mediaType = %@", NSNumber(integer: PHAssetMediaType.Image.rawValue))
                
                options.sortDescriptors = [sortDescriptor]
                options.predicate = predicate
                
                self.photos = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: options)
                self.collectionView.reloadData()
            }
        }
        
        self.postTextView.resignFirstResponder()
    }
    
    @IBAction func takePhoto(sender: AnyObject) {
        
        if cameraServiceAuthorized() && UIImagePickerController.isSourceTypeAvailable(.Camera) {

            if let availableMediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.Camera) as? [String] {
                
                let picker = UIImagePickerController()
                picker.sourceType = .Camera
                picker.mediaTypes = [kUTTypeImage]
                picker.delegate = self
                self.presentViewController(picker, animated: true, completion: nil)
                
                self.choosePhoto()
            }
        }
    }
    
    @IBAction func markLocation(sender: AnyObject) {
        
        if CLLocationManager.locationServicesEnabled() && locationServiceAuthorized() {
            
            if self.updatingLocation {
                self.stopLocationManager()
                
            } else {
                
                self.location = nil
                self.locationError = nil
                
                self.placemark = nil
                self.geocodeError = nil
                
                timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: Selector("didTimeOut"), userInfo: nil, repeats: false)
                
                self.updatingLocation = true
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    @IBAction func clearLocationButtonPressed(sender: AnyObject) {
        location = nil
        placemark = nil
        updateLocationLabel()
    }
    
}

// MARK: - UINavigationBar Delegate

extension CreatePostViewController {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

// MARK: - UITextView Delegate

extension CreatePostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.text = nil
        textView.textColor = UIColor.darkTextColor()
    }
    
    func textViewDidChange(textView: UITextView) {
        
        let postContent = textView.text.trimmed()
        
        if postContent.length > 0 {
            self.postButton.enabled = true
        } else {
            self.postButton.enabled = false
        }
    }
}

// MARK: - UICollectionView DataSource

extension CreatePostViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (self.photos?.count ?? 0) + self.newPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("defaultCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        // clear cell contents
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        // show the photo just took
        if indexPath.item < self.newPhotos.count {
            
            let imageView = UIImageView(image: self.newPhotos[indexPath.item])
            imageView.contentMode = .ScaleAspectFill
            imageView.frame = CGRectMake(0, 0, 200, 200)
            
            cell.contentView.addSubview(imageView)
            
        // or show the photo in photo library
        } else if let asset = self.photos?[indexPath.item - self.newPhotos.count] as? PHAsset {
            
            var options = PHImageRequestOptions()
            options.deliveryMode = .HighQualityFormat
            options.resizeMode = .Exact
            
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(200, 200), contentMode: .AspectFill, options: options) { (image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
                let imageView = UIImageView(image: image)
                cell.contentView.insertSubview(imageView, atIndex: 0)
            }
        }
        
        // add visual clue for the selected cell
        if let selectedIndexes = collectionView.indexPathsForSelectedItems() as? [NSIndexPath] {
            
            if selectedIndexes.contains(indexPath) {
                
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    cell.transform = CGAffineTransformMakeScale(0.9, 0.9)
                }, completion: { (_) -> Void in
                    let mark = UIImageView(image: UIImage(named: "ok"))
                    let position = CGPoint(x: 4, y: 4)
                    mark.frame.origin = position
                    mark.roundedCorner = true
                    mark.layer.borderWidth = 2.0
                    mark.layer.borderColor = UIColor.whiteColor().CGColor
                    cell.contentView.addSubview(mark)
                })
            }
        }
        
        return cell
    }
    
}

// MARK: - UICollectionView Delegate

extension CreatePostViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            
            if (collectionView.indexPathsForSelectedItems() ?? []).count > 10 {
                collectionView.deselectItemAtIndexPath(indexPath, animated: false)
                return
            }
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                cell.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }, completion: { (_) -> Void in
                let mark = UIImageView(image: UIImage(named: "ok"))
                let position = CGPoint(x: 4, y: 4)
                mark.frame.origin = position
                mark.roundedCorner = true
                mark.layer.borderWidth = 2.0
                mark.layer.borderColor = UIColor.whiteColor().CGColor
                cell.contentView.addSubview(mark)
            })
            
            self.updateNumberBadge()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                cell.transform = CGAffineTransformIdentity
            }, completion: { (_) -> Void in
                cell.contentView.subviews.last?.removeFromSuperview()
            })
            
            self.updateNumberBadge()
        }
    }
    
}

// MARK: UIImagePickerController Delegate

extension CreatePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.newPhotos.insert(image.normalizedImage(), atIndex: 0)
            let insertPath = NSIndexPath(forItem: 0, inSection: 0)
            
            self.dismissViewControllerAnimated(true) {
                
                self.collectionView.insertItemsAtIndexPaths([insertPath])
                self.collectionView.selectItemAtIndexPath(insertPath, animated: true, scrollPosition: .Left)
                self.updateNumberBadge()
                
                if let cell = self.collectionView.cellForItemAtIndexPath(insertPath) {
                    UIView.animateWithDuration(0.1, animations: { () -> Void in
                        cell.transform = CGAffineTransformMakeScale(0.9, 0.9)
                    }, completion: { (_) -> Void in
                        let mark = UIImageView(image: UIImage(named: "ok"))
                        cell.contentView.addSubview(mark)
                    })
                }
            }
            
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - CLLocationManager Delegate

extension CreatePostViewController: CLLocationManagerDelegate {
    
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
            
            // start reverse geocoding
            if !self.performGeocoding {
                
                self.performGeocoding = true
                
                self.geocoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) -> Void in
                    
                    self.geocodeError = error
                    
                    if let placemarks = placemarks where error == nil && placemarks.count > 0 {
                        self.placemark = placemarks.last as? CLPlacemark
                    } else {
                        self.placemark = nil
                    }
                    
                    self.performGeocoding = false
                    self.updateLocationLabel()
                })
            }
            
            // if the location didn't changed too much
        } else if distance < 1.0 {
            
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            
            if timeInterval > 10 {
                println("***** force done")
                self.stopLocationManager()
                self.updateLocationLabel()
            }
        }
        
    }
}
