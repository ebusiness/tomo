//
//  NewsfeedViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/02.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

enum NewsfeedDisplayMode {
    case Newsfeed, Account, User, Group, Station
}

class NewsfeedViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var cellForHeight: NewsfeedCell!
    
    var frc: NSFetchedResultsController!
    var posts = [Post]()
    
    var user: User?
    var displayMode = NewsfeedDisplayMode.Newsfeed
    
    var group: Group?
    var stationCondition: Dictionary<String, String>?
    
    var postForDelete: Post?
    
    func isHeaderSection(section: Int) -> Bool {
        return displayMode == .Group && section == 0
    }
    
    var count: Int! {
        switch displayMode {
        case .Newsfeed, .Account:
            return frc.fetchedObjects?.count ?? 0
        default:
            return posts.count
        }
    }
    
    var objectChanges = Dictionary<NSFetchedResultsChangeType, [NSIndexPath]>()
    
    func postAtIndexPath(indexPath: NSIndexPath) -> Post {
        switch displayMode {
        case .Newsfeed, .Account:
            return frc.objectAtIndexPath(indexPath) as! Post
        default:
            return posts[indexPath.row]
        }
    }
    
    func rightBarButtonItem() -> UIBarButtonItem? {
        switch displayMode {
        case .Newsfeed, .Account:
            return UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: Selector("addPostBtnTapped:"))
        case .Group:
            if let group = group where group.participants.count > 1 {
                return UIBarButtonItem(title: "チャット", style: .Plain, target: self, action: Selector("groupChat"))
            }
            return nil
        default:
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = rightBarButtonItem()
        
        loadLocalDataOrRemote()
        
        if displayMode == .Account {
            let lpgr = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
            lpgr.minimumPressDuration = 1
            lpgr.delegate = self
            collectionView.addGestureRecognizer(lpgr)
        }
        
        collectionView.registerNib(UINib(nibName: "NewsfeedCell", bundle: nil), forCellWithReuseIdentifier: "NewsfeedCell")
        
        setupLayout()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("becomeActive"), name: UIApplicationDidBecomeActiveNotification, object: nil)

    }
    
    func loadLocalDataOrRemote() {
        switch displayMode {
        case .Newsfeed:
            frc = DBController.newsfeeds()
            frc.delegate = self
        case .Account:
            frc = DBController.myPosts()
            frc.delegate = self
            
            ApiController.getPostOfUser(user!.id!, done: { (posts, error) -> Void in
            })
        case .User:
            ApiController.getPostOfUser(user!.id!, done: { (posts, error) -> Void in
                if posts != nil {
                    self.posts = posts!
                    self.collectionView.reloadData()
                }
            })
        case .Group:
            ApiController.getPostOfGroup(group!.id!, done: { (posts, error) -> Void in
                if posts != nil {
                    self.posts = posts!
                    self.collectionView.reloadData()
                }
            })
        case .Station:
            ApiController.getPostOfStation(self.stationCondition!, done: { (posts, error) -> Void in
                if posts != nil {
                    self.posts = posts!
                    self.collectionView.reloadData()
                }
            })
        }
    }
    
    func setupLayout() {
        collectionView.collectionViewLayout = CHTCollectionViewWaterfallLayout()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //refresh group title
        if displayMode == .Group && !isMovingToParentViewController() {
            reloadHeaderSection()
        } else if displayMode == .Newsfeed {
            loadRemoteData()
        }
    }
    
    func reloadHeaderSection() {
        self.collectionView.reloadSections(NSIndexSet(index: 0))
        navigationItem.rightBarButtonItem = rightBarButtonItem()
    }
    
    func loadRemoteData() {
        ApiController.getNewsfeed() { (error) -> Void in
            
        }
    }
    
    // MARK: - Notification
    
    func becomeActive() {
        if displayMode == .Newsfeed {
            self.loadRemoteData()
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SeguePostDetail" {
            let vc = segue.destinationViewController as! PostDetailViewController
            vc.postId = sender as! String
        }
        
        if segue.identifier == "SegueGroupSetting" {
            let vc = segue.destinationViewController as! GroupSettingViewController
            vc.group = group
        }
    }
    
    // MARK: - Action
    
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
    
    func groupChat() {
        let vc = Util.createViewControllerWithIdentifier("MessageGroupViewController", storyboardName: "Message") as! MessageGroupViewController
        vc.group = group
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleLongPress(ges: UILongPressGestureRecognizer) {
        if ges.state == .Cancelled {
            return
        }
        
        let point = ges.locationInView(collectionView)
        if let indexPath = collectionView.indexPathForItemAtPoint(point) {
            postForDelete = frc.objectAtIndexPath(indexPath) as? Post
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let delAction = UIAlertAction(title: "削除", style: .Destructive, handler: { (action) -> Void in
                if let post = self.postForDelete {
                    post.MR_deleteEntity()
                    DBController.save()
                    
                    //call api
                    ApiController.postDelete(post.id!, done: { (_) -> Void in
                        
                    })
                }
            })

            let cancelAction = UIAlertAction(title: "キャンセル", style: .Cancel, handler: { (action) -> Void in
                
            })
            
            alertController.addAction(delAction)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - UICollectionView

extension NewsfeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return displayMode == .Group ? 2 : 1
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        if isHeaderSection(section) {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isHeaderSection(section) {
            return 1
        }
        
        return count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if isHeaderSection(indexPath.section) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GroupPostsHeaderCell", forIndexPath: indexPath) as! GroupPostsHeaderCell
            
            cell.group = group!
            cell.delegate = self
            
            return cell
        }
        
        let post = postAtIndexPath(indexPath)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("NewsfeedCell", forIndexPath: indexPath) as! NewsfeedCell
        
        cell.post = post
        
        cell.configCellForShow()
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if isHeaderSection(indexPath.section) {
            if group?.owner?.id == Defaults["myId"].string {
                let vc = Util.createViewControllerWithIdentifier("GroupAddTableViewController", storyboardName: "Group") as! GroupAddTableViewController
                vc.group = group!
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return
        }
        
        let post = postAtIndexPath(indexPath)
        
        performSegueWithIdentifier("SeguePostDetail", sender: post.id!)
    }
}

// MARK: - layout

extension NewsfeedViewController: CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, columnCountForSection section: Int) -> Int {
        if isHeaderSection(section) {
            return 1
        }
        
        return 2
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        if isHeaderSection(indexPath.section) {
            return CGSize(width: collectionView.bounds.width, height: GroupPostsHeaderCell.height(group: group!))
        }
        
        let post = postAtIndexPath(indexPath)
        
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
            
            let deleteItems = self.objectChanges[.Delete]
            if deleteItems?.count > 0 {
                self.collectionView.deleteItemsAtIndexPaths(deleteItems!)
            }
            
        }, completion: nil)
    }
}

// MARK: - GroupPostsHeaderCellDelegate

extension NewsfeedViewController: GroupPostsHeaderCellDelegate {
    
    func joinBtnTapped() {
        ApiController.joinGroup(group!.id!, done: { (error) -> Void in
            self.reloadHeaderSection()
        })
    }
    
    func didTapMemberListOfGroupPostsHeaderCell(cell: GroupPostsHeaderCell) {
        let vc = Util.createViewControllerWithIdentifier("FriendListViewController", storyboardName: "Chat") as! FriendListViewController
        vc.displayMode = .List
        vc.users = cell.group.participants.array as! [User]
        self.navigationController?.pushViewController(vc, animated: true)
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

// MARK: - UIGestureRecognizerDelegate

extension NewsfeedViewController: UIGestureRecognizerDelegate {
    
    
}
