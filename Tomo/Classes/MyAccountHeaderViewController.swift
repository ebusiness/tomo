//
//  MyAccountHeaderViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


import UIKit

class MyAccountHeaderViewController: BaseViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    var photoImageViewTapped : ((sender: UITapGestureRecognizer)->())?
    var coverImageViewTapped : ((sender: UITapGestureRecognizer)->())?
    
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

extension MyAccountHeaderViewController {
    
    func updateUI(){
        
        photoImageView.layer.cornerRadius = photoImageView.frame.size.width / 2
        photoImageView.layer.masksToBounds = true
        photoImageView.layer.borderWidth = 1
        photoImageView.layer.borderColor = UIColor.whiteColor().CGColor
        
        if let photo = me.photo {
            photoImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
        }
        
        if let cover = me.cover {
            coverImageView.sd_setImageWithURL(NSURL(string: cover), placeholderImage: DefaultAvatarImage)
        }
        nickNameLabel.text = me.nickName
        bioLabel.text = me.bio
    }
    
}