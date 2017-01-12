//
//  BookmarkedPostsViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/07/21.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class BookmarkedPostsViewController: UITableViewController {

    @IBOutlet weak var coverImageView: UIImageView!

    @IBOutlet weak var avatarImageView: UIImageView!

    @IBOutlet weak var nickNameLabel: UILabel!

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    @IBOutlet weak var loadingLabel: UILabel!
    
    // Array holds all cell contents
    var bookmarks = [PostEntity]()

    // Array holds all cell heights
    var rowHeights = [CGFloat]()

    var oldestContent: PostEntity?

    var isLoading = false
    var isExhausted = false

    let headerHeight = TomoConst.UI.ScreenHeight * 0.382 - 58
    let headerViewSize = CGSize(width: TomoConst.UI.ScreenWidth, height: TomoConst.UI.ScreenHeight * 0.382 + 58)

    override func viewDidLoad() {

        super.viewDidLoad()

        self.configDisplay()

        self.loadMoreContent()
    }

    override func viewWillDisappear(_ animated: Bool) {
        // restore the normal navigation bar before disappear
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        self.configNavigationBarByScrollPosition()
    }
}

// MARK: UITableView DataSource

extension BookmarkedPostsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookmarks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let post = self.bookmarks[indexPath.row]

        var cell: TextPostTableViewCell!

        // If the post has one or more images, use ImagePostTableViewCell, otherwise use the TextPostTableViewCell.
        if (post.images?.count)! > 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ImagePostCell") as! ImagePostTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "TextPostCell") as! TextPostTableViewCell
        }

        // Give the cell post data, this will tirgger configDisplay
        cell.post = post

        // Set current navigation controller as the cell's delegate,
        // for the navigation when post author's photo been tapped, etc.
        cell.delegate = self.navigationController

        return cell
    }
}

// MARK: UITableView Delegate

extension BookmarkedPostsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = Util.createViewControllerWithIdentifier(id: "PostDetailViewController", storyboardName: "Home") as! PostDetailViewController
        vc.post = self.bookmarks[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeights[indexPath.item]
    }
}

// MARK: - UIScrollView delegate

extension BookmarkedPostsViewController {

    // Fetch more contents when scroll down to bottom
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        // trigger on the position of one screen height to bottom
        if (contentHeight - TomoConst.UI.ScreenHeight) < offsetY {
            self.loadMoreContent()
        }

        self.configNavigationBarByScrollPosition()
    }
}

// MARK: - Internal methods

extension BookmarkedPostsViewController {

    fileprivate func configDisplay() {

        self.avatarImageView.layer.borderColor = UIColor.white.cgColor
        self.avatarImageView.layer.borderWidth = 2

        // set the header view's size according the screen size
        self.tableView.tableHeaderView?.frame = CGRect(origin: CGPoint.zero, size: self.headerViewSize)

        if let cover = me.cover {
            self.coverImageView.sd_setImage(with: URL(string: cover), placeholderImage: TomoConst.Image.DefaultCover)
        }

        if let avatar = me.photo {
            self.avatarImageView.sd_setImage(with: URL(string: avatar), placeholderImage: TomoConst.Image.DefaultCover)
        }

        self.nickNameLabel.text = me.nickName
    }
    
    fileprivate func loadMoreContent() {
        
        // skip if already in loading or no more contents
        if self.isLoading || self.isExhausted {
            return
        }

        self.isLoading = true
        
        var parameters = Router.Post.FindParameters(category: .bookmark)
        
        if let oldestContent = self.oldestContent {
            parameters.before = oldestContent.createDate.timeIntervalSince1970
        }

        Router.Post.Find(parameters: parameters).response {
            
            // Mark as exhausted when something wrong (probably 404)
            if $0.result.isFailure {
                self.isLoading = false
                self.isExhausted = true
                self.loadingIndicator.stopAnimating()
                self.loadingLabel.isHidden = false
                return
            }
            
            let posts:[PostEntity]? = PostEntity.collection($0.result.value!)
            
            if let loadPosts:[PostEntity] = posts {

                // append new contents
                self.bookmarks += loadPosts

                // calculate the cell height for display these contents
                self.rowHeights += loadPosts.map { self.simulateLayout(post: $0) }

                self.appendRows(rows: loadPosts.count)
            }
        }

        self.isLoading = false
    }
    
    private func appendRows(rows: Int) {
        
        let firstIndex = self.bookmarks.count - rows
        let lastIndex = self.bookmarks.count
        
        var indexPathes = [IndexPath]()
        
        for index in firstIndex..<lastIndex {
            indexPathes.append(IndexPath(row: index, section: 0))
        }
        
        // hold the oldest content for pull-up loading
        oldestContent = self.bookmarks.last
        
        tableView.beginUpdates()
        tableView.insertRows(at: indexPathes, with: .middle)
        tableView.endUpdates()
        
    }

    // Calulate the cell height beforehand
    private func simulateLayout(post: PostEntity) -> CGFloat {

        let cell: TextPostTableViewCell

        if (post.images?.count)! > 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "ImagePostCell") as! ImagePostTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "TextPostCell") as! TextPostTableViewCell
        }

        cell.post = post

        let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)

        return size.height
    }

    fileprivate func configNavigationBarByScrollPosition() {

        let offsetY = self.tableView.contentOffset.y

        // begin fade in the navigation bar background at the point which is
        // twice height of topbar above the bottom of the table view header area.
        // and let the fade in complete just when the bottom of navigation bar
        // overlap with the bottom of table header view.
        if offsetY > self.headerHeight - TomoConst.UI.TopBarHeight * 2 {

            let distance = self.headerHeight - offsetY - TomoConst.UI.TopBarHeight * 2
            let image = Util.imageWithColor(rgbValue: 0x0288D1, alpha: abs(distance) / TomoConst.UI.TopBarHeight)
            self.navigationController?.navigationBar.setBackgroundImage(image, for: .default)

            // if user scroll down so the table header view got shown, just keep the navigation bar transparent
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
    
}
