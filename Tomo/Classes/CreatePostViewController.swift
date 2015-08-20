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
    
    @IBOutlet weak var paperViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var paperView: UIView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var numberBadge: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupAppearance()
        
        self.registerForKeyboardNotifications()
        
        self.postTextView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    deinit {
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
        
        self.collectionView.allowsMultipleSelection = true
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.activityType = .Fitness
        
    }
    
    private func registerForKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        
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
}

// MARK: - Actions

extension CreatePostViewController {
    
    @IBAction func cancel(sender: AnyObject) {
        self.postTextView.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
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
                
//                if find(availableMediaTypes, kUTTypeImage) == nil {
//                    return
//                }
                
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
            
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(200, 200), contentMode: PHImageContentMode.AspectFill, options: PHImageRequestOptions()) { (image: UIImage!, info: [NSObject : AnyObject]!) -> Void in
                cell.contentView.addSubview(UIImageView(image: image))
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
            
            self.dismissViewControllerAnimated(true) {
                let insertPath = NSIndexPath(forItem: 0, inSection: 0)
                self.collectionView.insertItemsAtIndexPaths([insertPath])
                self.collectionView.selectItemAtIndexPath(insertPath, animated: true, scrollPosition: UICollectionViewScrollPosition.Left)
                self.updateNumberBadge()
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
    
}
