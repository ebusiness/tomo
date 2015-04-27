//
//  GroupHeaderView.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/24.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class GroupHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.backgroundColor = UIColor.clearColor()
    }
    
    var groupSection: GroupSection! {
        didSet {
            titleLabel.text = groupSection.groupSectionTitle()
        }
    }

}
