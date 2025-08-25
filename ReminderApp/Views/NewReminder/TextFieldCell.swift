//
//  TextFieldCell.swift
//  ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 8/25/25.
//

import UIKit

class TextFieldCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var containerView: UIView!
    var onTextChanged: ((String) -> Void)?

        override func awakeFromNib() {
            super.awakeFromNib()
            selectionStyle = .none
            textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        }

        @objc private func textDidChange() {
            onTextChanged?(textField.text ?? "")
        }
    
}
