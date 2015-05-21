//
//  AlertTableViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/05/19.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//


import UIKit

class AlertTableViewController: BaseViewController {
    // typealias
    typealias tappenAction = (sender: AnyObject) -> ()
    class tappenDic {
        var title:String!
        var tappen:tappenAction!
        init (title:String,tappen:tappenAction){
            self.title = title
            self.tappen = tappen
        }
    }
    
    @IBOutlet weak var TableView: UITableView!
    
    private var data:[tappenDic]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.formSheetController.presentedFormSheetSize = CGSizeMake(300, 10 + 20 + 44 + 10 + CGFloat(data.count) * 44 );
        TableView.backgroundColor = Util.UIColorFromRGB(0xDAEFFE, alpha: 0.5)
    }
    @IBAction func closeTappen(sender: AnyObject) {
        self.dismiss(true)
    }
    
    func dismiss(animated: Bool) {
        self.mz_dismissFormSheetControllerAnimated(animated, completionHandler: { (formSheet) -> Void in
            
        })
    }
    func show(vc:UIViewController,data:[tappenDic]){
        self.data = data
        Util.showActionSheet(vc, vc: self,style:MZFormSheetTransitionStyle.SlideFromBottom)
    }
}

extension AlertTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        //cell.textLabel?.text = self.data[indexPath.row].keys[0]
        let label = cell.viewWithTag(1) as! UILabel
        label.text = self.data[indexPath.row].title
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.dismiss(true)
        self.data[indexPath.row].tappen(sender: indexPath.row)
    }
}