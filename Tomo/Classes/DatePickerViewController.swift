//
//  DatePickerViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/08/04.
//  Copyright © 2015 e-business. All rights reserved.
//

import UIKit

final class DatePickerViewController: UIViewController {

    var date:Date?

    @IBOutlet weak fileprivate var datePicker: UIDatePicker!

    var didSelected: ((_ selected:Date) -> Void)!

    override func viewDidLoad() {

        super.viewDidLoad()

        if let date = self.date {
            self.datePicker.setDate(date, animated: true)
        }
    }

    @IBAction func save(_ sender: Any) {
        self.didSelected(datePicker.date)
        self.navigationController?.pop(animated: true)
    }
}
