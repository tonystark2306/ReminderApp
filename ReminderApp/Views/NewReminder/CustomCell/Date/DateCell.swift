//
//  DateCell.swift
//  ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 8/25/25.
//

import UIKit

class DateCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var switchButton: UISwitch!

    var onToggle: ((Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        switchButton.addTarget(self, action: #selector(toggled), for: .valueChanged)
    }

    func configure(isOn: Bool) {
        switchButton.isOn = isOn
    }

    func firstCellCorner() {
        containerView?.layer.masksToBounds = true
        containerView?.layer.cornerRadius = 12
        containerView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView?.backgroundColor = .neutral5
    }

    func singleCellCorner() {
        containerView?.layer.masksToBounds = true
        containerView?.layer.cornerRadius = 12
        containerView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        containerView?.backgroundColor = .neutral5
    }

    @objc private func toggled() {
        onToggle?(switchButton.isOn)
    }
}
