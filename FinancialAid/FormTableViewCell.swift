//
//  FormTableViewCell.swift
//  FinancialAid
//
//  Created by GaoChengliang on 16/5/25.
//  Copyright © 2016年 pku. All rights reserved.
//

import UIKit

class FormTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!

    func setupWithName(name: String, startDate: NSDate, endDate: NSDate, status: Int) {
        nameLabel.text = name
        startDateLabel.text = NSDateFormatter.outputFormatter().stringFromDate(startDate)
        endDateLabel.text = NSDateFormatter.outputFormatter().stringFromDate(endDate)
        if status == 1 {
            self.accessoryType = .Checkmark
        } else {
            self.accessoryType = .DisclosureIndicator
        }
    }
}
