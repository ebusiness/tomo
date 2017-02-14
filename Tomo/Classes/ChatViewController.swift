//
//  ChatViewController.swift
//  Tomo
//
//  Created by starboychina on 2017/02/13.
//  Copyright © 2017 e-business. All rights reserved.
//

import SlackTextViewController
import UIKit

final class ChatViewController: SLKTextViewController {

    override var tableView: UITableView {
        return super.tableView!
    }

    var messages = [MessageEntity]()
    private var cellForCalculatorHeight: ChatTableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()

        let nibs = Bundle.main.loadNibNamed("ChatTableViewCell", owner: nil, options: nil)!
        if let cell = nibs.first as? ChatTableViewCell {
            self.cellForCalculatorHeight = cell
        }

        self.loadMessages()
    }

    private func configureTableView() {
//        self.isInverted = false
        self.textView.placeholder = "Message"

        let nib = UINib(nibName: "ChatTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "Cell")
        self.tableView.separatorStyle = .none
        self.textView.registerMarkdownFormattingSymbol("*", withTitle: "Bold")
        self.textView.registerMarkdownFormattingSymbol("_", withTitle: "Italics")
        self.textView.registerMarkdownFormattingSymbol("~", withTitle: "Strike")
        self.textView.registerMarkdownFormattingSymbol("`", withTitle: "Code")
        self.textView.registerMarkdownFormattingSymbol("```", withTitle: "Preformatted")
        self.textView.registerMarkdownFormattingSymbol(">", withTitle: "Quote")
    }

    override func didPressRightButton(_ sender: Any?) {
        self.view .endEditing(true)
        guard let text = self.textView.text, text != "" else {
            return
        }
        super.didPressRightButton(sender)

        let newMessage = MessageEntity()
        newMessage.id = ""
//        newMessage.to = friend
//        newMessage.group = self.group
        newMessage.from = me
        newMessage.type = .text
        newMessage.content = text
        newMessage.createDate = Date()
        self.messages.insert(newMessage, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }

    private func loadMessages() {

        Router.GroupMessage.FindByGroupId(id: "562f4b6c0286d66c05cbab3a", before: nil)
            .response {
                if $0.result.isFailure {
                    return
                }
                guard let result: [MessageEntity] = MessageEntity.collection($0.result.value!) else {
                    return
                }

                self.messages = result.map {
                    if $0.from.id == me.id {
                        $0.from = me
                    }
                    return $0
                }

                self.tableView.reloadData()
            }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? ChatTableViewCell

        self.configure(cell: cell!, forRowAt: indexPath)
        cell?.transform = tableView.transform

        return cell!
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.configure(cell: self.cellForCalculatorHeight!, forRowAt: indexPath)
        return self.cellForCalculatorHeight.getHeight()
    }

    private func configure(cell: ChatTableViewCell, forRowAt indexPath: IndexPath) {
        cell.message = self.messages[indexPath.row]
        if indexPath.row == self.messages.count - 1 {
            cell.dateOfPreviousMessage = Date(timeIntervalSince1970: 0)
        } else {
            cell.dateOfPreviousMessage = self.messages[indexPath.row + 1].createDate
        }
    }
}
