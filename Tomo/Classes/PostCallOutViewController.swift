//
//  PostCallOutViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/10/01.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PostCallOutViewController: UIViewController {
    
    var postAnnotation: PostAnnotation!

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDisplay()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupDisplay() {
        
        let post = postAnnotation.post
        
        self.avatarImageView.layer.borderColor = avatarBorderColor
        
        if let image = post.images?.first {
            self.coverImageView.sd_setImageWithURL(NSURL(string: image), placeholderImage: DefaultCoverImage)
        } else if let cover = post.owner.cover {
            self.coverImageView.sd_setImageWithURL(NSURL(string: cover), placeholderImage: DefaultCoverImage)
        }
        
        if let photo = post.owner.photo {
            self.avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
        }
        
        self.userNameLabel.text = post.owner.nickName
        
        self.dateTimeLabel.text = post.createDate.relativeTimeToString()
        
        self.contentLabel.text = post.content
        
        if let like = post.like where like.count > 0 {
            likeButton.setTitle("\(like.count)", forState: .Normal)
        } else {
            likeButton.setTitle("", forState: .Normal)
        }
        
        let likeimage = ( post.like ?? [] ).contains(me.id) ? "hearts_filled" : "hearts"
        if let image = UIImage(named: likeimage) {
            
            let image = Util.coloredImage(image, color: UIColor.redColor())
            likeButton.setImage(image, forState: .Normal)
            
        }
        
        let bookmarkimage = ( post.bookmark ?? [] ).contains(me.id) ? "star_filled" : "star"
        
        if let image = UIImage(named: bookmarkimage) {
            let image = Util.coloredImage(image, color: UIColor.orangeColor())
            bookmarkButton.setImage(image, forState: .Normal)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
