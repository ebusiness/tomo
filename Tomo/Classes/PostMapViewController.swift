//
//  PostMapViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/08/28.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class PostMapViewController: UIViewController {
    
    var post: PostEntity?
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAppearance()
        
        if let post = self.post {
            configDisplay(post)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

// MARK: - Internal Methods

extension PostMapViewController {
    
    private func setupAppearance() {
        
        self.avatarImageView.layer.borderWidth = 3
        self.avatarImageView.layer.borderColor = Util.UIColorFromRGB(NavigationBarColorHex, alpha: 1).CGColor
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.width / 2
        self.avatarImageView.layer.masksToBounds = true
        
        self.shadowView.layer.cornerRadius = 10
    }
    
    func configDisplay(post: PostEntity) {
        
        if post.images?.count > 0 {
            self.backgroundImageView.sd_setImageWithURL(NSURL(string: post.images!.first!))
        } else {
            self.backgroundImageView.sd_setImageWithURL(NSURL(string: post.owner.cover!))
        }

        self.avatarImageView.sd_setImageWithURL(NSURL(string: post.owner.photo!))
        self.postContentLabel.text = post.content
    }
}