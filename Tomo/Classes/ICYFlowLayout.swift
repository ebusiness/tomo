//
//  ICYFlowLayout.swift
//  Tomo
//
//  Created by eagle on 15/10/6.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class ICYFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let attributes = super.layoutAttributesForElementsInRect(rect) {
            let newAttributes = attributes.map({
                self.leftAlignedAttributes($0)
            })
            return newAttributes
        }
        return nil
    }
    
    private func leftAlignedAttributes(attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let indexPath = attributes.indexPath
        let newAttributes = attributes
        if indexPath.row == 0 &&
            collectionView?.numberOfItemsInSection(indexPath.section) == 1 {
            newAttributes.frame.origin.x = sectionInset.left
        }
        // FIXME: 多行的情况后续加入……
        return newAttributes
    }
}
