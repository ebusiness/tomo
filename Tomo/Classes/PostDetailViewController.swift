//
//  PostDetailViewController.swift
//  Tomo
//
//  Created by ebuser on 2016/01/21.
//  Copyright © 2016年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class PostDetailViewController: UIViewController {

    var post: PostEntity!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

// MARK: - Internal methods

extension PostDetailViewController {

}

// MARK: - UITableView datasource

extension PostDetailViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let comments = self.post.comments {
            return comments.count + 2
        } else {
            return 2
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell: UITableViewCell

        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("AuthorInfoCell", forIndexPath: indexPath)
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("ContentCell", forIndexPath: indexPath)
        default:
            cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath)
        }

        (cell as! PostDisplayCell).post = self.post

        return cell
    }
}

// MARK: - UITableView delegate

extension PostDetailViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 0
    }
}

// MARK: - UICollectionView datasource

extension PostDetailViewController: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.post.images?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SingleImageCell", forIndexPath: indexPath) as! SingleImageCollectionViewCell
        cell.imageURL = self.post.images?[indexPath.row]
        return cell
    }

}

// MARK: - UICollectionView delegate

extension PostDetailViewController: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        return
    }
}

class PostDisplayCell: UITableViewCell {

    var post: PostEntity! {
        didSet { self.configDisplay() }
    }

    func configDisplay() {

    }
}

final class PostAuthorInfoCell: PostDisplayCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func configDisplay() {

        if let photo = self.post.owner.photo {
            self.avatarImageView.sd_setImageWithURL(NSURL(string: photo), placeholderImage: DefaultAvatarImage)
        }
        self.nickNameLabel.text = self.post.owner.nickName
        self.dateLabel.text = post.createDate.toString()
    }
}

final class PostContentCell: PostDisplayCell {

    @IBOutlet weak var contentLabel: UILabel!

    override func configDisplay() {

        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 30

        let attributeString = NSAttributedString(string: self.post.content, attributes: [
            NSParagraphStyleAttributeName: style
        ])

        contentLabel.attributedText = attributeString

    }
}

final class PostCommentCell: PostDisplayCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func configDisplay() {

    }
}