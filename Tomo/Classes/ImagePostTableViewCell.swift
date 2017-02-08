//
//  ImagePostTableViewCell.swift
//  Tomo
//
//  Created by ebuser on 2016/01/20.
//  Copyright © 2016 e-business. All rights reserved.
//

import UIKit

final class ImagePostTableViewCell: TextPostTableViewCell {

    @IBOutlet weak var imageCollectionView: UICollectionView!

    @IBOutlet weak var pageControl: UIPageControl!

    override func awakeFromNib() {

        super.awakeFromNib()

        // add white border to avatar, cause it overlap with post image
        self.avatarImageView.layer.borderWidth = 2
        self.avatarImageView.layer.borderColor = UIColor.white.cgColor

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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.images?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleImageCell", for: indexPath) as? SingleImageCollectionViewCell

        if let imageURL = post.images?[indexPath.row] {
            cell!.imageURL = imageURL
        } else {
            cell!.imageURL = nil
        }
        return cell!
    }

}

// MARK: - UICollectionView delegate

extension ImagePostTableViewCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let postVC = Util.createViewControllerWithIdentifier(id: "PostDetailViewController", storyboardName: "Home") as? PostDetailViewController
        postVC?.post = post
        if indexPath.row != 0 {
            postVC?.initialImageIndex = indexPath.row
        }
        delegate?.pushViewController(postVC!, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: TomoConst.UI.ScreenWidth, height: 300.0)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView != imageCollectionView { return }
        guard let count = post.images?.count, count > 1 else { return }
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
                imageView.contentMode = .scaleAspectFill
                imageView.sd_setImage(with: URL(string: url), completed: { (image, _, _, _) in
                    if image == nil {
                        self.imageView.contentMode = .scaleAspectFill
                        return
                    }
                    let size = image?.size
                    let ratio = (size?.width)! / (size?.height)!
                    if (size?.height)! < (self.imageView.bounds.height / SingleImageCollectionViewCell.minCenterScale)
                        && (size?.width)! < (self.imageView.bounds.width / SingleImageCollectionViewCell.minCenterScale) {
                            self.imageView.contentMode = .center
                    } else if ratio > SingleImageCollectionViewCell.maxAspectFitScale
                        || ratio < SingleImageCollectionViewCell.minAspectFitScale {
                            self.imageView.contentMode = .scaleAspectFit
                    }else {
                        self.imageView.contentMode = .scaleAspectFill
                        //                        self.imageView.faceAwareFill()
                    }
                })
            } else {
                imageView.contentMode = .scaleAspectFill
                imageView.image = placeholderImage
            }
        }
    }

    @IBOutlet weak var imageView: UIImageView!

}
