//
//  AddPostViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import AssetsLibrary

class AddPostViewController: BaseViewController {
    
    
    @IBOutlet weak var postInput: UITextView!
    @IBOutlet weak var imageListView: UIScrollView!
    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var stationButton: UIButton!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var groupName: UILabel!
    
    var assetUrlList: [NSURL?] = []
    var imageList:[UIImage] = []
    var imageListSelected:[UIImage] = []
    var postContent: String?
    
    private var locationManager: CLLocationManager?
    private var location: CLLocation?
    
    override func viewDidLoad() {
        
        self.navigationController?.navigationBarHidden = true
        self.postInput.becomeFirstResponder()
        submitButton.enabled = false
        
        self.setLocationManager()
        
        let color = Util.UIColorFromRGB(0xFF007AFF, alpha: 1)
        Util.changeImageColorForButton(stationButton,color: color)
        Util.changeImageColorForButton(groupButton,color: color)
        
        self.getAllPhoto()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.postInput.becomeFirstResponder()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    @IBAction func post(sender: AnyObject) {
        Util.showHUD()
        // send post
        self.uploadToS3 { (imagelist) -> () in
            
            var param = Dictionary<String, AnyObject>()
            param["content"] = self.postContent!
            param["images"] = imagelist
            
            if let location = self.location {
                param["coordinate"] = [String(stringInterpolationSegment: location.coordinate.latitude),String(stringInterpolationSegment: location.coordinate.longitude)];
            }
            
            Manager.sharedInstance.request(.POST, kAPIBaseURLString + "/mobile/posts" , parameters: param,encoding: ParameterEncoding.JSON)
            .responseJSON { (_, _, post, _) -> Void in
                Util.dismissHUD()
                self.performSegueWithIdentifier("addedPost", sender: post)
//                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.postInput.resignFirstResponder()
        self.performSegueWithIdentifier("addedPost", sender: nil)
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addedPost" {
            if let sender: AnyObject = sender, home = segue.destinationViewController as? HomeViewController {
                
                let json = JSON(sender)
                
                var post = PostEntity()
                post.id = json["_id"].stringValue
                post.content = json["contentText"].stringValue
                post.coordinate = json["coordinate"].arrayObject as? [Double]
                json["images_mobile"].array?.map { (image) -> () in
                    post.images = post.images ?? [String]()
                    post.images?.append(image["name"].stringValue)
                }
//                post.like = json["like"].arrayObject as? [String]
                post.createDate = json["createDate"].stringValue.toDate(format: "yyyy-MM-dd't'HH:mm:ss.SSSZ")
                post.owner = me
                
                
                home.contents.insert(post, atIndex: 0)
                home.latestContent = post
                home.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Middle)
            }
        }
    }
    
    @IBAction func cameraOnClick(sender: AnyObject) {
        
        var optional = Dictionary<String,((UIAlertAction!) -> Void)!>()
        
        
        let avstatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        if avstatus !=  .NotDetermined && avstatus !=  .Authorized {
            Util.showInfo("请允许本App使用相机")
        } else {
            
            optional["拍摄"] = { (_) -> () in
                DBCameraController.openCamera(self, delegate: self)
            }
            
        }
        
        let status = ALAssetsLibrary.authorizationStatus()
        if status != .NotDetermined && status != .Authorized {
            Util.showInfo("请允许本App访问相册")
        } else {
            
            optional["从相册选择"] = { (_) -> () in
                DBCameraController.openLibrary(self, delegate: self)
            }
        }
        
        if optional.count > 0 {
            
            Util.alertActionSheet(self, optionalDict:optional)
            
        }
        
    }
    
    @IBAction func groupTapped(sender: AnyObject) {

    }
    
    @IBAction func stationTapped(sender: AnyObject) {

    }
    
    @IBAction func viewPanGesture(sender: UIPanGestureRecognizer) {
        
    }
}


extension AddPostViewController {
    
    func getAllPhoto(){
        let library = ALAssetsLibrary()
        
        library.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos, usingBlock: {
            (group: ALAssetsGroup!, stop) in
            if let group = group {
                var assetBlock : ALAssetsGroupEnumerationResultsBlock = { (result: ALAsset!, index: Int, stop) in
                    if result != nil && self.assetUrlList.count < 20 {
                        self.assetUrlList.append(result.defaultRepresentation().url())
//                        var image = UIImage(CGImage:result.defaultRepresentation().fullScreenImage().takeUnretainedValue())
                        var image = UIImage(CGImage:result.thumbnail().takeUnretainedValue())
                        self.imageList.append(image!)
                    }
                }
                group.setAssetsFilter(ALAssetsFilter.allPhotos())
                group.enumerateAssetsWithOptions(.Reverse, usingBlock: assetBlock)
                self.setImageList()
            }
            }, failureBlock: { (fail) in
                
                self.hideHeaderView(self.imageList.count == 0)
        })
        
    }
    
    func setImageList(){
        
        for imageview in imageListView.subviews {
            imageview.removeFromSuperview()
        }
        if self.imageList.count < 1 {
            self.hideHeaderView(true,animated: false)
            return
        }
        
        let height = imageListView.frame.size.height
        let width = height / 3 * 4
        
        var scrollWidth:CGFloat = 0
        
        for i in 0..<self.imageList.count{
            let image = self.imageList[ i ]
            
            let imgView = UIImageView(frame: CGRectZero )
            imgView.image = image
            imgView.tag = i
            
            imgView.contentMode = UIViewContentMode.ScaleAspectFill
            imgView.clipsToBounds = true
            
            if imageListSelected.contains(image) {
                imgView.layer.borderColor = UIColor.redColor().CGColor
                imgView.layer.borderWidth = 2
            }

            let tap = UITapGestureRecognizer(target: self, action: Selector("imageViewTapped:"))
            imgView.userInteractionEnabled = true
            imgView.addGestureRecognizer(tap)
            
            imageListView.addSubview(imgView)
            
            imgView.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            imgView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: width))
            imageListView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Leading, relatedBy: .Equal, toItem: imageListView, attribute: .Leading, multiplier: 1.0, constant: scrollWidth ))
            
            scrollWidth += width + 5
            
            imageListView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Height, relatedBy: .Equal, toItem: imageListView, attribute: .Height, multiplier: 1.0, constant: 0))
            imageListView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .CenterY, relatedBy: .Equal, toItem: imageListView, attribute: .CenterY, multiplier: 1.0, constant: 0))
            
        }
        
        imageListView.contentSize.width = scrollWidth
    }
    
    func imageViewTapped(sender: UITapGestureRecognizer) {
        
        
        if let imageView = sender.view as? UIImageView where self.assetUrlList.count > imageView.tag {
            
            if let url = self.assetUrlList[imageView.tag] {
            
            let library = ALAssetsLibrary()
                library.assetForURL(url, resultBlock: { (asset) -> Void in
                    
                    let image = UIImage(CGImage:asset.defaultRepresentation().fullScreenImage().takeUnretainedValue())!
                    
                    imageView.layer.borderColor = UIColor.redColor().CGColor
                    
                    if self.imageListSelected.contains(image) {
                        self.imageListSelected.remove(image)
                        imageView.layer.borderWidth = 0
                    } else {
                        imageView.layer.borderWidth = 2
                        self.imageListSelected.append(image)
                        
                    }
                    }, failureBlock: { (error) -> Void in
                        
                })
            }
        }
    }

    
    func uploadToS3(completion:(imagelist: AnyObject)->()){
        var imagelist = [[String:AnyObject]]()
        if imageListSelected.count == 0 {
            completion(imagelist: imagelist)
            return
        }
        for image in imageListSelected {
            let name = NSUUID().UUIDString
            let imagePath = NSTemporaryDirectory() + name
            image.saveToPath(imagePath)
            
            let remotePath = Constants.postPath(fileName: name)
            
            S3Controller.uploadFile(name: name, localPath: imagePath, remotePath: remotePath, done: { (error) -> Void in
                
                let imageinfo:[String:AnyObject] = [
                    "name":name,
                    "size":[
                        "width":image.size.width,
                        "height":image.size.height
                    ]
                ]
                imagelist.append(imageinfo)
                
                if error == nil && imagelist.count == self.imageListSelected.count {
                    completion(imagelist: imagelist)
                }
            })
        }
        
    }
    
    func hideHeaderView(hidden:Bool,animated:Bool = true){
        
        self.headerHeight.constant = hidden ? 44 : 138
        
        if animated {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
        
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
            submitButton.enabled = true
        } else {
            submitButton.enabled = false
        }
    }
}



extension AddPostViewController: DBCameraViewControllerDelegate {
    
    func camera(cameraViewController: AnyObject!, didFinishWithImage image: UIImage!, withMetadata metadata: [NSObject : AnyObject]!) {
        let image = image.scaleToFitSize(CGSize(width: MaxWidth, height: MaxWidth * image.size.height / image.size.width ))
        
        let newImage = image.normalizedImage()
        
        self.imageList.insert(newImage, atIndex: 0)
        self.assetUrlList.insert(nil, atIndex: 0)
        self.imageListSelected.append(newImage)
        self.insertIntoImageListView (image: newImage)
        self.hideHeaderView(false)
        
        self.dismissCamera(cameraViewController)
        
    }
    
    func dismissCamera(cameraViewController: AnyObject!) {
        self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        cameraViewController.restoreFullScreenMode()
    }
    
    func insertIntoImageListView (#image: UIImage!){
        
        self.imageListView.setContentOffset(CGPointZero, animated: true)
        
        let height = imageListView.frame.size.height
        let width = height / 3 * 4
        
        let constraints = self.imageListView.constraints().filter{ $0.firstAttribute == .Leading }
        
        for constraint in constraints {
            if let constraint = constraint as? NSLayoutConstraint {
                constraint.constant = constraint.constant + width + 5
            }
        }
        
        let imgView = UIImageView(frame: CGRectZero )
        imgView.image = image
        imgView.contentMode = UIViewContentMode.ScaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.borderColor = UIColor.redColor().CGColor
        imgView.layer.borderWidth = 2
        let tap = UITapGestureRecognizer(target: self, action: Selector("imageViewTapped:"))
        imgView.userInteractionEnabled = true
        imgView.addGestureRecognizer(tap)
        
        self.imageListView.addSubview(imgView)
        
        imgView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        imgView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: width))
        imageListView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Leading, relatedBy: .Equal, toItem: imageListView, attribute: .Leading, multiplier: 1.0, constant: 0 ))
        imageListView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Height, relatedBy: .Equal, toItem: imageListView, attribute: .Height, multiplier: 1.0, constant: 0))
        imageListView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .CenterY, relatedBy: .Equal, toItem: imageListView, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
        imageListView.contentSize.width = imageListView.contentSize.width + width + 5
    }
}

extension AddPostViewController:CLLocationManagerDelegate{
    
    func setLocationManager() {
        
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
        
        //check for description key and ask permissions
        if (NSBundle.mainBundle().objectForInfoDictionaryKey("NSLocationWhenInUseUsageDescription") != nil) {
            self.locationManager!.requestWhenInUseAuthorization()
        } else if (NSBundle.mainBundle().objectForInfoDictionaryKey("NSLocationAlwaysUsageDescription") != nil) {
            self.locationManager!.requestAlwaysAuthorization()
        } else {
            fatalError("To use location in iOS8 you need to define either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription in the app bundle's Info.plist file")
        }
        
    }
    
    //location authorization status changed
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse,.AuthorizedAlways:
            manager.startUpdatingLocation()
        case .Denied:
            break
        default:
            break
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        if let location = locations[0] as? CLLocation {
            self.location = location
        } else {
            println("can not get location")
        }
    }
    
}
