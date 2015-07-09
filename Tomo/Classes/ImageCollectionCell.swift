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
    
    override func awakeFromNib() {
        
        if let image = UIImage(named:"icon_close") {
            btnClose?.setBackgroundImage(Util.coloredImage( image, color: UIColor.redColor()), forState: .Normal)
        }
    }
    
    @IBAction func deleteAction(sender: AnyObject) {
        self.whenDelete?()
    }

}