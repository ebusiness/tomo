//
//  PickerTableViewController.swift
//  Tomo
//
//  Created by starboychina on 2015/08/04.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

import UIKit

final class PickerTableViewController: UITableViewController {
    
    var pickerData = ["男","女"]
    var selected:String?
    var didSelected: ((_ selected:String) -> Void)!

}

// MARK: - UITableView DataSource

extension PickerTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pickerData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let label = self.pickerData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        
        cell.accessoryType = .none
        if self.selected == label {
            cell.accessoryType = .checkmark
        }
        cell.textLabel?.text = label
        return cell
    }
}

// MARK: - UITableView Delegate

extension PickerTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.selected = self.pickerData[indexPath.row]
        self.tableView.reloadData()
        
        self.didSelected(self.pickerData[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }
}
