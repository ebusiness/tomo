//
//  ICYPostCell.swift
//  Tomo
//
//  Created by eagle on 15/10/5.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ICYPostCell: UITableViewCell {
    
    weak var delegate: UIViewController?
    
    var post: PostEntity? {
        didSet {
            if let post = post {
                // avatar
                majorAvatarImageView.sd_setImageWithURL(NSURL(string: post.owner.photo ?? ""), placeholderImage: UIImage(named: "avatar"))
                // name
                userNameLabel.text = post.owner.nickName
                // time
                dateLabel.text = post.createDate.relativeTimeToString()
                // bookmark
                let bookmarkImage = ( post.bookmark ?? [] ).contains(me.id) ? "star_filled" : "star"
                if let image = UIImage(named: bookmarkImage) {
                    let image = Util.coloredImage(image, color: UIColor.orangeColor())
                    collectionButton.setImage(image, forState: .Normal)
                }
                //like
                if let like = post.like where like.count > 0 {
                    likeButton.setTitle("\(like.count)", forState: .Normal)
                } else {
                    likeButton.setTitle("", forState: .Normal)
                }
                
                let likeImage = ( post.like ?? [] ).contains(me.id) ? "hearts_filled" : "hearts"
                if let image = UIImage(named: likeImage) {
                    let image = Util.coloredImage(image, color: UIColor.redColor())
                    likeButton.setImage(image, forState: .Normal)
                }
                // content
                contentLabel.text = post.content
                let contentWidth = screenWidth - 32.0
                let contentEstimatedSize = post.content.boundingRectWithSize(
                    CGSize(width: contentWidth, height: 2000000),
                    options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                    attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15)],
                    context: nil)
                
                
                contentHeight.constant = (contentEstimatedSize.height <= 200 ? contentEstimatedSize.height : 200) + 3
                // tag
                if nil != post.group {
                    collectionViewHeight.constant = 30.0
                } else {
                    collectionViewHeight.constant = 0.0
                }
                collectionView.reloadData()
                // comment
                if let lastComment = post.comments?.last {
                    commentViewHeight.constant = 56.0
                    minorAvatarImageViewHeight.constant = 40.0
                    
                    lastCommentAvatarImageView.sd_setImageWithURL(NSURL(string: lastComment.owner.photo ?? ""), placeholderImage: UIImage(named: "avatar"))
                    lastCommentContent.text = lastComment.content
                    lastCommentDateLabel.text = lastComment.createDate.relativeTimeToString()
                    commentCountButton.setTitle("\(post.comments!.count)", forState: UIControlState.Normal)
                    commentCountButton.setImage(UIImage(named: "comments"), forState: UIControlState.Normal)
                } else {
                    commentViewHeight.constant = CGFloat.almostZero
                    minorAvatarImageViewHeight.constant = 0.0
                    lastCommentAvatarImageView.image = nil
                    lastCommentContent.text = nil
                    lastCommentDateLabel.text = nil
                    commentCountButton.setTitle(nil, forState: UIControlState.Normal)
                    commentCountButton.setImage(nil, forState: UIControlState.Normal)
                }
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var majorAvatarImageView: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var collectionButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    /// TAG collection
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var lastCommentAvatarImageView: UIImageView!
    
    @IBOutlet weak var lastCommentContent: UILabel!
    
    @IBOutlet weak var lastCommentDateLabel: UILabel!
    
    @IBOutlet weak var commentCountButton: UIButton!
    
    @IBOutlet weak var commentView: UIView!
    

    
    @IBOutlet weak var flowLayout: ICYFlowLayout!
    
    
    
    
    // MARK: - Constraints
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var commentViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var minorAvatarImageViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    
    
    
    // MARK: - Actions
    
    @IBAction func bookmarkButtonPressed(sender: UIButton) {
        if let post = post {
            sender.userInteractionEnabled = false
            AlamofireController.request(.PATCH, "/posts/\(post.id)/bookmark", success: { _ in
                
                post.bookmark = post.bookmark ?? []
                
                if post.bookmark!.contains(me.id) {
                    post.bookmark!.remove(me.id)
                } else {
                    post.bookmark!.append(me.id)
                }
                self.post = post
                sender.tada {
                    sender.userInteractionEnabled = true
                }
            }) { _ in
                    sender.userInteractionEnabled = true
            }
        }
    }
    
    @IBAction func likeButtonPressed(sender: UIButton) {
        if let post = post {
            sender.userInteractionEnabled = false
            AlamofireController.request(.PATCH, "/posts/\(post.id)/like", success: { _ in
                
                if let like = post.like {
                    like.contains(me.id) ? post.like!.remove(me.id) : post.like!.append(me.id)
                } else {
                    post.like = [me.id]
                }
                sender.bounce{
                    self.post = post
                    sender.userInteractionEnabled = true
                }
            }) { _ in
                    sender.userInteractionEnabled = true
            }
        }
    }
    
    func majorAvatarTapped() {
        if let owner = post?.owner {
            let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
            vc.user = owner
            delegate?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func lastCommentAvatarTapped() {
        if let owner = post?.comments?.last?.owner {
            let vc = Util.createViewControllerWithIdentifier("ProfileView", storyboardName: "Profile") as! ProfileViewController
            vc.user = owner
            delegate?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func commentTapped() {
        if nil != post?.comments?.last {
            let vc = Util.createViewControllerWithIdentifier("PostView", storyboardName: "Home") as! PostViewController
            vc.post = post!
            vc.isCommentInitial = true
            delegate?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let affineTransform = CGAffineTransformScale(CGAffineTransformIdentity, -1, 1)
        collectionView.layer.setAffineTransform(affineTransform)
        
        let nib = UINib(nibName: "ICYTagCollectionViewCell", bundle: nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: ICYTagCollectionViewCell.identifier)
        
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 4.0, right: 0.0)
        
        // major avatar tap
        let majorAvatarTap = UITapGestureRecognizer(target: self, action: "majorAvatarTapped")
        majorAvatarImageView.addGestureRecognizer(majorAvatarTap)
        
        // minor avatar tap
        let lastCommentAvatarTap = UITapGestureRecognizer(target: self, action: "lastCommentAvatarTapped")
        lastCommentAvatarImageView.addGestureRecognizer(lastCommentAvatarTap)
        
        // comment tap
        let commentTap = UITapGestureRecognizer(target: self, action: "commentTapped")
        commentView.addGestureRecognizer(commentTap)
        
        collectionView.scrollsToTop = false
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension ICYPostCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if nil != post?.group {
            return 1
        } else {
            return 0
        }
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ICYTagCollectionViewCell.identifier, forIndexPath: indexPath) as! ICYTagCollectionViewCell
        if let group = post?.group {
            cell.tagButton.tomoTag = TomoTag(content: group)
            cell.tagButton.setTagClickAction({ (tomoTag) -> () in
                switch tomoTag.type {
                case .Group:
                    let group = tomoTag.content as! GroupEntity
                    let groupVC = Util.createViewControllerWithIdentifier("GroupDetailView", storyboardName: "Group") as! GroupDetailViewController
                    groupVC.group = group
                    self.delegate?.navigationController?.pushViewController(groupVC, animated: true)
                }
            })
        }
        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let tagString = post?.group?.name {
            let size = ICYTagButton.defaultSize(tagString)
            return size
        }
        return CGSizeZero
    }
}
