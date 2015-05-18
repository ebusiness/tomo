//
//  MessageGroupViewController.swift
//  Tomo
//
//  Created by 張志華 on 2015/05/11.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

class MessageGroupViewController: MessageViewController {

    var group: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        DBController.makeAllMessageGroupRead(group)
    }
    
    override func loadMessages() {
        frc = DBController.messageWithGroup(group)
        frc.delegate = self
        
        ApiController.getMessage { (error) -> Void in
            
        }
        
        if !Defaults.hasKey("didGetMessageSent") {
            self.messageSend = true
            ApiController.getMessageSent { (error) -> Void in
                if error == nil {
                    Defaults["didGetMessageSent"] = true
                }
            }
        }
    }
    
    override func sendMessage(text: String) {
        messageSend = true
        
        DBController.createMessageGroup(group, text: text)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        ApiController.sendMessage(group, to: nil, content: text)
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
