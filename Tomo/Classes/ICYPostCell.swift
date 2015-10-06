//
//  ICYPostCell.swift
//  Tomo
//
//  Created by eagle on 15/10/5.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ICYPostCell: UITableViewCell {
    
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
                // tag
                if let group = post.group {
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
                    commentViewHeight.constant = CGFloat.relativeZero
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
    @IBOutlet private weak var majorAvatarImageView: UIImageView!
    
    @IBOutlet private weak var contentLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var collectionButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var lastCommentAvatarImageView: UIImageView!
    
    @IBOutlet weak var lastCommentContent: UILabel!
    
    @IBOutlet weak var lastCommentDateLabel: UILabel!
    
    @IBOutlet weak var commentCountButton: UIButton!
    
    @IBOutlet weak var flowLayout: ICYFlowLayout!
    
    
    
    
    // MARK: - Constraints
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var commentViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var minorAvatarImageViewHeight: NSLayoutConstraint!
    
    // MARK: - Actions
    
    @IBAction func bookmarkButtonPressed(sender: UIButton) {
        if var post = post {
            sender.userInteractionEnabled = false
            AlamofireController.request(.PATCH, "/posts/\(post.id)/bookmark", success: { _ in
                
                me.bookmark = me.bookmark ?? []
                post.bookmark = post.bookmark ?? []
                
                if me.bookmark!.contains(post.id) {
                    me.bookmark!.remove(post.id)
                    post.bookmark!.remove(me.id)
                } else {
                    me.bookmark!.append(post.id)
                    post.bookmark!.append(me.id)
                }
                self.post = post
                sender.tada {
                    sender.userInteractionEnabled = true
                }
                }) { err in
                    sender.userInteractionEnabled = true
            }
        }
    }
    
    @IBAction func likeButtonPressed(sender: UIButton) {
        if var post = post {
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
                }) { err in
                    sender.userInteractionEnabled = true
            }
        }
    }
    
    
    
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let affineTransform = CGAffineTransformScale(CGAffineTransformIdentity, -1, 1)
        collectionView.layer.setAffineTransform(affineTransform)
        
        let nib = UINib(nibName: "ICYTagCollectionViewCell", bundle: nil)
        collectionView.registerNib(nib, forCellWithReuseIdentifier: ICYTagCollectionViewCell.identifier)
        
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 4.0, right: 0.0)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension ICYPostCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let group = post?.group {
            return 1
        } else {
            return 0
        }
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ICYTagCollectionViewCell.identifier, forIndexPath: indexPath) as! ICYTagCollectionViewCell
        cell.tagButton.tagString = post?.group?.name
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
