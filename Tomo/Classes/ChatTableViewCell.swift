//
//  ChatTableViewCell.swift
//  Tomo
//
//  Created by starboychina on 2017/02/13.
//  Copyright © 2017 e-business. All rights reserved.
//

import UIKit

final class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak fileprivate var incomingAvatar: UIImageView!
    @IBOutlet weak fileprivate var outgoingAvatar: UIImageView!

    @IBOutlet weak fileprivate var createDate: UILabel!
    @IBOutlet weak fileprivate var nickname: UILabel!
    @IBOutlet weak fileprivate var content: UILabel!
    @IBOutlet weak fileprivate var thumbnail: UIImageView!

    @IBOutlet weak fileprivate var topConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var contentTopConstraint: NSLayoutConstraint!
    @IBOutlet weak fileprivate var thumbnailHeight: NSLayoutConstraint!

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
//            self.content.preferredMaxLayoutWidth = self.content.frame.size.width
            let width = self.frame.size.width - self.incomingAvatar.frame.size.width * 2 - 8 * 4
            self.content.preferredMaxLayoutWidth = width
        }
        self.content.frame.size.width = self.content.preferredMaxLayoutWidth
        self.content.sizeToFit()

        let variable = self.thumbnailHeight.constant
                        + self.content.frame.size.height
                        + self.contentTopConstraint.constant

        if variable < self.incomingAvatar.frame.size.height {
            return regular + self.incomingAvatar.frame.size.height
        }

        return regular + variable
    }
}

extension ChatTableViewCell {
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
        self.content.text = ""
        self.thumbnail.image = nil
        if self.message.type == .text {
            self.showTextContent(isReceived: isReceived)
        } else if self.message.type == .voice {
            self.thumbnailHeight.constant = 20
            let voiceImageName = isReceived ? "Receiver" : "Sender"
            self.thumbnail.image = UIImage(named: "\(voiceImageName)VoiceNodePlaying.png")
        } else {
            self.showMediaContent(isReceived: isReceived)
        }
    }

    private func showTextContent(isReceived: Bool) {
        self.thumbnailHeight.constant = 0
        self.content.text = self.message.content
        self.content.textAlignment = .left
        self.content.sizeToFit()
        if !isReceived && self.content.frame.size.height < 20 {
            self.content.textAlignment = .right
        }
    }

    private func showMediaContent(isReceived: Bool) {
        self.thumbnailHeight.constant = 150
        let url = URL(string: self.message.type.fullPath(name: self.message.content))
        self.thumbnail.contentMode = isReceived ? .topLeft : .topRight
        let placeholderImageName = "placeholder.png"
        self.thumbnail.image = UIImage(named: placeholderImageName)
        self.thumbnail.sd_setImage(with: url) { (image, _, _, _) in
            guard let image = image else {
                let brokenImageName = "file_broken.png"
                self.thumbnail.image = UIImage(named:brokenImageName)
                return
            }
            let width = image.size.width / image.size.height * self.thumbnailHeight.constant
            self.thumbnail.image = image.scale(toFit: CGSize(width: width, height: 150))
        }
    }

}
