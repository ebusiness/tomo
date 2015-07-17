//
//  NewAddPostViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import AssetsLibrary

class NewAddPostViewController: BaseViewController {
    
    
    @IBOutlet weak var postInput: UITextView!
    @IBOutlet weak var imageListView: UIScrollView!
    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var stationButton: UIButton!
    
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var groupName: UILabel!
    
    var imageList:[UIImage] = []
    var imageListSelected:[UIImage] = []
    var postContent: String?
    
    var groupListVC: GroupListViewController?
    var stationListVC: StationTableViewController?
    var selectedGroup: Group?
    var selectedStation: Station?
    
    override func viewDidLoad() {
        
        self.navigationController?.navigationBarHidden = true
        self.postInput.becomeFirstResponder()
        submitButton.enabled = false
        
        
        let color = Util.UIColorFromRGB(0xFF007AFF, alpha: 1)
        Util.changeImageColorForButton(stationButton,color: color)
        Util.changeImageColorForButton(groupButton,color: color)
        
        if DBController.myStations().count == 0 {
            stationButton.enabled = false
        }
        
        if DBController.myUser()?.groups.count == 0 {
            groupButton.enabled = false
        }
        getAllPhoto()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.selectedGroup = nil
        self.selectedStation = nil
        self.groupName.text = ""
        self.stationName.text = ""
        
        if let groupListVC = groupListVC, selectedGroup = groupListVC.selectedGroup {
            self.selectedGroup = selectedGroup
            self.groupListVC = nil
            self.groupName.text = selectedGroup.name
        }
        
        if let stationListVC = stationListVC, selectedStation = stationListVC.selectedStation {
            self.selectedStation = selectedStation
            self.stationListVC = nil
            self.stationName.text = selectedStation.name
        }
        self.postInput.becomeFirstResponder()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    @IBAction func post(sender: AnyObject) {
        
        // send post
        self.uploadToS3({ (imageNames, sizes) -> () in
            ApiController.addPost(imageNames, sizes: sizes, content: self.postContent!, groupId: self.selectedGroup?.id, stationId: self.selectedStation?.id,location: nil, done: { (error) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        })
        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.postInput.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func cameraOnClick(sender: AnyObject) {
        DBCameraController.openCamera(self, delegate: self)
    }
    
    @IBAction func groupTapped(sender: AnyObject) {
        //select group
        groupListVC = Util.createViewControllerWithIdentifier("GroupListViewController", storyboardName: "Group") as? GroupListViewController
        groupListVC!.showMyGroupOnly = true
        groupListVC!.selectedGroup = selectedGroup
        
        navigationController?.pushViewController(groupListVC!, animated: true)
    }
    
    @IBAction func stationTapped(sender: AnyObject) {
        //select station
        stationListVC = StationTableViewController()
        stationListVC?.displayMode = .MyStationOnly
        
        navigationController?.pushViewController(stationListVC!, animated: true)
    }
}


extension NewAddPostViewController {
    
    func getAllPhoto(){
        let library = ALAssetsLibrary()
        
        library.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos, usingBlock: {
            (group: ALAssetsGroup!, stop) in
            if group != nil {
                var assetBlock : ALAssetsGroupEnumerationResultsBlock = { (result: ALAsset!, index: Int, stop) in
                    if result != nil {
                        //var image = UIImage(CGImage:result.thumbnail().takeUnretainedValue())
                        var image = UIImage(CGImage:result.defaultRepresentation().fullScreenImage().takeUnretainedValue())
                        self.imageList.append(image!)
                    }
                }
                group.enumerateAssetsUsingBlock(assetBlock)
                self.setImageList()
            }
            }, failureBlock: { (fail) in
                println(fail)
        })
        
    }
    
    func setImageList(){
        
        for imageview in imageListView.subviews {
            imageview.removeFromSuperview()
        }
        
        let lv = imageListView.frame.size.width / imageListView.frame.size.height
        
        var scrollWidth:CGFloat = 0
        
        for i in 0..<imageList.count{
            let image = imageList[ imageList.count - i - 1 ]
            
            let imgView = UIImageView(frame: CGRectZero )
            imgView.image = image
            imgView.userInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: Selector("imageViewTapped:"))
            imgView.addGestureRecognizer(tap)

            imageListView.addSubview(imgView)
            
            imgView.setTranslatesAutoresizingMaskIntoConstraints(false)
            var width:CGFloat = imageListView.frame.size.width
            
            let w = image.size.width
            let h=image.size.height
            
            if  (w / h) > lv{
                width = w > imageListView.frame.size.width ? imageListView.frame.size.width : w
            }else{
                width = w / h * (h > imageListView.frame.size.height ? imageListView.frame.size.height : h)
            }
            
            imgView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: width))
            imageListView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Leading, relatedBy: .Equal, toItem: imageListView, attribute: .Leading, multiplier: 1.0, constant: scrollWidth ))
            
            scrollWidth += width + 5
            
            imageListView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Height, relatedBy: .Equal, toItem: imageListView, attribute: .Height, multiplier: 1.0, constant: 0))
            imageListView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .CenterY, relatedBy: .Equal, toItem: imageListView, attribute: .CenterY, multiplier: 1.0, constant: 0))
            
        }
        
        imageListView.contentSize.width = scrollWidth
    }
    
    
    func imageViewTapped(sender: UITapGestureRecognizer) {
        
        
        if let imageView = sender.view as? UIImageView,image = imageView.image {
            
            imageView.layer.borderColor = UIColor.redColor().CGColor
            
            if imageListSelected.contains(image) {
                imageListSelected.remove(image)
                imageView.layer.borderWidth = 0
                println("removed")
            } else {
                imageView.layer.borderWidth = 2
                imageListSelected.append(image)
                println("selected")
                
            }
        }
    }

    
    func uploadToS3(completion:(imageNames: [String], sizes: [CGSize])->()){
        var names: [String] = []
        var sizes: [CGSize] = []
        if imageListSelected.count == 0 {
            completion(imageNames: names,sizes: sizes)
            return
        }
        for image in imageListSelected {
            let name = NSUUID().UUIDString
            let imagePath = NSTemporaryDirectory() + name
            image.saveToPath(imagePath)
            
            let remotePath = Constants.postPath(fileName: name)
            
            S3Controller.uploadFile(name: name, localPath: imagePath, remotePath: remotePath, done: { (error) -> Void in
                names.append(name)
                sizes.append(image.size)
                if error == nil && sizes.count == self.imageListSelected.count {
                    completion(imageNames: names,sizes: sizes)
                }
            })
        }
        
    }
    
}

extension NewAddPostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        if postContent == nil || postContent!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        
        postContent = textView.text
        
        if postContent != nil && postContent!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            submitButton.enabled = true
        } else {
            submitButton.enabled = false
        }
    }
}



extension NewAddPostViewController: DBCameraViewControllerDelegate {
    
    func camera(cameraViewController: AnyObject!, didFinishWithImage image: UIImage!, withMetadata metadata: [NSObject : AnyObject]!) {
        let image = image.scaleToFitSize(CGSize(width: MaxWidth, height: MaxWidth))
        
        let newImage = image.normalizedImage()
        
        self.imageList.append(newImage)
        self.setImageList()
        self.dismissCamera(cameraViewController)
        
    }
    
    func dismissCamera(cameraViewController: AnyObject!) {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        cameraViewController.restoreFullScreenMode()
    }
}


extension NewAddPostViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
}