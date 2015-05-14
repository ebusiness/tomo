//
//  NewsfeedViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/02.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

enum NewsfeedDisplayMode {
    case Normal, Account, Detail, Group, Station
}

class NewsfeedViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var cellForHeight: NewsfeedCell!
    
    var frc: NSFetchedResultsController!
    var posts = [Post]()
    
    var user: User?
    var displayMode = NewsfeedDisplayMode.Normal
    
    var group: Group?
    var stationId: String?
    
    func isHeaderSection(section: Int) -> Bool {
        return displayMode == .Group && section == 0
    }
    
    var count: Int! {
        switch displayMode {
        case .Group, .Station:
            return posts.count
        default:
            return frc.fetchedObjects?.count ?? 0
        }
    }
    
    var objectChanges = Dictionary<NSFetchedResultsChangeType, [NSIndexPath]>()
    
    func postAtIndexPath(indexPath: NSIndexPath) -> Post {
        switch displayMode {
        case .Group, .Station:
            return posts[indexPath.row]
        default:
            return frc.objectAtIndexPath(indexPath) as! Post
        }
    }
    
    func rightBarButtonItem() -> UIBarButtonItem? {
        switch displayMode {
        case .Normal, .Account:
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
        
        if displayMode == .Normal {
            loadLocalData()
        } else if displayMode == .Group {
            ApiController.getPostOfGroup(group!.id!, done: { (posts, error) -> Void in
                if posts != nil {
                    self.posts = posts!
                    self.collectionView.reloadData()
                }
            })
        } else if displayMode == .Station {
            ApiController.getPostOfStation(self.stationId!, done: { (posts, error) -> Void in
                if posts != nil {
                    self.posts = posts!
                    self.collectionView.reloadData()
                }
            })
        }
        
        collectionView.registerNib(UINib(nibName: "NewsfeedCell", bundle: nil), forCellWithReuseIdentifier: "NewsfeedCell")
        
        setupLayout()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("becomeActive"), name: UIApplicationDidBecomeActiveNotification, object: nil)

    }
    
    func loadLocalData() {
        frc = DBController.newsfeeds(user)
        frc.delegate = self
    }
    
    func setupLayout() {
        collectionView.collectionViewLayout = CHTCollectionViewWaterfallLayout()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //refresh group title
        if displayMode == .Group && !isMovingToParentViewController() {
            collectionView.reloadSections(NSIndexSet(index: 0))
        } else if displayMode == .Normal {
            loadRemoteData()
        }
    }
    
    func loadRemoteData() {
        ApiController.getNewsfeed(user: user) { (error) -> Void in
            
        }
    }
    
    // MARK: - Notification
    
    func becomeActive() {
        if displayMode == .Normal {
            self.loadRemoteData()
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SeguePostDetail" {
            let vc = segue.destinationViewController as! PostDetailViewController
            vc.postId = sender as! String
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
        }, completion: nil)
    }
}

// MARK: - GroupPostsHeaderCellDelegate

extension NewsfeedViewController: GroupPostsHeaderCellDelegate {
    
    func joinBtnTapped() {
        ApiController.joinGroup(group!.id!, done: { (error) -> Void in
            self.collectionView.reloadSections(NSIndexSet(index: 0))
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
