//
//  PostDetailHeaderView.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/06.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

@objc protocol PostDetailHeaderViewDelegate {
    func commentBtnTapped()
    func avatarImageTapped()
    func imageViewTapped(imageView: UIImageView)
    func shareBtnTapped()
    func deleteBtnTapped()
}

class PostDetailHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postImageList: UIScrollView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var commentsCount: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var postImageViewHeightConstraint: NSLayoutConstraint!
    

    weak var delegate: PostDetailHeaderViewDelegate?
    
    var layoutSize: CGSize!
    
    override func awakeFromNib() {
        avatarImageView.layer.cornerRadius = 18.0
        avatarImageView.layer.masksToBounds = true
        
        postImageList.delegate = self
        
    }
    
    
    var viewWidth: CGFloat!
    
    var post: Post! {
        didSet {
            if let photo_ref = post.owner?.photo_ref {
                avatarImageView.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
            }
            
            userName.text = post.owner?.nickName
            timeLabel.text = Util.displayDate(post.createDate)
            
            contentLabel.text = post.content
            
            self.setImageList()
            
            commentsCount.text = "\(post.comments.count)"
            
            deleteBtn.hidden = !post.isMyPost
        }
    }

    var viewHeight: CGFloat! {
        get {
            contentLabel.preferredMaxLayoutWidth = viewWidth - 2*8
            
            let size = self.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize) as CGSize
            
            return size.height
        }
    }

    // MARK: - Action
    
    @IBAction func commentBtnTapped(sender: AnyObject) {
        delegate?.commentBtnTapped()
    }
    
    @IBAction func avatarImageTapped(sender: UITapGestureRecognizer) {
        delegate?.avatarImageTapped()
    }
    
    @IBAction func postImageViewTapped(sender: UITapGestureRecognizer) {
        //delegate?.imageViewTapped(postImageView)
    }
    
    @IBAction func shareBtnTapped(sender: AnyObject) {
        delegate?.shareBtnTapped()
    }
    
    @IBAction func deleteBtnTapped(sender: UIButton) {
        delegate?.deleteBtnTapped()
    }
}

extension PostDetailHeaderView {

    func setImageList(){
        
        if post.imagesmobile.count < 10 {
            //hide [postImageList] when imagesmobile.count
            postImageList.addConstraint(NSLayoutConstraint(item: postImageList, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0))
            return
        }
        
        let lv = postImageList.frame.size.width/postImageList.frame.size.height
        
        var scrollWidth:CGFloat = 0
        
        for i in 0..<post.imagesmobile.count{
            
            if let image = post.imagesmobile[i] as? Images{
                let imgView = UIImageView(frame: CGRectZero )
                imgView.setImageWithURL(NSURL(string: image.name! ), completed: { (image, error, cacheType, url) -> Void in
                    }, usingActivityIndicatorStyle: .Gray)
                
                postImageList.addSubview(imgView)
                imgView.setTranslatesAutoresizingMaskIntoConstraints(false)
                
                var width:CGFloat = postImageList.frame.size.width
                var height:CGFloat = postImageList.frame.size.height
                
                if let w = image.width as? CGFloat,h=image.height as? CGFloat{
                    
                    if  (w / h) > lv{
                        width = w > postImageList.frame.size.width ? postImageList.frame.size.width : w
                        height = h / w * width
                    }else{
                        
                        height = h > postImageList.frame.size.height ? postImageList.frame.size.height : h
                        width = w / h * height
                    }
                }
                
                imgView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: width))
                imgView.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: height))
                
                
                postImageList.addConstraint(NSLayoutConstraint(item: imgView, attribute: .CenterY, relatedBy: .Equal, toItem: postImageList, attribute: .CenterY, multiplier: 1.0, constant: 0))
                
                postImageList.addConstraint(NSLayoutConstraint(item: imgView, attribute: .Leading, relatedBy: .Equal, toItem: postImageList, attribute: .Leading, multiplier: 1.0, constant: scrollWidth ))
                
                
                scrollWidth += width + 5
            }
            
        }
        
        postImageList.contentSize.width = scrollWidth
    }
    
}

extension PostDetailHeaderView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {

    }
}