//
//  NewGroupCell.swift
//  Tomo
//
//  Created by ebuser on 2015/07/16.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class NewGroupCell: UITableViewCell {

    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    
    var group: Group!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupDisplay() {
        
        if let cover_ref = group.cover_ref {
            groupImageView.sd_setImageWithURL(NSURL(string: cover_ref))
        }
        
        groupNameLabel.text = group.name
        
        introductionLabel.text = group.detail
        
    }
    
}
