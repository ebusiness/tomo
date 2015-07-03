//
//  ShareViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/05/19.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


import UIKit

class ShareViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var icons = ["icon_wx", "icon_moments" ]
    
    var share_image :UIImage!
    var share_description = ""
    var share_url:String?
    var cellwidth:CGFloat = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rowCount = CGFloat(ceil(CDouble(icons.count) / 1))
        var h:CGFloat = 21 + 10 + 10 + 44 + 20 + rowCount * (cellwidth + 10)
        
        self.formSheetController.presentedFormSheetSize = CGSizeMake(300, h);
        
        collectionView.backgroundColor = Util.UIColorFromRGB(0xDAEFFE, alpha: 0.38)
        
    }
    @IBAction func closeTappen(sender: AnyObject) {
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: { (formSheet) -> Void in
            
        })
    }
}

extension ShareViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        
        return CGSize(width: cellwidth, height: cellwidth)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! UICollectionViewCell
        let imageView = cell.viewWithTag(1) as! UIImageView
        
        imageView.image = Util.coloredImage(
            UIImage(named: icons[indexPath.row])!,
            color: Util.UIColorFromRGB(0x1E90FF, alpha: 0.7))
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0:
            OpenidController.instance.wxShare(0, img: self.share_image, description: self.share_description, url: self.share_url)
            break;
        case 1:
            OpenidController.instance.wxShare(1, img: self.share_image, description: self.share_description, url: self.share_url)
            break;
        default:
            break;
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
}