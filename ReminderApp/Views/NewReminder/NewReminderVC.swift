//
//  NewReminderVC.swift
//  ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 8/25/25.
//

import UIKit

class NewReminderVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var titleText: String = ""
    private var descriptionText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil),
                           forCellReuseIdentifier: "TextFieldCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 52
        tableView.keyboardDismissMode = .onDrag
        tableView.layer.cornerRadius = 16
    }

}

extension NewReminderVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "TextFieldCell",
            for: indexPath
        ) as! TextFieldCell

        if indexPath.row == 0 {
            // Cell Title
            cell.textField.placeholder = "Title"
            cell.textField.font = .systemFont(ofSize: 17, weight: .regular)
            cell.textField.textColor = .neutral3
            cell.textField.returnKeyType = .next
            cell.onTextChanged = { [weak self] text in
                self?.titleText = text
            }
        } else {
            // Cell Description
            cell.textField.placeholder = "Description"
            cell.textField.font = .systemFont(ofSize: 17, weight: .regular)
            cell.textField.textColor = .neutral3
            cell.textField.returnKeyType = .done
            cell.onTextChanged = { [weak self] text in
                self?.descriptionText = text
            }
        }

        return cell
    }
}
