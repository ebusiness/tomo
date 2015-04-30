//
//  GroupPostsHeaderCell.swift
//  Tomo
//
//  Created by 張志華 on 2015/04/28.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

@objc protocol GroupPostsHeaderCellDelegate {
    
    func joinBtnTapped()
    func didTapMemberListOfGroupPostsHeaderCell(cell: GroupPostsHeaderCell)
    
}

class GroupPostsHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var userCountLabel: UILabel!
    @IBOutlet weak var joinBtn: UIButton!
    
    weak var delegate: GroupPostsHeaderCellDelegate?
    
    var group: Group! {
        didSet {
            //image
            if let path = group.cover_ref {
                groupImageView.setImageWithURL(NSURL(string: path), completed: { (image, error, _, _) -> Void in
                    //                    let img = image.cropToSize(CGSize(width: GroupImageWidth*Util.scale(), height: GroupImageWidth*Util.scale()), usingMode: NYXCropModeTopLeft)
                    //                    self.groupImageView.image = img
                    }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                //                groupImageView.sd_setImageWithURL(NSURL(string: path)) { (image, error, _, _) -> Void in
                //                    let img = image.cropToSize(CGSize(width: GroupImageWidth*Util.scale(), height: GroupImageWidth*Util.scale()), usingMode: NYXCropModeTopLeft)
                //                    self.groupImageView.image = img
                //                }
            }
            nameLabel.text = group.name
            typeLabel.text = GroupType(rawValue: group.type ?? "")?.str()
            userCountLabel.text = "\(group.participants.count)人のメンバー"
            
            let ges = UITapGestureRecognizer(target: self, action: Selector("memberListTapped:"))
            userCountLabel.addGestureRecognizer(ges)
            
            joinBtn.hidden = group.section == GroupSection.MyGroup.rawValue
        }
    }
    
    class func height(#group: Group) -> CGFloat {
        if group.section == GroupSection.MyGroup.rawValue {
            return 168 - 34 - 12
        }
        
        return 168
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //fix autolayout error
        contentView.frame = bounds
        contentView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        
        backView.layer.cornerRadius = 3.0
        backView.layer.shadowColor = UIColor(hexString: "#DADADA").CGColor
        backView.layer.shadowOffset = CGSize(width: 0, height: 3)
        backView.layer.shadowOpacity = 1.0
        backView.layer.shadowRadius = 0.0
    }
    
    // MARK: - Action
    
    @IBAction func memberListTapped(sender: UITapGestureRecognizer) {
        delegate?.didTapMemberListOfGroupPostsHeaderCell(cellOfView(sender.view!))
    }
    
    @IBAction func joinBtnTapped(sender: AnyObject) {
        delegate?.joinBtnTapped()
    }
    
    func cellOfView(view: UIView) -> GroupPostsHeaderCell {
        var v = view
        
        while !(v is GroupPostsHeaderCell) {
            v = v.superview!
        }
        
        return v as! GroupPostsHeaderCell
    }
}
