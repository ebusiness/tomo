//
//  PostWithImageCell.swift
//  Tomo
//
//  Created by ebuser on 2015/07/13.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class PostImageCell: PostCell {

    @IBOutlet weak var scrollView: UIScrollView!
    
    let gapOffset = CGFloat(5)
    let leftOffset = CGFloat(0)
    let placeHolder = UIImage(named: "placeholder")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.scrollView.scrollsToTop = false
    }
    
    override func setupDisplay() {
        
        super.setupDisplay()
        
        if post.images!.count == 1 {
            displaySingleImage()
        } else {
            displayMultipleImage()
        }
        
    }
    
    private func displaySingleImage() {
        
        let imageHeight = scrollView.frame.height
        let imageWidth = scrollView.frame.width
        
        let imageFrame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        let imageView = UIImageView(frame: imageFrame)
        
//        imageView.sd_setImageWithURL(NSURL(string: post.images!.get(0)!))
        imageView.setImageWithURL(NSURL(string: post.images!.get(0)!), usingActivityIndicatorStyle: .Gray)

        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        
        scrollView.addSubview(imageView)
        
        scrollView.contentSize = CGSizeMake(imageWidth, imageHeight)
        
    }
    
    private func displayMultipleImage() {
        
        let imageHeight = scrollView.frame.height
        let imageWidth = imageHeight / 3 * 4
        
        var imageCount = CGFloat(0)
        
        for imageData in post.images! {
            
            let imageX = (imageWidth + gapOffset) * imageCount + leftOffset
            let imageFrame = CGRect(x: imageX, y: 0, width: imageWidth, height: imageHeight)
            
            let imageView = UIImageView(frame: imageFrame)
            
//            imageView.sd_setImageWithURL(NSURL(string: imageData))
//            imageView.setImageWithURL(NSURL(string: imageData), usingActivityIndicatorStyle: .Gray)
            imageView.setImageWithURL(NSURL(string: imageData), placeholderImage: placeHolder, usingActivityIndicatorStyle: .Gray)
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.clipsToBounds = true
            
            imageCount++
            
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSizeMake((imageWidth + gapOffset) * imageCount + leftOffset, imageHeight)
    }

}
