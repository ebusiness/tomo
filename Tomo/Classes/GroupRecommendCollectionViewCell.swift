//
//  GroupRecommendCollectionViewCell.swift
//  Tomo
//
//  Created by starboychina on 2017/03/30.
//  Copyright © 2017  e-business. All rights reserved.
//

/// GroupRecommendCollectionViewCell
final class GroupRecommendCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak private var coverImageView: UIImageView!
    @IBOutlet weak private var nameLabel: UILabel!

    var group: GroupEntity! {
        didSet {
            self.coverImageView.sd_setImage(with: NSURL(string: group.cover) as URL!, placeholderImage: TomoConst.Image.DefaultGroup)
            self.nameLabel.text = group.name
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 5
        self.contentView.clipsToBounds = true
    }
    
}

