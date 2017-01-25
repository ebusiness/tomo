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
    
    var photos: PHFetchResult<PHAsset>?

    var newPhotos = [UIImage]()

    var timer: Timer?

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
    override func viewDidAppear(_ animated: Bool) {
        self.postTextView.becomeFirstResponder()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

// MARK: - Internal Methods 

extension CreatePostViewController {
    
    fileprivate func setupAppearance() {

        if let group = self.group {
            self.groupLabel.text = "发布在：\(group.name)"
        } else {
            groupLabel.text = nil
        }

        self.collectionView.allowsMultipleSelection = true
    }
    
    fileprivate func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(CreatePostViewController.keyboardWillShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CreatePostViewController.keyboardWillHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShown(_ notification: NSNotification) {

        guard let info = notification.userInfo else { return }
        
        if let keyboardHeight = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {

            // key the text view stay above the key board
            self.paperViewBottomConstraint.constant = 8 + keyboardHeight
            // hide photo collection view below the screen
            self.collectionViewTopConstraint.constant = 0
            
            UIView.animate(withDuration: 0.3, animations: { _ in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHidden(_ notification: NSNotification) {

        // make the text view full screen height whit a gap
        self.paperViewBottomConstraint.constant = 8
        
        UIView.animate(withDuration: 0.3, animations: { _ in
            self.view.layoutIfNeeded()
        })
    }
    
    fileprivate func updateNumberBadge() {
        
        let selectedPics = (self.collectionView.indexPathsForSelectedItems ?? []).count
        
        if selectedPics > 0 {
            self.numberBadge.text = String(selectedPics)
            self.numberBadge.isHidden = false
        } else {
            self.numberBadge.text = String(0)
            self.numberBadge.isHidden = true
        }
    }
    
    fileprivate func updateLocationLabel() {
        
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
            self.locationLabel.isHidden = false
            clearLocationButton.isHidden = false
            locationButton.setImage(nil, for: .normal)
            locationButtonWidthConstraint.constant = 0.0
        } else {
            locationLabel.text = nil
            locationLabel.isHidden = true
            clearLocationButton.isHidden = true
            locationButton.setImage(UIImage(named: "marker"), for: .normal)
            locationButtonWidthConstraint.constant = 30.0
        }
    }
    
    fileprivate func photoServiceAuthorized() -> Bool {
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { _ in
            }
            return false
        case .restricted:
            return false
        case .denied:
            showPhotoServiceDisabledAlert()
            return false
        }
    }
    
    fileprivate func showPhotoServiceDisabledAlert() {
        
        let alert = UIAlertController(title: "現場Tomo需要访问您的照片", message: "为了能够在您发表的帖子中加入照片，请您允许現場Tomo访问您的照片", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "不允许", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "好", style: .default, handler: { _ in
            let url = URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.openURL(url!)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func cameraServiceAuthorized() -> Bool {
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: nil)
            return false
        case .restricted:
            return false
        case .denied:
            showCameraServiceDisabledAlert()
            return false
        }
    }
    
    fileprivate func showCameraServiceDisabledAlert() {
        
        let alert = UIAlertController(title: "現場Tomo需要访问您的相机", message: "为了能够拍照，请您允许現場Tomo访问您的相机", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "不允许", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "好", style: .default, handler: { _ in
            let url = URL(string: UIApplicationOpenSettingsURLString)
            UIApplication.shared.openURL(url!)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func uploadMeida(completion: @escaping (_ imagelist: Any)->()) {
        guard let selectedIndexes = collectionView.indexPathsForSelectedItems else { return }
        
        var imagelist = [String]()
        
        for index in selectedIndexes {
            
            let name = NSUUID().uuidString
            let imagePath = NSTemporaryDirectory() + name
            let remotePath = Constants.postPath(fileName: name)
            
            if index.item < self.newPhotos.count {
                let scaledImage = self.resize(image: self.newPhotos[index.item])
                scaledImage.save(toPath: imagePath)
            } else {
                
                let asset = self.photos?[index.item - self.newPhotos.count]
                
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.resizeMode = PHImageRequestOptionsResizeMode.exact
                
                PHImageManager.default().requestImage(for: asset!, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { (image, info) -> Void in
                    
                    if let image = image {
                        self.resize(image: image).save(toPath: imagePath)
                    }
                }
            }
            
            S3Controller.uploadFile(localPath: imagePath, remotePath: remotePath, done: { (error) -> Void in
                
                imagelist.append(name)
                
                if error == nil && imagelist.count == selectedIndexes.count {
                    completion(imagelist: imagelist)
                }
            })
            
        }
        
    }
    
    fileprivate func postContent(imageList: Any?) {

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
            case .success(let value):
                self.performSegue(withIdentifier: "CreatePost", sender: PostEntity(value))
            default:
                break
            }

            self.postButton.isEnabled = true
        }
    }
    
    // TODO - refactor out
    fileprivate func resize(image: UIImage) -> UIImage {
        
        let imageData = UIImageJPEGRepresentation(image, 1)!
        
        // if the image smaller than 1MB, do nothing
        if !(imageData.count/1024/1024 > 1) {
            return image.normalizedImage()
        }
        
        // modify this value to change result size
        let resizeFactor:CGFloat = 1
        
        // based on iPhone6 plus screen
        let widthBase = UIScreen.main.bounds.size.width * resizeFactor
        let heigthBase = UIScreen.main.bounds.size.height * resizeFactor
        
        return image.scale( toFit: CGSize(width: widthBase, height: heigthBase) )!.normalizedImage()
    }
}

// MARK: - Actions

extension CreatePostViewController {
    
    @IBAction func cancel(_ sender: Any) {
        self.postTextView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func post(_ sender: Any) {

        self.postButton.isEnabled = false
        
        if (collectionView.indexPathsForSelectedItems ?? []).count > 0 {
            self.uploadMeida(completion: postContent)
        } else {
            self.postContent(imageList: nil)
        }
    }
    
    @IBAction func choosePhoto() {
        
        self.paperViewBottomConstraint.constant = 8
        self.collectionViewTopConstraint.constant = 216

        UIView.animate(withDuration: 0.3, animations: { _ in
            self.view.layoutIfNeeded()
        })
        
        if let photos = self.photos, photos.count > 0 {
            self.postTextView.resignFirstResponder()
            return
        }
        
        if !photoServiceAuthorized() {
            return
        }
        
        let assetCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        
        if let assetCollection = assetCollection.firstObject {
            
            let options = PHFetchOptions()
            
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            let predicate = NSPredicate(format: "mediaType = %@", NSNumber(value: PHAssetMediaType.image.rawValue))
            
            options.sortDescriptors = [sortDescriptor]
            options.predicate = predicate
            
            self.photos = PHAsset.fetchAssets(in: assetCollection, options: options)
            self.collectionView.reloadData()
        }
        
        self.postTextView.resignFirstResponder()
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        
        if cameraServiceAuthorized() && UIImagePickerController.isSourceTypeAvailable(.camera) {

            if let _ = UIImagePickerController.availableMediaTypes(for: .camera) {
                
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.mediaTypes = [kUTTypeImage as String]
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
                
                self.choosePhoto()
            }
        }
    }
    
    @IBAction func markLocation(_ sender: Any) {

        // user ask for add location explicitly, notify user if the location is not enabled.
        LocationController.shareInstance.doActionWithPlacemark(authRequestOnController: self) { placemark, location in
            self.placemark = placemark
            self.location = location
            self.updateLocationLabel()
        }
    }
    
    @IBAction func clearLocationButtonPressed(sender: Any) {
        location = nil
        placemark = nil
        updateLocationLabel()
    }
    
}

// MARK: - UINavigationBar Delegate

extension CreatePostViewController {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

// MARK: - UITextView Delegate

extension CreatePostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = nil
        textView.textColor = UIColor.darkText
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let postContent = textView.text.trimmed()
        
        if postContent.characters.count > 0 {
            self.postButton.isEnabled = true
        } else {
            self.postButton.isEnabled = false
        }
    }
}

// MARK: - UICollectionView DataSource

extension CreatePostViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (self.photos?.count ?? 0) + self.newPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath) 
        
        // clear cell contents
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        // show the photo just took
        if indexPath.item < self.newPhotos.count {
            
            let imageView = UIImageView(image: self.newPhotos[indexPath.item])
            imageView.contentMode = .scaleAspectFill
            imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            
            cell.contentView.addSubview(imageView)
            
        // or show the photo in photo library
        } else if let asset = self.photos?[indexPath.item - self.newPhotos.count] {
            
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: options) { (image, info) -> Void in
                let imageView = UIImageView(image: image)
                cell.contentView.insertSubview(imageView, at: 0)
            }
        }
        
        // add visual clue for the selected cell
        if let selectedIndexes = collectionView.indexPathsForSelectedItems {
            
            if selectedIndexes.contains(indexPath) {
                
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: { (_) -> Void in
                    let mark = UIImageView(image: UIImage(named: "ok"))
                    let position = CGPoint(x: 4, y: 4)
                    mark.frame.origin = position
                    mark.roundedCorner = true
                    mark.layer.borderWidth = 2.0
                    mark.layer.borderColor = UIColor.white.cgColor
                    cell.contentView.addSubview(mark)
                })
            }
        }
        
        return cell
    }
}

// MARK: - UICollectionView Delegate

extension CreatePostViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        if (collectionView.indexPathsForSelectedItems ?? []).count > 10 {
            collectionView.deselectItem(at: indexPath, animated: false)
            return
        }
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { (_) -> Void in
                let mark = UIImageView(image: UIImage(named: "ok"))
                let position = CGPoint(x: 4, y: 4)
                mark.frame.origin = position
                mark.roundedCorner = true
                mark.layer.borderWidth = 2.0
                mark.layer.borderColor = UIColor.white.cgColor
                cell.contentView.addSubview(mark)
        })
        
        self.updateNumberBadge()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            cell.transform = CGAffineTransform.identity
            }, completion: { (_) -> Void in
                cell.contentView.subviews.last?.removeFromSuperview()
        })
        
        self.updateNumberBadge()
    }
    
}

// MARK: UIImagePickerController Delegate

extension CreatePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        self.newPhotos.insert(image.normalizedImage(), at: 0)
        let insertPath = IndexPath(item: 0, section: 0)
        
        self.dismiss(animated: true) {
            
            self.collectionView.insertItems(at: [insertPath])
            self.collectionView.selectItem(at: insertPath, animated: true, scrollPosition: .left)
            self.updateNumberBadge()
            
            if let cell = self.collectionView.cellForItem(at: insertPath) {
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    }, completion: { (_) -> Void in
                        let mark = UIImageView(image: UIImage(named: "ok"))
                        cell.contentView.addSubview(mark)
                })
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
