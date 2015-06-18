//
//  TagSearchResultsViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/06/17.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

protocol TagSearchResultsDelegate : NSObjectProtocol {
    func whenTagDidSelected(tagView: AMTagView)
}
class TagSearchResultsViewController: UIViewController {
    
    @IBOutlet weak var tagListView: AMTagListView!
    var delegate:TagSearchResultsDelegate?
    
    let tagColor_normal = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1)
    let innerTagColor_normal =  UIColor(white: 1, alpha: 0.3)
    
    let tagColor_highlight = UIColor.blueColor()
    let innerTagColor_highlight =  UIColor.redColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.didLoad();
    }
}
//データの初期化
extension TagSearchResultsViewController {
    func didLoad(){
        AMTagView.appearance().tagLength = 10
        AMTagView.appearance().textPadding = 14
        AMTagView.appearance().textFont = UIFont(name: "Futura", size: 14)
        AMTagView.appearance().tagColor = tagColor_normal
        AMTagView.appearance().innerTagColor = innerTagColor_normal
        self.tagListView.setTapHandler { (tagView) -> Void in
            self.delegate?.whenTagDidSelected(tagView)
        }
    }
}