//
//  GroupCallOutViewController.swift
//  Tomo
//
//  Created by ebuser on 2015/10/04.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class GroupCallOutViewController: UIViewController {
    
    var groupAnnotation: GroupAnnotation!

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDisplay()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupDisplay() {
        
        let group = groupAnnotation.group
        
        self.coverImageView.sd_setImageWithURL(NSURL(string: group.cover), placeholderImage: DefaultGroupImage)
        
        self.nameLabel.text = group.name
        
        if let posts = group.posts {
            self.detailLabel.text = "\(posts.count)个帖子"
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
