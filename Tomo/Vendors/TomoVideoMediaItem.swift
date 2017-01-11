//
//  TomoVideoMediaItem.swift
//  Tomo
//
//  Created by 張志華 on 2015/05/26.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class TomoVideoMediaItem: JSQVideoMediaItem {
   
//    var cachedVideoImageView: UIImageView!
    
    override func mediaView() -> UIView! {
        var view = super.mediaView()
        if let imageView = view as? UIImageView {
            let image = SDImageCache.shared().imageFromDiskCache(forKey: MessageType.video.fullPath(name: fileURL.lastPathComponent))
            if image != nil {
                imageView.contentMode = .scaleAspectFit
                imageView.image = image
                view = imageView
            }
        }
        return view
    }
}
