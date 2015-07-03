//
//  ImageCollectionCell.swift
//  Tomo
//
//  Created by starboychina on 2015/07/02.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import Foundation

class ImageCollectionCell :UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnClose: UIButton!
    
    var whenDelete : (()->())!
    
    
    @IBAction func deleteAction(sender: AnyObject) {
        self.whenDelete?()
        println("del")
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if let image = UIImage(named:"icon_close") {
            //btnClose.backgroundColor = Util.coloredImage( image, color: UIColor.redColor())
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
}