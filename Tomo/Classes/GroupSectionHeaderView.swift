//
//  GroupSectionHeaderVew.swift
//  Tomo
//
//  Created by ebuser on 2015/09/18.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class GroupSectionHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var memberLabel: UILabel!
    
    var group: GroupEntity!
    var delegate: UINavigationController!
    
    override func awakeFromNib() {
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("headerTapped"))
        self.addGestureRecognizer(tapGesture)
    }
    
    func setupDisplay() {

        self.coverImageView.sd_setImageWithURL(NSURL(string: self.group.cover), placeholderImage: DefaultGroupImage)
        
        self.nameLabel.text = self.group.name
        
        if self.group.type == "site" {
            self.typeLabel.hidden = false
            self.typeLabel.text = "现场"
        } else {
            self.typeLabel.hidden = true
        }
        
        self.introductionLabel.text = self.group.introduction
        
        self.memberLabel.text = "\(self.group.members!.count)名成员"
    }
    
    func headerTapped() {
        let vc = Util.createViewControllerWithIdentifier("GroupDetailView", storyboardName: "Group") as! GroupDetailViewController
        vc.group = self.group
        self.delegate.pushViewController(vc, animated: true)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
