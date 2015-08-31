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
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var paperViewHeight: NSLayoutConstraint!
    @IBOutlet weak var paperView: UIView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var numberBadge: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paperView.frame.size.width = UIScreen.mainScreen().bounds.size.width - 8 * 2
        
        self.setupAppearance()
        
        self.registerForKeyboardNotifications()
        
        self.postTextView.becomeFirstResponder()
        
        self.markLocation("")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "postCreated" {
            if let sender: AnyObject = sender, home = segue.destinationViewController as? HomeViewController {
                
                let json = JSON(sender)
                
                var post = PostEntity(sender)
                post.owner = me
                
                home.contents.insert(post, atIndex: 0)
                home.latestContent = post
                home.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Middle)
            }
        }
    }
    
    deinit {
        self.stopLocationManager()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

// MARK: - Internal Methods 

extension CreatePostViewController {
    
    private func setupAppearance() {
        
        if let navigationBar = self.navigationController?.navigationBar {
            let image = Util.imageWithColor(NavigationBarColorHex, alpha: 1.0)
            navigationBar.setBackgroundImage(image, forBarMetrics: .Default)
            navigationBar.shadowImage = UIImage()
            navigationBar.translucent = true
            navigationBar.barStyle = .Black
            navigationBar.tintColor = UIColor.whiteColor()
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
        let info = notification.userInfo
        
        let paperViewHeight = screenHeight - navigationBarHeight - paperPadding * 2 - photoCollectionViewHeight
        self.paperViewHeight.constant = paperViewHeight
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    private func updateNumberBadge() {
        
        let selectedPics = self.collectionView.indexPathsForSelectedItems().count
        
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
        println("***** Time Out")
        
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
            
            var imagelist = [[String:AnyObject]]()
            
            for index in selectedIndexes {
                
                let name = NSUUID().UUIDString
                let imagePath = NSTemporaryDirectory() + name
                let remotePath = Constants.postPath(fileName: name)
                
                if index.item < self.newPhotos.count {
                    let scaledImage = self.resize(self.newPhotos[index.item].normalizedImage())
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
                
                S3Controller.uploadFile(name: name, localPath: imagePath, remotePath: remotePath, done: { (error) -> Void in
                    
                    let imageinfo:[String:AnyObject] = [
                        "name":name,
                        "size":[
                            "width":0,
                            "height":0
                        ]
                    ]
                    
                    imagelist.append(imageinfo)
                    
                    if error == nil && imagelist.count == selectedIndexes.count {
                        completion(imagelist: imagelist)
                    }
                })
                
            }
        }
        
    }
    
    private func postContent(imageList: AnyObject?) {
        
        println(imageList)
        
        var param = Dictionary<String, AnyObject>()
        
        param["content"] = self.postTextView.text
        
        if let imageList: AnyObject = imageList {
            param["images"] = imageList
        }
        
        if let location = self.location {
            param["coordinate"] = [String(stringInterpolationSegment: location.coordinate.latitude),String(stringInterpolationSegment: location.coordinate.longitude)];
        }
        
        Manager.sharedInstance.request(.POST, kAPIBaseURLString + "/mobile/posts" , parameters: param,encoding: ParameterEncoding.JSON)
            .responseJSON { (_, _, post, _) -> Void in
                Util.dismissHUD()
                self.performSegueWithIdentifier("postCreated", sender: post)
        }
    }
    
    // TODO - refactor out
    private func resize(image: UIImage) -> UIImage {
        
        var imageData = UIImageJPEGRepresentation(image, 1)
        
        // if the image smaller than 1MB, do nothing
        if !(imageData.length/1024/1024 > 1) {
            return image
        }
        
        // modify this value to change result size
        let resizeFactor = 1
        
        // based on iPhone6 plus screen
        let widthBase = CGFloat(414 * resizeFactor)
        let heigthBase = CGFloat(736 * resizeFactor)
        
        let cgImage = image.CGImage
        
        let width = CGFloat(CGImageGetWidth(cgImage))
        let height = CGFloat(CGImageGetHeight(cgImage))
        
        // image initial ratio
        var ratio = CGFloat(1)
        
        // calculate resize ratio by width and height
        if width > widthBase && height > heigthBase {
            if width > height {
                ratio = widthBase / width
            } else {
                ratio = heigthBase / height
            }
        } else if width > widthBase && height <= heigthBase {
            ratio = widthBase / width
        } else if width <= widthBase && height > heigthBase {
            ratio = heigthBase / height
        }
        
        let resultSize = CGSize(width: width * ratio, height: height * ratio)
        
        // prepare redraw context
        let bitsPerComponent = CGImageGetBitsPerComponent(cgImage)
        let bytesPerRow = CGImageGetBytesPerRow(cgImage)
        let colorSpace = CGImageGetColorSpace(cgImage)
        let bitmapInfo = CGImageGetBitmapInfo(cgImage)
        let context = CGBitmapContextCreate(nil, Int(width * ratio), Int(height * ratio), bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
        
        // redraw image by new size
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: resultSize), cgImage)
        
        let result = CGBitmapContextCreateImage(context)
        
        return UIImage(CGImage: result)!
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
        
        if collectionView.indexPathsForSelectedItems().count > 0 {
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
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                cell.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }, completion: { (_) -> Void in
                let mark = UIImageView(image: UIImage(named: "ok"))
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
            
            self.newPhotos.insert(image, atIndex: 0)
            let insertPath = NSIndexPath(forItem: 0, inSection: 0)
            
            self.dismissViewControllerAnimated(true) {
                
                self.collectionView.insertItemsAtIndexPaths([insertPath])
                self.collectionView.selectItemAtIndexPath(insertPath, animated: true, scrollPosition: .Left)
                self.updateNumberBadge()
                
                let cell = self.collectionView.cellForItemAtIndexPath(insertPath)!
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    cell.transform = CGAffineTransformMakeScale(0.9, 0.9)
                }, completion: { (_) -> Void in
                    let mark = UIImageView(image: UIImage(named: "ok"))
                    cell.contentView.addSubview(mark)
                })
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
                
                self.geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                    
                    self.geocodeError = error
                    
                    if error == nil && !placemarks.isEmpty {
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
