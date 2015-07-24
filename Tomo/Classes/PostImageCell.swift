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
    let leftOffset = CGFloat(74)
    
    override func setupDisplay() {
        
        super.setupDisplay()
        
        let imageHeight = scrollView.frame.height
        let imageWidth = imageHeight / 3 * 4
        
        var imageCount = CGFloat(0)
        
        for imageData in post.imagesmobile {
            
            let imageX = (imageWidth + gapOffset) * imageCount + leftOffset
            let imageFrame = CGRect(x: imageX, y: 0, width: imageWidth, height: imageHeight)
            
            let imageView = UIImageView(frame: imageFrame)
            
            imageView.sd_setImageWithURL(NSURL(string: imageData.name))
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.clipsToBounds = true
            
            imageCount++
            
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSizeMake((imageWidth + gapOffset) * imageCount + leftOffset, imageHeight)
        
    }

}
