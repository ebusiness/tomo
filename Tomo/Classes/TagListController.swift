//
//  TagListController.swift
//  Tomo
//
//  Created by starboychina on 2015/06/15.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class TagListController: UIViewController {
    var sendertag:Int = 0
    var tagtype = ""

    @IBOutlet weak var titleItem: UIBarButtonItem!
    @IBOutlet weak var tagListView: AMTagListView!
    
    var tagSearchViewController = TagSearchController()
    
    let usertags = DBController.myUser()?.tags
    var hotTags:[Tag] = []
    
    let tagColor_normal = UIColor(red:0.12, green:0.55, blue:0.84, alpha:1)
    let innerTagColor_normal =  UIColor(white: 1, alpha: 0.3)
    
    let tagColor_highlight = UIColor.blueColor()
    let innerTagColor_highlight =  UIColor.redColor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch (self.sendertag) {
        case 1:
            self.titleItem.title = "出身地"
            self.tagtype = "hometown"
            break
        case 2:
            self.titleItem.title = "現場"
            self.tagtype = "workplace"
            break
        case 3:
            self.titleItem.title = "大学"
            self.tagtype = "university"
            break;
        case 4:
            self.titleItem.title = "以前の職場"
            self.tagtype = "workplace"
            break;
        case 5:
            self.titleItem.title = "言語"
            self.tagtype = "language"
            break;
        case 6:
            self.titleItem.title = "興味"
            self.tagtype = "interest"
            break;
        default:
            break;
        }
        self.didLoad();
        //closeButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))//园
    }
    //保存
    @IBAction func saveAction(sender: AnyObject) {
        ApiController.editUserTags(self.tagtype, tags: self.getTags(isSelectedOnly: true), done: { (error) -> Void in

        })
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //検索へ
    @IBAction func tappenSearchBtn(sender: AnyObject) {
        tagSearchViewController.resultVC.delegate = self
        tagSearchViewController.tagtype = self.tagtype
        self.presentViewController(tagSearchViewController, animated: true) { () -> Void in
            
        }
    }
}
//データの初期化
extension TagListController {
    func didLoad(){
        AMTagView.appearance().tagLength = 10
        AMTagView.appearance().textPadding = 14
        AMTagView.appearance().textFont = UIFont(name: "Futura", size: 14)
        AMTagView.appearance().tagColor = tagColor_normal
        AMTagView.appearance().innerTagColor = innerTagColor_normal
        
        self.addMyTags()
        
        self.getHotTags()
        
        self.tagListView.setTapHandler { (tagview) -> Void in
            self.tapHander(tagview)
        }
    }
    //自分のタグを取得
    func addMyTags(){
        if let usertags = usertags {
            var tags = self.getTags()
            for usertag in usertags{
                if let usertag = usertag as? Tag,
                    tag_name = usertag.name
                   where usertag.type == self.tagtype &&
                        tags.indexOf(tag_name) == nil{
                            
                    self.addMyTag(tag_name)
                }
            }
        }
    }
    //Hot tags
    func getHotTags(){
        ApiController.getTags(self.tagtype, name: nil, done: { (result, error) -> Void in
            if let result = result {
                self.hotTags = result
                self.addHotTags()
                
            }
        })
    }
    //Hot tags
    func addHotTags(){
        var tags = self.getTags()
        for tag in self.hotTags {
            if let text = tag.name{
                if let index = tags.indexOf(text) {
                    //追加済み
                }else{
                    self.tagListView.addTag(text)
                }
            }
        }

    }
    //画面に表示しているタグを取得
    func getTags(isSelectedOnly:Bool = false) -> [String] {
        var tags:[String] = []
        let tagviews = self.tagListView.tags
        
        for view in tagviews {
            if !isSelectedOnly{
                tags.append(view.tagText())
            }else if view.tag == 1 {
                tags.append(view.tagText())
            }
        }
        return tags
    }
    //tag on click
    func tapHander(tagview:AMTagView){
        if(tagview.tag == 0){
            tagview.tag = 1
            tagview.innerTagColor = innerTagColor_highlight
            tagview.tagColor = tagColor_highlight
        }else{
            tagview.tag = 0
            tagview.tagColor = tagColor_normal
            tagview.innerTagColor = innerTagColor_normal
        }
//        let txt = tagview.tagText()
//        tagview.tag = 1
//        println(txt)
    }
    //自分のタグ
    func addMyTag(text:String){
        let tagview = AMTagView();
        tagview.setupWithText(text)
        tapHander(tagview)
        self.tagListView.addTagView(tagview)
    }
}


// MARK: - TagSearchResultsDelegate

extension TagListController: TagSearchResultsDelegate {
    //タグ検索結果ー＞タグを選択する場合
    func whenTagDidSelected(tagView: AMTagView) {
        var tagviews = self.tagListView.tags
        self.tagListView.removeAllTags()
        self.addMyTag(tagView.tagText())
        self.addMyTags()
        self.addHotTags()
        tagSearchViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}