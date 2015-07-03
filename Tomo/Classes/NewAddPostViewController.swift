//
//  NewAddPostViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/02.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NewAddPostViewController: BaseViewController {
    @IBOutlet weak var postInput: UITextView!
    
    @IBOutlet weak var imageListView: UICollectionView!
    //输入的文字
    var content: String?
    //是否已经弹出键盘
    var isKeyboardsShown: Bool = false
    var imageList:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.postInput.inputAccessoryView //= inputAccessoryViewController()
        self.navigationItem.rightBarButtonItem?.enabled = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow:"), name: UIKeyboardDidShowNotification, object: nil)
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.shyNavBarManager.scrollView = nil
    }
    //键盘显示后触发事件
    func keyboardDidShow(notification: NSNotification){
        isKeyboardsShown = true
        self.navigationItem.rightBarButtonItem?.title = "完成"
    }
    //取消
    @IBAction func btnClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //关闭键盘,发帖
    @IBAction func btnOnClick(sender: AnyObject) {
        if isKeyboardsShown {//hide keyboard
            postInput.resignFirstResponder()
            self.navigationItem.rightBarButtonItem?.title = "提交"
            isKeyboardsShown = false
        }else{//create post
            self.uploadToS3({ (imageNames, sizes) -> () in
                ApiController.addPost(imageNames, sizes: sizes, content: self.content!, groupId: nil, stationId: nil,location: nil, done: { (error) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            })
        }
        
    }
    //upload to amazon s3
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
    
    @IBAction func takePhoto(sender: AnyObject) {
        let atvc = Util.createViewControllerWithIdentifier("AlertTableView", storyboardName: "ActionSheet") as! AlertTableViewController
        
        let cameraAction = AlertTableViewController.tappenDic(title: "写真を撮る",tappen: { (sender) -> () in
            DBCameraController.openCamera(self, delegate: self)
        })
        let albumAction = AlertTableViewController.tappenDic(title: "写真から選択",tappen: { (sender) -> () in
            DBCameraController.openLibrary(self, delegate: self)
        })
        atvc.show(self, data: [cameraAction,albumAction])
    }
}

// MARK: - UITextViewDelegate

extension NewAddPostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        if content == nil || content!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        content = textView.text
        
        if content != nil && content!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            self.navigationItem.rightBarButtonItem?.enabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }
}


// MARK: - UICollectionView

extension NewAddPostViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        if indexPath.row == imageList.count {
            return collectionView.dequeueReusableCellWithReuseIdentifier("btnCell", forIndexPath: indexPath) as! UICollectionViewCell
        }else{
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ImageCollectionCell
            let image = imageList[indexPath.row]
            cell.imageView.image = image
            cell.whenDelete = { ()->() in
                self.imageList.remove(image)
                self.imageListView.reloadData()
                self.scrollToEnd()
            }
            return cell
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println(indexPath.row)
    }
    //移动到最后
    func scrollToEnd(){
        let section = imageListView.numberOfSections() - 1
        let item = imageListView.numberOfItemsInSection(section) - 1
        let lastIndexPath = NSIndexPath(forItem: item, inSection: section)
        
        imageListView.scrollToItemAtIndexPath(lastIndexPath, atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
    }
}


// MARK: - DBCameraViewControllerDelegate

extension NewAddPostViewController: DBCameraViewControllerDelegate {
    func camera(cameraViewController: AnyObject!, didFinishWithImage image: UIImage!, withMetadata metadata: [NSObject : AnyObject]!) {
        let image = image.scaleToFitSize(CGSize(width: MaxWidth, height: MaxWidth))
        
        let newImage = image.normalizedImage()
        
        self.imageList.append(newImage)
        imageListView.reloadData()
        self.scrollToEnd()
        self.dismissCamera(cameraViewController)
        
    }
    func dismissCamera(cameraViewController: AnyObject!) {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        cameraViewController.restoreFullScreenMode()
    }
}

