//
//  NewsfeedViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/02.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NewsfeedViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var cellForHeight: NewsfeedCell!
    
    var postsFRC: NSFetchedResultsController!
    
    var user: User?
    
    var count: Int {
        return (postsFRC.sections as! [NSFetchedResultsSectionInfo])[0].numberOfObjects
    }
    
    var objectChanges = Dictionary<NSFetchedResultsChangeType, [NSIndexPath]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if user != nil {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil
        }
        
        loadLocalData()
        
        collectionView.registerNib(UINib(nibName: "NewsfeedCell", bundle: nil), forCellWithReuseIdentifier: "NewsfeedCell")
        
        setupLayout()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("becomeActive"), name: UIApplicationDidBecomeActiveNotification, object: nil)

    }
    
    func loadLocalData() {
        postsFRC = DBController.newsfeeds(user: user)
        postsFRC.delegate = self
    }
    
    func setupLayout() {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.collectionViewLayout = layout
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadRemoteData()
    }
    
    func loadRemoteData() {
        ApiController.getNewsfeed(user: user) { (error) -> Void in
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notification
    
    func becomeActive() {
        loadRemoteData()
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SeguePostDetail" {
            let vc = segue.destinationViewController as! PostDetailViewController
            vc.postId = sender as! String
        }
    }
    
    // MARK: - Action
    
    @IBAction func debug(sender: AnyObject) {
        let debug = Util.createViewControllerWithIdentifier(nil, storyboardName: "Debug")
        debug.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        presentViewController(debug, animated: true, completion: nil)
    }
    
    @IBAction func addPostBtnTapped(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "写真を撮る", style: .Default, handler: { (action) -> Void in
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.delegate = self
            self.presentViewController(picker, animated: true, completion: nil)
        })
        let albumAction = UIAlertAction(title: "写真から選択", style: .Default, handler: { (action) -> Void in
            let picker = UIImagePickerController()
            picker.sourceType = .PhotoLibrary
            picker.delegate = self
            self.presentViewController(picker, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: { (action) -> Void in
            
        })
        
        alertController.addAction(cameraAction)
        alertController.addAction(albumAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionView

extension NewsfeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let post = postsFRC.objectAtIndexPath(indexPath) as! Post
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NewsfeedCell", forIndexPath: indexPath) as! NewsfeedCell
        
        cell.post = post
        
        cell.configCellForShow()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let post = postsFRC.objectAtIndexPath(indexPath) as! Post
        
        performSegueWithIdentifier("SeguePostDetail", sender: post.id!)
    }
}

// MARK: - layout

extension NewsfeedViewController: CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        
        let post = postsFRC.objectAtIndexPath(indexPath) as! Post
        
        if cellForHeight == nil {
            cellForHeight = Util.createViewWithNibName("NewsfeedCell") as! NewsfeedCell
        }
        
        let cellWidth = (collectionView.bounds.width - 3 * 10) / 2

        cellForHeight.post = post
        
        var size = cellForHeight.sizeOfCell(cellWidth)
        size.width = cellWidth
        
        return size
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension NewsfeedViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        objectChanges.removeAll(keepCapacity: false)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        if objectChanges[type] == nil {
            objectChanges[type] = [NSIndexPath]()
        }

        switch type {
        case .Insert:
            if let newIndexPath = newIndexPath {
                objectChanges[type]!.append(newIndexPath)
            }
        case .Delete:
            if let indexPath = indexPath {
                objectChanges[type]!.append(indexPath)
            }
        case .Update:
            if let indexPath = indexPath {
                objectChanges[type]!.append(indexPath)
            }
        case .Move:
            // TODO: 
            println("move")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // TODO: move,update,delete
        
        collectionView.performBatchUpdates({ () -> Void in
            let insertedItems = self.objectChanges[.Insert]
            if insertedItems?.count > 0 {
                self.collectionView.insertItemsAtIndexPaths(insertedItems!)
            }
        }, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension NewsfeedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let image = image.scaleToFitSize(CGSize(width: MaxWidth, height: MaxWidth))
        
        let name = NSUUID().UUIDString
        let path = NSTemporaryDirectory() + name
        
        let newImage = image.normalizedImage()

        newImage.saveToPath(path)
        
        picker.dismissViewControllerAnimated(false, completion: { () -> Void in
            let vcNavi = Util.createViewControllerWithIdentifier(nil, storyboardName: "AddPost") as! UINavigationController
            
            let vc = vcNavi.topViewController as! AddPostViewController
            vc.imagePath = path
            self.presentViewController(vcNavi, animated: true, completion: nil)
        })
    }
}

