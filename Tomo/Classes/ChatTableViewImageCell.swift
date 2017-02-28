//
//  ChatTableViewImageCell.swift
//  Tomo
//
//  Created by ebuser on 17/2/23.
//  Copyright © 2017年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit
import Alamofire

protocol ChatTableViewImageCellDelegate: class {
    func userAvatarTapped(message: MessageEntity)
}

final class ChatTableViewImageCell: UITableViewCell {

    @IBOutlet weak fileprivate var incomingAvatar: UIImageView!

    @IBOutlet weak fileprivate var outgoingAvatar: UIImageView!

    @IBOutlet weak fileprivate var createDate: UILabel!

    @IBOutlet weak fileprivate var nickname: UILabel!

    @IBOutlet weak fileprivate var thumbnail: UIImageView!

    @IBOutlet weak fileprivate var topConstraint: NSLayoutConstraint!

    @IBOutlet weak fileprivate var contentTopConstraint: NSLayoutConstraint!

    weak var delegate: ChatTableViewImageCellDelegate!

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
}

extension ChatTableViewImageCell {

    func avatarTapped(_ sender: UITapGestureRecognizer) {
        self.delegate.userAvatarTapped(message: message)
    }

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
        self.contentTopConstraint.constant = 24
        self.nickname.isHidden = !isReceived
        self.nickname.text = self.message.from.nickName
    }

    fileprivate func showContent(isReceived: Bool) {
        self.thumbnail.image = nil
        if self.message.type == .voice {
            self.thumbnail.contentMode = isReceived ? .topLeft : .topRight
            let voiceImageName = isReceived ? "Receiver" : "Sender"
            self.thumbnail.image = UIImage(named: "\(voiceImageName)VoiceNodePlaying.png")
        } else {
            self.showMediaContent(isReceived: isReceived)
        }
    }

    private func showMediaContent(isReceived: Bool) {
        // TODO display video file
//        self.thumbnailHeight.constant = 150

        var url = Util.getDocumentsURL(forFile: self.message.content)
        if !FileManager.default.fileExists(atPath: url.path) {
            url = URL(string: self.message.type.fullPath(name: self.message.content))!
        }

        self.thumbnail.contentMode = isReceived ? .topLeft : .topRight
        let placeholderImageName = "placeholder.png"
        self.thumbnail.image = UIImage(named: placeholderImageName)
        self.thumbnail.sd_setImage(with: url) { (image, _, _, _) in
            guard let image = image else {
                let brokenImageName = "file_broken.png"
                self.thumbnail.image = UIImage(named: brokenImageName)
                return
            }
            let width = image.size.width / image.size.height * 150
            self.thumbnail.image = image.scale(toFit: CGSize(width: width, height: 150))
        }
    }

}
