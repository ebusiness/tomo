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

    let photoCollectionViewHeight = CGFloat(216)

    let paperPadding = CGFloat(8)
    
    var group: GroupEntity?
    
    var photos: PHFetchResult?

    var newPhotos = [UIImage]()

    var timer: NSTimer?

    var location: CLLocation?

    var placemark: CLPlacemark?

    @IBOutlet weak var postButton: UIBarButtonItem!

    @IBOutlet weak var postTextView: UITextView!

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var groupLabel: UILabel!

    @IBOutlet weak var numberBadge: UILabel!

    @IBOutlet weak var locationButton: UIButton!

    @IBOutlet weak var clearLocationButton: UIButton!

    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var paperViewBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var locationButtonWidthConstraint: NSLayoutConstraint!

    override func viewDidLoad() {

        super.viewDidLoad()

        self.setupAppearance()
        
        self.registerForKeyboardNotifications()

        // config location label with the current setting of location service.
        LocationController.shareInstance.doActionWithPlacemark { placemark, location in
            self.placemark = placemark
            self.location = location
            self.updateLocationLabel()
        }
    }

    // If do this in viewDidLoad, there will be a wired animation  because
    // the keyborad show up. so bring up the keyborad after view appeared.
    override func viewDidAppear(animated: Bool) {
        self.postTextView.becomeFirstResponder()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier != "postCreated" { return }
        
        if let sender: AnyObject = sender {
            
            guard let post = sender as? PostEntity else { return }
            
            post.owner = me
            
            if let homeViewController = segue.destinationViewController as? HomeViewController {
                
                homeViewController.contents.insert(post, atIndex: 0)
                homeViewController.latestContent = post
                homeViewController.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Middle)
                
            } else if let _ = segue.destinationViewController as? GroupDetailViewController {
                
            }
            
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

// MARK: - Internal Methods 

extension CreatePostViewController {
    
    private func setupAppearance() {

        if let group = self.group {
            self.groupLabel.text = "发布在：\(group.name)"
        } else {
            groupLabel.text = nil
        }

        self.collectionView.allowsMultipleSelection = true
    }
    
    private func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShown(notification: NSNotification) {

        guard let info = notification.userInfo else { return }
        
        if let keyboardHeight = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {

            // key the text view stay above the key board
            self.paperViewBottomConstraint.constant = 8 + keyboardHeight
            // hide photo collection view below the screen
            self.collectionViewTopConstraint.constant = 0
            
            UIView.animateWithDuration(0.3, animations: { _ in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHidden(notification: NSNotification) {

        // make the text view full screen height whit a gap
        self.paperViewBottomConstraint.constant = 8
        
        UIView.animateWithDuration(0.3, animations: { _ in
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
            PHPhotoLibrary.requestAuthorization { _ in
            }
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

    private func uploadMeida(completion: (imagelist: AnyObject)->()) {
        guard let selectedIndexes = collectionView.indexPathsForSelectedItems() else { return }
        
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
                
                let options = PHImageRequestOptions()
                options.synchronous = true
                options.resizeMode = PHImageRequestOptionsResizeMode.Exact
                
                PHImageManager.defaultManager().requestImageForAsset(asset!, targetSize: PHImageManagerMaximumSize, contentMode: .AspectFill, options: options) { (image, info) -> Void in
                    
                    if let image = image {
                        self.resize(image).saveToPath(imagePath)
                    }
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
    
    private func postContent(imageList: AnyObject?) {

        var parameters = Router.Post.CreateParameters(content: self.postTextView.text!)
        
        if let imageList = imageList as? [String] {
            parameters.images = imageList
        }
        
        if let group = self.group {
            parameters.group = group.id
        }
        
        if let location = self.location {
            parameters.coordinate = [String(stringInterpolationSegment: location.coordinate.latitude),String(stringInterpolationSegment: location.coordinate.longitude)];
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
            parameters.location = address
        }
        
        Router.Post.Create(parameters: parameters).response {
            switch $0.result {
            case .Success(let value):
                self.performSegueWithIdentifier("postCreated", sender: PostEntity(value))
            default:
                break
            }
            
            Util.showHUD()
        }
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
        
        self.paperViewBottomConstraint.constant = 8
        self.collectionViewTopConstraint.constant = 216

        UIView.animateWithDuration(0.3, animations: { _ in
            self.view.layoutIfNeeded()
        })

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

            if let _ = UIImagePickerController.availableMediaTypesForSourceType(.Camera) {
                
                let picker = UIImagePickerController()
                picker.sourceType = .Camera
                picker.mediaTypes = [kUTTypeImage as String]
                picker.delegate = self
                self.presentViewController(picker, animated: true, completion: nil)
                
                self.choosePhoto()
            }
        }
    }
    
    @IBAction func markLocation(sender: AnyObject) {

        // user ask for add location explicitly, notify user if the location is not enabled.
        LocationController.shareInstance.doActionWithPlacemark(self) { placemark, location in
            self.placemark = placemark
            self.location = location
            self.updateLocationLabel()
        }
    }
    
    @IBAction func clearLocationButtonPressed(sender: AnyObject) {
        location = nil
        placemark = nil
        updateLocationLabel()
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
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("defaultCell", forIndexPath: indexPath) 
        
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
            
            let options = PHImageRequestOptions()
            options.deliveryMode = .HighQualityFormat
            options.resizeMode = .Exact
            
            PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: CGSizeMake(200, 200), contentMode: .AspectFill, options: options) { (image, info) -> Void in
                let imageView = UIImageView(image: image)
                cell.contentView.insertSubview(imageView, atIndex: 0)
            }
        }
        
        // add visual clue for the selected cell
        if let selectedIndexes = collectionView.indexPathsForSelectedItems() {
            
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
        
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) else { return }
        
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
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) else { return }
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            cell.transform = CGAffineTransformIdentity
            }, completion: { (_) -> Void in
                cell.contentView.subviews.last?.removeFromSuperview()
        })
        
        self.updateNumberBadge()
    }
    
}

// MARK: UIImagePickerController Delegate

extension CreatePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            self.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
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
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
