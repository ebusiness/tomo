//
//  AnnouncementCell.swift
//  Tomo
//
//  Created by 張志華 on 2015/05/22.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class AnnouncementCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupDefault()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setupDefault()
    }
    
    func setupDefault() {
        nameLabel.text = nil
        contentLabel.text = nil
        timeLabel.text = nil
    }
    
    var announcement: Announcements! {
        didSet {
            nameLabel.text = announcement.title
            contentLabel.text = announcement.content
            timeLabel.text = announcement.createDate?.toString(dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
            
            setupFont([nameLabel, contentLabel, timeLabel])
        }
    }
    
    func setupFont(labels: [UILabel]) {
        for label in labels {
            let size = label.font.pointSize
            label.font = (announcement.isRead == true) ? UIFont.systemFontOfSize(size) : UIFont.boldSystemFontOfSize(size)
        }
    }
}
