//
//  CalendarCell.swift
//  ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 8/25/25.
//

import UIKit

class CalendarCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    var onDateChanged: ((Date) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(changed), for: .valueChanged)
    }

    func secondCellCorner() {
        containerView?.layer.masksToBounds = true
        containerView?.layer.cornerRadius = 12
        containerView?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        containerView?.backgroundColor = .neutral5
    }

    func setDate(_ date: Date?) {
        if let d = date { datePicker.date = d } else { datePicker.date = Date() }
    }

    @objc private func changed() { onDateChanged?(datePicker.date) }
}
