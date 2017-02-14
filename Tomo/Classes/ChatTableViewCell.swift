//
//  ChatTableViewCell.swift
//  Tomo
//
//  Created by starboychina on 2017/02/13.
//  Copyright © 2017 e-business. All rights reserved.
//

import UIKit

final class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak private var incomingAvatar: UIImageView!
    @IBOutlet weak private var outgoingAvatar: UIImageView!

    @IBOutlet weak private var createDate: UILabel!
    @IBOutlet weak private var nickname: UILabel!
    @IBOutlet weak private var content: UILabel!
    @IBOutlet weak private var thumbnail: UIImageView!

    @IBOutlet weak private var topConstraint: NSLayoutConstraint!
    @IBOutlet weak private var contentTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var thumbnailConstraint: NSLayoutConstraint!

    var message: MessageEntity! {
        didSet {
            showCreateDateIfNeeded()
            let isReceived = self.message.from.id != me.id
            self.showAvatar(isReceived: isReceived)
            self.showNickname(isReceived: isReceived)
        }
    }

    var dateOfPreviousMessage: Date! {
        didSet {
            showCreateDateIfNeeded()
        }
    }

    func getHeight() -> CGFloat {
        let regular = self.topConstraint.constant + self.contentTopConstraint.constant

        self.content.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        let variable = self.thumbnailConstraint.constant + self.content.frame.size.height

        if variable < self.incomingAvatar.frame.size.height {
            return regular + self.incomingAvatar.frame.size.height
        }

        return regular + variable
    }

    private func showCreateDateIfNeeded() {
        self.topConstraint.constant = 8
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

    private func showAvatar(isReceived: Bool) {
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

    private func showNickname(isReceived: Bool) {
        self.contentTopConstraint.constant = isReceived ? 24 : 0
        self.nickname.text = self.message.from.nickName
    }

    private func showContent(isReceived: Bool) {
        if self.message.type == .text {
            self.thumbnailConstraint.constant = 0
            self.content.text = self.message.content
        } else if self.message.type == .voice {
            self.thumbnailConstraint.constant = 20
            let voiceImageName = isReceived ? "Receiver" : "Sender"
            self.thumbnail.image = UIImage(named: "\(voiceImageName)VoiceNodePlaying.png")
        } else {
            self.thumbnailConstraint.constant = 150
            let url = URL(string: self.message.content)
            self.thumbnail.sd_setImage(with: url)
        }
    }

}
