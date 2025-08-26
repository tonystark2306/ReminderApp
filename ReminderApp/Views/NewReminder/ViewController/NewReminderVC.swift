//
//  NewReminder.swift
//  ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 8/25/25.
//

import UIKit
import RealmSwift

class NewReminderVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var reminderID: ObjectId?
    private let realm = try! Realm()
    private var reminder: Reminder!
    private var isCalendarExpanded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let id = reminderID,
              let obj = realm.object(ofType: Reminder.self, forPrimaryKey: id),
              !obj.isInvalidated else { dismiss(animated: true); return }
        reminder = obj

        isCalendarExpanded = reminder.dueEnabled

        setupNavBar()
        setupTableView()

        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadSections(IndexSet(integer: 2), with: .none)
    }

    private func setupNavBar() {
        title = "New Reminder"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
    }

    @objc private func cancelTapped() { dismiss(animated: true) }
    @objc private func doneTapped()   { view.endEditing(true); dismiss(animated: true) }

    private func setupTableView() {
        tableView.register(UINib(nibName: "TextFieldCell", bundle: nil), forCellReuseIdentifier: "TextFieldCell")
        tableView.register(UINib(nibName: "DateCell", bundle: nil), forCellReuseIdentifier: "DateCell")
        tableView.register(UINib(nibName: "CalendarCell", bundle: nil), forCellReuseIdentifier: "CalendarCell")
        tableView.register(UINib(nibName: "TagCell", bundle: nil), forCellReuseIdentifier: "TagCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 52
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setDateEnabled(_ enabled: Bool) {
        let hadPicker = isCalendarExpanded && reminder.dueEnabled
        try? realm.write {
            reminder.dueEnabled = enabled
            if enabled && reminder.dueDate == nil { reminder.dueDate = Date() }
            reminder.updatedAt = Date()
        }
        isCalendarExpanded = enabled

        tableView.beginUpdates()
        if enabled && !hadPicker {
            tableView.insertRows(at: [IndexPath(row: 1, section: 1)], with: .fade)
        } else if !enabled && hadPicker {
            tableView.deleteRows(at: [IndexPath(row: 1, section: 1)], with: .fade)
        }
        tableView.endUpdates()
    }
}

extension NewReminderVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 3 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return (isCalendarExpanded && reminder.dueEnabled) ? 2 : 1
        case 2: return 1
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
            if indexPath.row == 0 {
                cell.configure(placeholder: "Title", text: reminder.title, returnKey: .next)
                cell.textField.font = .systemFont(ofSize: 17, weight: .regular)
                cell.textField.textColor = .neutral3
                cell.onTextChanged = { [weak self] t in
                    guard let self = self else { return }
                    try? self.realm.write { self.reminder.title = t; self.reminder.updatedAt = Date() }
                }
                cell.firstCellCorner()
            } else {
                cell.configure(placeholder: "Description", text: reminder.note, returnKey: .done)
                cell.textField.font = .systemFont(ofSize: 17, weight: .regular)
                cell.textField.textColor = .neutral3
                cell.onTextChanged = { [weak self] t in
                    guard let self = self else { return }
                    try? self.realm.write { self.reminder.note = t; self.reminder.updatedAt = Date() }
                }
                cell.secondCellCorner()
            }
            return cell

        case 1:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! DateCell
                cell.configure(isOn: reminder.dueEnabled)
                if isCalendarExpanded && reminder.dueEnabled { cell.firstCellCorner() } else { cell.singleCellCorner() }
                cell.onToggle = { [weak self] on in self?.setDateEnabled(on) }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
                cell.secondCellCorner()
                cell.setDate(reminder.dueDate)
                cell.onDateChanged = { [weak self] d in
                    guard let self = self else { return }
                    try? self.realm.write { self.reminder.dueDate = d; self.reminder.updatedAt = Date() }
                }
                return cell
            }

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath) as! TagCell
            cell.singleCellCorner()
            let names = Array(reminder.tags)
            cell.configure(names: names)
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == 2 && indexPath.row == 0 {
            let tagVC = TagVC(nibName: "TagVC", bundle: nil)
            tagVC.reminderID = reminder.id
            navigationController?.pushViewController(tagVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 16 }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(); v.backgroundColor = .clear; return v
    }
}
