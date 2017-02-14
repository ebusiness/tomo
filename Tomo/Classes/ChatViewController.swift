//
//  ChatViewController.swift
//  Tomo
//
//  Created by starboychina on 2017/02/13.
//  Copyright © 2017 e-business. All rights reserved.
//

import UIKit
import SlackTextViewController

final class ChatViewController: SLKTextViewController {

    override var tableView: UITableView {
        return super.tableView!
    }

    var messages = [MessageEntity]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadMessages()
    }

    private func loadMessages() {

        Router.GroupMessage.FindByGroupId(id: "562f4d1b0286d66c05cbba59", before: nil)
            .response {
                if $0.result.isFailure {
                    return
                }
                guard let result: [MessageEntity] = MessageEntity.collection($0.result.value!) else {
                    return
                }

                result.forEach {
                    if $0.from.id == me.id {
                        $0.from = me
                    }
                    self.messages.insert($0, at: 0)
                }
                self.tableView.reloadData()
            }
    }
}
