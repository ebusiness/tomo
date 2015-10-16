//
//  ProfileHeaderViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


import UIKit

class ProfileHeaderViewController: BaseViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    var photoImageViewTapped : ((sender: UITapGestureRecognizer)->())?
    var coverImageViewTapped : ((sender: UITapGestureRecognizer)->())?
    
    var user:UserEntity! {
        didSet {
            self.updateUI()
        }
    }
    private var isDidLoad = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        photoImageView.layer.cornerRadius = photoImageView.frame.size.width / 2
        photoImageView.layer.masksToBounds = true
        photoImageView.layer.borderWidth = 2
        photoImageView.layer.borderColor = avatarBorderColor
        
        self.isDidLoad = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI()
    }
    
    @IBAction func imageViewTapped(sender: UITapGestureRecognizer) {
        
        if sender.view == photoImageView {
            
            self.photoImageViewTapped?(sender: sender)
            
        } else if sender.view == coverImageView {
            
            self.coverImageViewTapped?(sender: sender)
            
        }
    }
}

extension ProfileHeaderViewController {
    
    func updateUI(){
        
        if !isDidLoad { return }
        
        if let photo = user.photo {
            photoImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
        }
        
        if let cover = user.cover {
            coverImageView.sd_setImageWithURL(NSURL(string: cover), placeholderImage: UIImage(named: "user_cover_default"))
        }
        nickNameLabel.text = user.nickName
        bioLabel.text = (user.bio ?? "" ).length > 0 ? user.bio : "一个彰显个性的签名."
    }
    
}