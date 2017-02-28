//
//  ChatTableViewTextCell.swift
//  Tomo
//
//  Created by ebuser on 17/2/23.
//  Copyright © 2017年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

protocol ChatTableViewTextCellDelegate: class {
    func userAvatarTapped(message: MessageEntity)
}

class ChatTableViewTextCell: UITableViewCell {

    @IBOutlet weak fileprivate var incomingAvatar: UIImageView!
    @IBOutlet weak fileprivate var outgoingAvatar: UIImageView!
    @IBOutlet weak fileprivate var createDate: UILabel!
    @IBOutlet weak fileprivate var nickname: UILabel!
    @IBOutlet weak fileprivate var content: UILabel!

    @IBOutlet weak fileprivate var topConstraint: NSLayoutConstraint!

    @IBOutlet weak fileprivate var contentTopConstraint: NSLayoutConstraint!
    weak var delegate: ChatTableViewTextCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        let inGes = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(_:)))
        incomingAvatar.addGestureRecognizer(inGes)
        let outGes = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(_:)))
        outgoingAvatar.addGestureRecognizer(outGes)
    }

    var message: MessageEntity! {
        didSet {
            self.showCreateDateIfNeeded()
            let isReceived = self.message.from.id != me.id
            self.showAvatar(isReceived: isReceived)
            self.showNickname(isReceived: isReceived)
            self.showContent(isReceived: isReceived)
        }
    }

    var dateOfPreviousMessage: Date! {
        didSet {
            self.showCreateDateIfNeeded()
        }
    }

    func getHeight() -> CGFloat {
        let regular = self.topConstraint.constant + 8
        if self.content.preferredMaxLayoutWidth == 0 {
            let width = self.frame.size.width - self.incomingAvatar.frame.size.width * 2 - 8 * 4
            self.content.preferredMaxLayoutWidth = width
        }
        self.content.frame.size.width = self.content.preferredMaxLayoutWidth
        self.content.sizeToFit()

        let variable = self.content.frame.size.height
                        + self.contentTopConstraint.constant
        if variable < self.incomingAvatar.frame.size.height {
            return regular + self.incomingAvatar.frame.size.height
        }

        return regular + variable
    }

    func avatarTapped(_ sender: UIGestureRecognizer) {
        self.delegate?.userAvatarTapped(message: message)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension ChatTableViewTextCell {

    fileprivate func showCreateDateIfNeeded() {
        self.topConstraint.constant = 8
        self.createDate.text = ""
        guard self.message != nil else {
            return
        }
        guard self.dateOfPreviousMessage != nil else {
            return
        }

        let diff = self.message.createDate.timeIntervalSince1970 - self.dateOfPreviousMessage.timeIntervalSince1970
        if diff > 90 {
            self.topConstraint.constant = 32
            self.createDate.isHidden = false
            self.createDate.text = self.message.createDate.relativeTimeToString()
        }

    }

    fileprivate func showAvatar(isReceived: Bool) {
        self.outgoingAvatar.isHidden = isReceived
        self.incomingAvatar.isHidden = !isReceived
        if let photo = self.message.from.photo,
            let url = URL(string: photo) {
            self.outgoingAvatar.sd_setImage(with: url)
            self.incomingAvatar.sd_setImage(with: url)
        } else {
            self.outgoingAvatar.image = defaultAvatarImage
            self.incomingAvatar.image = defaultAvatarImage
        }
    }

    fileprivate func showNickname(isReceived: Bool) {
        self.contentTopConstraint.constant = isReceived ? 24 : 0
        self.nickname.isHidden = !isReceived
        self.nickname.text = self.message.from.nickName
    }

    fileprivate func showContent(isReceived: Bool) {
        self.content.text = self.message.content
        self.content.textAlignment = .left
        self.content.sizeToFit()
        if !isReceived && self.content.frame.size.height < 20 {
            self.content.textAlignment = .right
        }
    }
}
