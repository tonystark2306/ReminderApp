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
    private var isDateEnabled: Bool = true
    private var isCalendarExpanded: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "TextFieldCell")
        tableView.register(UINib(nibName: "DateCell", bundle: nil), forCellReuseIdentifier: "DateCell")
        tableView.register(UINib(nibName: "CalendarCell", bundle: nil), forCellReuseIdentifier: "CalendarCell")
        tableView.register(UINib(nibName: "TagCell", bundle: nil), forCellReuseIdentifier: "TagCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 52
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.tableHeaderView = UIView(frame: .zero)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            view.endEditing(true)
        }
}

extension NewReminderVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return (isCalendarExpanded && isDateEnabled) ? 2 : 1
        case 2: return 1
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
            if indexPath.row == 0 {
                cell.configure(placeholder: "Title", text: titleText, returnKey: .next)
                cell.textField.font = .systemFont(ofSize: 17, weight: .regular)
                cell.textField.textColor = .neutral3
                cell.onTextChanged = { [weak self] t in self?.titleText = t }
                cell.firstCellCorner()
            } else {
                cell.configure(placeholder: "Description", text: descriptionText, returnKey: .done)
                cell.textField.font = .systemFont(ofSize: 17, weight: .regular)
                cell.textField.textColor = .neutral3
                cell.onTextChanged = { [weak self] t in self?.descriptionText = t }
                cell.secondCellCorner()
            }
            return cell
        case 1:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! DateCell
                cell.configure(isOn: isDateEnabled)
                if isCalendarExpanded && isDateEnabled { cell.firstCellCorner() } else { cell.singleCellCorner() }
                cell.onToggle = { [weak self] on in
                    guard let self = self else { return }
                    self.isDateEnabled = on
                    self.isCalendarExpanded = on
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
                cell.secondCellCorner()
                return cell
            }
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath) as! TagCell
            cell.singleCellCorner()
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 52
        case 1: return indexPath.row == 0 ? 52 : 330
        case 2: return 52
        default: return 52
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 16 }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
