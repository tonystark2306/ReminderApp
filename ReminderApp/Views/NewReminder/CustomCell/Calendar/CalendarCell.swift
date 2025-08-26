//
//  CalendarCell.swift
//  ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 8/25/25.
//

import UIKit

class CalendarCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var picker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        picker.preferredDatePickerStyle = .inline
        picker.datePickerMode = .date
    }
    
    func secondCellCorner() {
        containerView?.layer.masksToBounds = true
        containerView?.layer.cornerRadius = 12
        containerView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        containerView?.backgroundColor = .neutral5
    }
}
