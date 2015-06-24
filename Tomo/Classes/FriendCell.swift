//
//  FriendCell.swift
//  spot
//
//  Created by 張志華 on 2015/03/10.
//  Copyright (c) 2015年 e-business. All rights reserved.
//

import UIKit

class FriendCell: MCSwipeTableViewCell {
    
//    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var invitedLabel: UILabel!
    
    @IBOutlet weak var tagListView: AMTagListView!
    
    
    var successHandler: ((cell:FriendCell, state:MCSwipeTableViewCellState, mode:MCSwipeTableViewCellMode)->())?
    
    var friend: User! {
        didSet {
            if friend.hasIdOnly {
                ApiController.getUserInfo(friend.id!, done: { (error) -> Void in
                    self.updateUI()
                })
            } else {
                updateUI()
            }
        }
    }
    
    func updateUI() {
        if let photo_ref = friend.photo_ref {
            friendImageView.sd_setImageWithURL(NSURL(string: photo_ref), placeholderImage: DefaultAvatarImage)
        }
        
        nameLabel.text = friend.fullName()
        
        invitedLabel.hidden = !DBController.isInvitedUser(friend)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        friendImageView.layer.cornerRadius = friendImageView.bounds.width / 2
        
        
        if let tagListView = self.tagListView {
            tagListView.tagListDelegate = self
            
            self.defaultColor = Util.UIColorFromRGB(0xEAEAEA, alpha: 1)
            
            self.setSwipe(.State1)
            self.setSwipe(.State2)
            self.setSwipe(.State3)
            self.setSwipe(.State4)
        }
    }
    func setSwopeON(withLeft:Bool,withRight:Bool = false){
        self.modeForState1 = .None
        self.modeForState2 = .None
        self.modeForState3 = .None
        self.modeForState4 = .None
        
        if withLeft {
            self.modeForState1 = .Switch
            self.modeForState2 = .Switch
        }
        if withRight {
            self.modeForState3 = .Switch
            self.modeForState4 = .Switch
        }
    }
    
    func setSwipe(state: MCSwipeTableViewCellState) {
        var backgroundColor:UIColor!
        
        let image = Util.coloredImage(UIImage(named: "ic_add_black_48dp")!, color: UIColor.whiteColor())
        let imageView = UIImageView(image: image)
        imageView.contentMode =  .Center
        
//        let uilabel = UILabel(frame: CGRectMake(0, 0, 30, 30))
//        uilabel.text = "sssss"
        
        if state == .State1 || state == .State2 {
            
            backgroundColor = UIColor.greenColor()
        }else if  state == .State3 || state == .State4 {
            
            backgroundColor = UIColor.redColor()
        }
        self.setSwipeGestureWithView(imageView, color: backgroundColor, mode: .Switch, state: state, completionBlock: { (cell, state, model) -> Void in
            if let cell = cell as? FriendCell {
                self.successHandler?(cell: cell, state: state, mode: model)
            }
        })
        
    }

//    func setChecked(checked: Bool) {
//        let imageName = checked ? "friend_check_on" : "friend_check_off"
//        
//        checkImageView.image = UIImage(named: imageName)
//    }

}

extension FriendCell {
    //タグを追加する
    func addTag(tag: Tag){
        if let name = tag.name where !name.isEmpty {
            tagUIController.serTagView(.small)
            self.tagListView.addTag(name)
        }
    }
    func addTags(array: [AnyObject]!){
        tagListView.hidden = array.count == 0 && self.tagListView.tags.count == 0
        if !tagListView.hidden {
            tagUIController.serTagView(.small)
        }
        self.tagListView.addTags(array)
    }
}


extension FriendCell : AMTagListDelegate {
    //タグ表示数
    func tagList(tagListView: AMTagListView!, shouldAddTagWithText text: String!, resultingContentSize size: CGSize) -> Bool {
        return tagListView.tags.count < 4
    }
}
