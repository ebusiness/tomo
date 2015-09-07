//
//  NotificationView.swift
//  Tomo
//
//  Created by starboychina on 2015/09/07.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NotificationView: UIView {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabelView: UILabel!
    @IBOutlet weak var messageLabelView: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    var timer: NSTimer?
    
    var userInfo: [NSObject : AnyObject]! {
        didSet {
            let payload = NotificationEntity(self.userInfo)
            if let photo = payload.from.photo {
                self.avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
            }
            
            self.nickNameLabelView.text = payload.from.nickName
            self.messageLabelView.text = payload.message
            gcd.async(.Default, delay: 5) {
                self.closeTapped()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gcd.async(.Main) {
            Util.changeImageColorForButton(self.closeButton, color: UIColor.whiteColor())
        }
        gcd.async(.Default) {
            self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2
            self.avatarImageView.layer.masksToBounds = true
            self.backgroundView.backgroundColor = Util.UIColorFromRGB(NavigationBarColorHex, alpha: 1)
        }
    }

    @IBAction func closeTapped() {
        gcd.async(.Default) {
            self.timer?.invalidate()
            let topConstraint: AnyObject? = self.superview!.constraints().find { $0.firstAttribute == .Top && $0.firstItem is NotificationView }
            if let topConstraint = topConstraint as? NSLayoutConstraint {
                gcd.sync(.Main) {
                    topConstraint.constant = -64
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.superview?.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
}