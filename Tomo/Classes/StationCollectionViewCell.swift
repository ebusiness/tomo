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
            self.watchButton.setTitle("  退出  ", forState: .Normal)
            self.watchButton.sizeToFit()

        } else {

            self.isWatched = false
            self.watchButton.backgroundColor = Palette.Green.primaryColor
            self.watchButton.setTitle("  加入  ", forState: .Normal)
            self.watchButton.sizeToFit()
        }
    }

    @IBAction func watchButtonTapped(sender: AnyObject) {

        if self.isWatched {

            Router.Group.Leave(id: group.id).response {
                if $0.result.isFailure { return }
                
                let group = GroupEntity($0.result.value!)
                me.groups?.remove(group.id)
                self.isWatched = false
                
                UIView.animateWithDuration(0.3, animations: {
                    self.watchButton.backgroundColor = Palette.Green.primaryColor
                    self.watchButton.setTitle("  加入  ", forState: .Normal)
                    self.watchButton.sizeToFit()
                    self.setNeedsLayout()
                })
            }

        } else  {
            
            Router.Group.Join(id: group.id).response {
                if $0.result.isFailure { return }
                
                let group = GroupEntity($0.result.value!)
                me.addGroup(group.id)
                self.isWatched = true
                
                UIView.animateWithDuration(0.3, animations: {
                    self.watchButton.backgroundColor = Palette.Red.primaryColor
                    self.watchButton.setTitle("  退出  ", forState: .Normal)
                    self.watchButton.sizeToFit()
                    self.setNeedsLayout()
                })
            }
        }

    }

}
