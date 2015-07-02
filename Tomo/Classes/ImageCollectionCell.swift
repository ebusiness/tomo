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
    
    var whenDelete : (()->())!
    
    
    @IBAction func deleteAction(sender: AnyObject) {
        self.whenDelete?()
        println("del")
    }
    
}