//
//  NewsfeedCell.swift
//  Tomo
//
//  Created by 張志華 on 2015/03/27.
//  Copyright © 2015 e-business. All rights reserved.
//

import UIKit

class NewsfeedCell: UITableViewCell {

    @IBOutlet weak fileprivate var nameLabel: UILabel!
    @IBOutlet weak fileprivate var dateLabel: UILabel!
    @IBOutlet weak fileprivate var contentLabel: UILabel!

    var newsfeed: Newsfeed! {
        didSet {
            nameLabel.text = "名前"
            dateLabel.text = "時間"

//            contentLabel.text = newsfeed.content

            if let str = newsfeed.content {
                let data = str.dataUsingEncoding(NSUnicodeStringEncoding)

                let attrStr = NSAttributedString(data: data!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil, error: nil)
                contentLabel.attributedText = attrStr
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupDefault()
    }

    override func prepareForReuse() {
        setupDefault()
    }

    func setupDefault() {
        nameLabel.text = nil
        dateLabel.text = nil
        contentLabel.text = nil
    }

}
