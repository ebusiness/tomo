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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //データの初期化
        tagUIController.serTagView(.normal)
        self.tagListView.setTapHandler { (tagView) -> Void in
            self.delegate?.whenTagDidSelected(tagView)
        }
    }
}