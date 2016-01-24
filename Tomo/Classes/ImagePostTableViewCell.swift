//
//  ImagePostTableViewCell.swift
//  Tomo
//
//  Created by ebuser on 2016/01/20.
//  Copyright © 2016年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class ImagePostTableViewCell: TextPostTableViewCell {

    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!

    override func awakeFromNib() {

        super.awakeFromNib()

        // add white border to avatar, cause it overlap with post image
        self.avatarImageView.layer.borderWidth = 2
        self.avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor

        // do this so the scrollsToTop of main table view will work
        self.imageCollectionView.scrollsToTop = false
    }

    override func configDisplay() {

        super.configDisplay()

        self.pageControl.numberOfPages = post.images?.count ?? 0
        self.pageControl.currentPage = 0

        self.imageCollectionView.reloadData()
    }
}

// MARK: - UICollectionView datasource

extension ImagePostTableViewCell: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.images?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SingleImageCell", forIndexPath: indexPath) as! SingleImageCollectionViewCell

        if let imageURL = post.images?.get(indexPath.row) {
            cell.imageURL = imageURL
        } else {
            cell.imageURL = nil
        }
        return cell
    }

}

// MARK: - UICollectionView delegate

extension ImagePostTableViewCell: UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let postVC = Util.createViewControllerWithIdentifier("PostDetailViewController", storyboardName: "Home") as! PostDetailViewController
        postVC.post = post
        if indexPath.row != 0 {
            postVC.initialImageIndex = indexPath.row
        }
        delegate?.pushViewController(postVC, animated: true)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: TomoConst.UI.ScreenWidth, height: 250.0)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {

        if scrollView != imageCollectionView { return }
        guard let count = post.images?.count where count > 1 else { return }
        let currentPage = Int(floor((scrollView.contentOffset.x + TomoConst.UI.ScreenWidth / 2.0) / TomoConst.UI.ScreenWidth))

        pageControl.currentPage = currentPage
    }
}

final class SingleImageCollectionViewCell: UICollectionViewCell {

    static let minCenterScale = CGFloat(1.5)
    static let maxAspectFitScale = CGFloat(3.5)
    static let minAspectFitScale = CGFloat(1 / 3.5)

    var imageURL: String? {
        didSet {
            let placeholderImage = UIImage(named: "placeholder")
            if let url = imageURL {
                imageView.contentMode = .ScaleAspectFill
                imageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: placeholderImage, completed: { (image, _, _, _) -> Void in
                    if image == nil {
                        self.imageView.contentMode = .ScaleAspectFill
                        return
                    }
                    let size = image.size
                    let ratio = size.width / size.height
                    if size.height < (self.imageView.bounds.height / ICYCollectionViewSingleImageCell.minCenterScale)
                        && size.width < (self.imageView.bounds.width / ICYCollectionViewSingleImageCell.minCenterScale) {
                            self.imageView.contentMode = .Center
                    } else if ratio > ICYCollectionViewSingleImageCell.maxAspectFitScale
                        || ratio < ICYCollectionViewSingleImageCell.minAspectFitScale {
                            self.imageView.contentMode = .ScaleAspectFit
                    }else {
                        self.imageView.contentMode = .ScaleAspectFill
                        //                        self.imageView.faceAwareFill()
                    }
                })
            } else {
                imageView.contentMode = .ScaleAspectFill
                imageView.image = placeholderImage
            }
        }
    }

    @IBOutlet weak var imageView: UIImageView!
    
}