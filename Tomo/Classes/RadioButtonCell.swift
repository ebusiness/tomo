//
//  RadioButtonCell.swift
//  Tomo
//
//  Created by 張志華 on 2015/05/12.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class RadioButtonCell: UITableViewCell {

    @IBOutlet weak var buttonImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func check() {
        buttonImageView.image = UIImage(named: "ic_radio_button_on_black_24dp")
    }
    
    func unCheck() {
        buttonImageView.image = UIImage(named: "ic_radio_button_off_black_24dp")
    }

}
