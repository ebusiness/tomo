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
    
    override func setupDisplay() {
        super.setupDisplay()
        
        var imageCount = CGFloat(0)
        var scrollViewHeight = scrollView.frame.height
        
        for imageData in post.imagesmobile {
            
            var imageView = UIImageView(frame: CGRect(x: scrollViewHeight * imageCount + 5 * imageCount, y: 0, width: scrollViewHeight, height: scrollViewHeight))
            
            imageView.sd_setImageWithURL(NSURL(string: imageData.name))
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.clipsToBounds = true
            
            imageCount++
            
            scrollView.addSubview(imageView)
        }
        
        scrollView.contentSize = CGSizeMake(scrollViewHeight * imageCount, scrollViewHeight)
        
    }

}
