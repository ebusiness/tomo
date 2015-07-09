//
//  NewAddPostViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/02.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class AddPostViewController: BaseViewController {
    
    @IBOutlet weak var postInput: UITextView!
    @IBOutlet weak var imageListView: UICollectionView!
    @IBOutlet weak var toolBar: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var postContent: String?
    var imageList:[UIImage] = []
    var isKeyboardShown = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // set post button disabled
        self.navigationItem.rightBarButtonItem?.enabled = false

        let toolbar = Util.createViewWithNibName("PostToolBarView") as! PostToolBarView
        toolbar.delegate = self
        toolbar.addToSuperView(self.toolBar, attr: .Top)
        
        let inputAccessory = Util.createViewWithNibName("PostToolBarView") as! PostToolBarView
        inputAccessory.delegate = self
        self.postInput.inputAccessoryView = inputAccessory
        self.postInput.becomeFirstResponder()
        self.changeConstraint()
        
        // watch the keyboard
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow:"), name: UIKeyboardDidShowNotification, object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.shyNavBarManager.scrollView = nil
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func post(sender: AnyObject) {
        
        if isKeyboardShown {
            
            self.hideKeynoard()
            
        } else {
            
            // send post
            self.uploadToS3({ (imageNames, sizes) -> () in
                ApiController.addPost(imageNames, sizes: sizes, content: self.postContent!, groupId: nil, stationId: nil,location: nil, done: { (error) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            })
        }
        
    }
    
}

extension AddPostViewController {
    
    func keyboardDidShow(notification: NSNotification){
        isKeyboardShown = true
        self.navigationItem.rightBarButtonItem!.title = "完成"
    }
    
    func uploadToS3(completion:(imageNames: [String], sizes: [CGSize])->()){
        var names: [String] = []
        var sizes: [CGSize] = []
        if imageList.count == 0 {
            completion(imageNames: names,sizes: sizes)
            return
        }
        for image in imageList {
            let name = NSUUID().UUIDString
            let imagePath = NSTemporaryDirectory() + name
            image.saveToPath(imagePath)
            
            let remotePath = Constants.postPath(fileName: name)
            
            S3Controller.uploadFile(name: name, localPath: imagePath, remotePath: remotePath, done: { (error) -> Void in
                names.append(name)
                sizes.append(image.size)
                if error == nil && sizes.count == self.imageList.count {
                    completion(imageNames: names,sizes: sizes)
                }
            })
        }
        
    }
    
    func hideKeynoard(){
        postInput.resignFirstResponder()
        self.navigationItem.rightBarButtonItem?.title = "提交"
        isKeyboardShown = false
    }
}

extension AddPostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        if postContent == nil || postContent!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
            
        postContent = textView.text
        
        if postContent != nil && postContent!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            self.navigationItem.rightBarButtonItem?.enabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }
}

extension AddPostViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ImageCollectionCell
        let image = imageList[indexPath.row]
        cell.imageView.image = image
        cell.whenDelete = { ()->() in
            self.imageList.remove(image)
            self.scrollToEnd()
        }
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println(indexPath.row)
    }
            
    // move to the last image
    func scrollToEnd(){
        self.imageListView.reloadData()
        self.changeConstraint()
        if imageList.count == 0 {
            return
        }
        let section = imageListView.numberOfSections() - 1
        let item = imageListView.numberOfItemsInSection(section) - 1
        let lastIndexPath = NSIndexPath(forItem: item, inSection: section)
        
        imageListView.scrollToItemAtIndexPath(lastIndexPath, atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
    }
    
    func changeConstraint(){
        heightConstraint.constant = imageList.count == 0 ? 0 : 130
    }
}

extension AddPostViewController : PostToolBarDelegate{
    
    func cameraOnClick() {
        
        if isKeyboardShown {
            self.hideKeynoard()
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        let takePhotoAction = UIAlertAction(title: "拍摄", style: .Default, handler: { (_) -> Void in
            DBCameraController.openCamera(self, delegate: self)
        })
        let chooseFromLibraryAction = UIAlertAction(title: "从相册选择", style: .Default, handler: { (_) -> () in
            DBCameraController.openLibrary(self, delegate: self)
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(takePhotoAction)
        alertController.addAction(chooseFromLibraryAction)
        
        presentViewController(alertController, animated: true, completion: nil)

    }
}

extension AddPostViewController: DBCameraViewControllerDelegate {
    
    func camera(cameraViewController: AnyObject!, didFinishWithImage image: UIImage!, withMetadata metadata: [NSObject : AnyObject]!) {
        let image = image.scaleToFitSize(CGSize(width: MaxWidth, height: MaxWidth))
        
        let newImage = image.normalizedImage()
        
        self.imageList.append(newImage)
        self.scrollToEnd()
        self.dismissCamera(cameraViewController)
        
    }
    
    func dismissCamera(cameraViewController: AnyObject!) {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        cameraViewController.restoreFullScreenMode()
    }
}



