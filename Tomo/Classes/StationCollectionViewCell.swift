//
//  StationCollectionViewCell.swift
//  Tomo
//
//  Created by ebuser on 2015/09/24.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class StationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var watchButton: UIButton!
    
    var group: GroupEntity!

    private var isWatched = false

    func setupDisplay() {

        self.nameLabel.text = self.group.name

        backgroundImageView.sd_setImageWithURL(NSURL(string: group.cover), placeholderImage: TomoConst.Image.DefaultGroup)

        self.contentView.layer.cornerRadius = 5
        self.contentView.clipsToBounds = true

        watchButton.layer.borderColor = UIColor.whiteColor().CGColor
        watchButton.layer.borderWidth = 1
        watchButton.layer.cornerRadius = 2

        guard let myGroup = me.groups else {
            self.isWatched = false
            return
        }

        if myGroup.contains(self.group.id) {

            self.isWatched = true
            self.watchButton.backgroundColor = Palette.Red.primaryColor
            self.watchButton.setTitle("  取消关注  ", forState: .Normal)
            self.watchButton.sizeToFit()

        } else {

            self.isWatched = false
            self.watchButton.backgroundColor = Palette.Green.primaryColor
            self.watchButton.setTitle("  关注  ", forState: .Normal)
            self.watchButton.sizeToFit()
        }
    }

    @IBAction func watchButtonTapped(sender: AnyObject) {

        if self.isWatched {

            AlamofireController.request(.PATCH, "/groups/\(group.id)/leave", parameters: nil, encoding: .URL, success: { (result) -> () in

                let group = GroupEntity(result)
                me.groups?.remove(group.id)
                self.isWatched = false

                UIView.animateWithDuration(0.3, animations: {
                    self.watchButton.backgroundColor = Palette.Green.primaryColor
                    self.watchButton.setTitle("  关注  ", forState: .Normal)
                    self.watchButton.sizeToFit()
                    self.setNeedsLayout()
                })
            })

        } else  {

            AlamofireController.request(.PATCH, "/groups/\(group.id)/join", parameters: nil, encoding: .URL, success: { (result) -> () in

                let group = GroupEntity(result)
                me.addGroup(group.id)
                self.isWatched = true

                UIView.animateWithDuration(0.3, animations: {
                    self.watchButton.backgroundColor = Palette.Red.primaryColor
                    self.watchButton.setTitle("  取消关注  ", forState: .Normal)
                    self.watchButton.sizeToFit()
                    self.setNeedsLayout()
                })
            })
        }

    }

}
