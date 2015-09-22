//
//  GroupDescriptionLabelCell.swift
//  Tomo
//
//  Created by eagle on 15/9/22.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class GroupDescriptionLabelCell: UITableViewCell {
    
    static let identifier = "GroupDescriptionLabelCellIdentifier"

    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var minorLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
