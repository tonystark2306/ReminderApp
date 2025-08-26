//
//  TextFieldCell.swift
//  ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 8/25/25.
//

import UIKit

class TextFieldCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var separatorLine: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var containerView: UIView!
    var onTextChanged: ((String) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 12
        containerView.backgroundColor = .clear
        textField.borderStyle = .none
        textField.backgroundColor = .neutral5
        textField.clearButtonMode = .whileEditing
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightViewMode = .always
        textField.addTarget(self, action: #selector(didChanged), for: .editingChanged)
        textField.delegate = self
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        separatorLine.isHidden = true
    }

    func configure(placeholder: String, text: String?, returnKey: UIReturnKeyType) {
        textField.placeholder = placeholder
        textField.text = text
        textField.returnKeyType = returnKey
    }

    func firstCellCorner() {
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        separatorLine.isHidden = false
    }

    func secondCellCorner() {
        containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        separatorLine.isHidden = true
    }

    @objc private func didChanged() { onTextChanged?(textField.text ?? "") }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
