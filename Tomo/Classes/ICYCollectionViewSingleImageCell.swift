//
//  ICYCollectionViewSingleImageCell.swift
//  Tomo
//
//  Created by eagle on 15/10/6.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ICYCollectionViewSingleImageCell: UICollectionViewCell {
    static let identifier = "ICYCollectionViewSingleImageCellIdentifier"
    
    static let minCenterScale = CGFloat(1.5)
    static let maxAspectFitScale = CGFloat(3.5)
    static let minAspectFitScale = CGFloat(1 / 3.5)
    
    var imageURL: String? {
        didSet {
            let placeholderImage = UIImage(named: "placeholder")
            if let url = imageURL {
                imageView.contentMode = .ScaleAspectFill
                imageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: placeholderImage, completed: { (image, _, _, _) -> Void in
                    if image == nil {
                        self.imageView.contentMode = .ScaleAspectFill
                        return
                    }
                    let size = image.size
                    let ratio = size.width / size.height
                    if size.height < (self.imageView.bounds.height / ICYCollectionViewSingleImageCell.minCenterScale)
                        && size.width < (self.imageView.bounds.width / ICYCollectionViewSingleImageCell.minCenterScale) {
                        self.imageView.contentMode = .Center
                    } else if ratio > ICYCollectionViewSingleImageCell.maxAspectFitScale
                    || ratio < ICYCollectionViewSingleImageCell.minAspectFitScale {
                        self.imageView.contentMode = .ScaleAspectFit
                    }else {
                        self.imageView.contentMode = .ScaleAspectFill
//                        self.imageView.faceAwareFill()
                    }
                })
            } else {
                imageView.contentMode = .ScaleAspectFill
                imageView.image = placeholderImage
            }
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

/// test -> faceAwareFill

let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
var ciiCache = Dictionary<Int, UIImage>()

extension UIImageView {
    func faceAwareFill(){
        self.contentMode = .ScaleAspectFill
        
        gcd.async(.Default){
            guard let image = self.image else { return }
            
            print("hashValue:\(image.hashValue)")
            if let newImage = ciiCache[image.hashValue] {
                if newImage != image {
                    self.contentMode = .TopLeft
                }
                self.image = newImage
                return
            }
            
            guard let ciimage = image.CIImage ?? CIImage(image: image) else { return }
            
            gcd.async(.Main){
                self.image = UIImage(named: "placeholder")
            }
            
            let scale = max(self.frame.size.width / image.size.width, self.frame.size.height / image.size.height)
            let facesRect = ciimage.rectWithFaces(scale)
            let newImage = image.imageWithFaces(self.frame.size, facesRect: facesRect, scale: scale)
            
            gcd.async(.Main){
                if newImage != image {
                    self.contentMode = .TopLeft
                }
                self.image = newImage
            }
            //
            if ciiCache.count > 20 {
                ciiCache.removeAll()
            }
            ciiCache[image.hashValue] = newImage
            
        }
    }
}

extension UIImage {
    func imageWithFaces(superViewSize: CGSize, facesRect: CGRect, scale: CGFloat = 1) -> UIImage {
        if facesRect == CGRectZero { return self }
        var imageRect = CGRectZero;
        imageRect.size.width = self.size.width * scale;
        imageRect.size.height = self.size.height * scale;
        imageRect.origin.x = min(0, max(-facesRect.origin.x + superViewSize.width/2 - facesRect.size.width/2, -imageRect.size.width + superViewSize.width));
        imageRect.origin.y = min(0, max(-facesRect.origin.y + superViewSize.height/2 - facesRect.size.height/2, -imageRect.size.height + superViewSize.height));
        
        imageRect = CGRectIntegral(imageRect)
        
        UIGraphicsBeginImageContextWithOptions(imageRect.size, true, 2)
        self.drawInRect(imageRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension CIImage {
    func rectWithFaces(scale: CGFloat = 1) -> CGRect {
        let faceFeatures = faceDetector.featuresInImage(self)
        
        guard faceFeatures.count > 0 else { return CGRectZero  }
        
        var facesRect: CGRect!
        
        faceFeatures.forEach {
            if facesRect == nil {
                facesRect = $0.bounds
            } else {
                facesRect = CGRectUnion(facesRect, $0.bounds)
            }
        }
        //We need to 'flip' the Y coordinate to make it match the iOS coordinate system one
        facesRect.origin.y = self.extent.size.height - facesRect.origin.y - facesRect.size.height
        
        if 1 == scale {
            return facesRect
        }
        return CGRectMake(facesRect.origin.x * scale, facesRect.origin.y * scale, facesRect.size.width * scale, facesRect.size.height * scale)
    }
}
