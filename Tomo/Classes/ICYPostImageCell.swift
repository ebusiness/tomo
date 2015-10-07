//
//  ICYPostImageCell.swift
//  Tomo
//
//  Created by eagle on 15/10/6.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ICYPostImageCell: ICYPostCell {
    
    override var post: PostEntity? {
        didSet {
            if let post = post {
                super.post = post
                pageControl.numberOfPages = post.images?.count ?? 0
                pageControlWidthConstraint.constant = pageControl.sizeForNumberOfPages(pageControl.numberOfPages + 1).width
            } else {
                super.post = nil
                pageControl.numberOfPages = 0
                pageControlWidthConstraint.constant = 0
            }
            imageCollectionView.reloadData()
        }
    }
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var pageControlWidthConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let sigleImageCell = UINib(nibName: "ICYCollectionViewSingleImageCell", bundle: nil)
        imageCollectionView.registerNib(sigleImageCell, forCellWithReuseIdentifier: ICYCollectionViewSingleImageCell.identifier)
        
        majorAvatarImageView.layer.borderWidth = 2.0
        majorAvatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
        
        pageControl.layer.cornerRadius = pageControl.bounds.height / 2.0
    }
    
}

extension ICYPostImageCell: UICollectionViewDelegate, UICollectionViewDataSource {
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == imageCollectionView {
            return post?.images?.count ?? 0
        } else {
            return super.collectionView(collectionView, numberOfItemsInSection: section)
        }
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == imageCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ICYCollectionViewSingleImageCell.identifier, forIndexPath: indexPath) as! ICYCollectionViewSingleImageCell
            if let imageURL = post?.images?.get(indexPath.row) {
                cell.imageURL = imageURL
            } else {
                cell.imageURL = nil
            }
            return cell
        } else {
            return super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
        }
    }
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == imageCollectionView {
            return CGSize(width: screenWidth, height: 250.0)
        } else {
            return super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: indexPath)
        }
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == imageCollectionView {
            if let post = post {
                let postVC = Util.createViewControllerWithIdentifier("PostView", storyboardName: "Home") as! PostViewController
                postVC.post = post
                delegate?.navigationController?.pushViewController(postVC, animated: true)
            }
        } else {
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == imageCollectionView {
            if let count = post?.images?.count where count > 1 {
                let currentPage = Int(floor((scrollView.contentOffset.x + screenWidth / 2.0) / screenWidth))
                pageControl.currentPage = currentPage
            }
        } else {
        }
    }
}
