//
//  TagCell.swift
//  ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 8/25/25.
//

import UIKit

class TagCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func singleCellCorner() {
        containerView?.layer.masksToBounds = true
        containerView?.layer.cornerRadius = 12
        containerView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        containerView?.backgroundColor = .neutral5
    }
}
