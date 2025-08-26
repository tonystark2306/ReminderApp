//
//  TagVC.swift
//  ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 8/25/25.
//

import UIKit
import RealmSwift

class TagVC: UIViewController {
    @IBOutlet weak var healthButton: UIButton!
    @IBOutlet weak var routineButton: UIButton!
    @IBOutlet weak var workButton: UIButton!
    @IBOutlet weak var learnButton: UIButton!
    @IBOutlet weak var containerView: UIView!

    var reminderID: ObjectId!

    private let realm = try! Realm()
    private var reminder: Reminder!
    private var selected = Set<String>()

    override func viewDidLoad() {
        super.viewDidLoad()
        reminder = realm.object(ofType: Reminder.self, forPrimaryKey: reminderID)
        selected = Set(reminder.tags.map { $0 })
        setupNavBar()
        setupUI()
        applyState()
    }

    private func setupNavBar() {
        title = "Tags"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
    }

    private func setupUI() {
        containerView.layer.cornerRadius = 16
        [learnButton, workButton, routineButton, healthButton].enumerated().forEach { (idx, b) in
            guard let b = b else { return }
            b.tag = idx
            b.addTarget(self, action: #selector(tapTag(_:)), for: .touchUpInside)
        }
        learnButton.setTitle("Học tập", for: .normal)
        workButton.setTitle("Công việc", for: .normal)
        routineButton.setTitle("Thói quen", for: .normal)
        healthButton.setTitle("Sức khoẻ", for: .normal)
    }

    @objc private func tapTag(_ sender: UIButton) {
        let name = nameFor(sender.tag)
        if selected.contains(name) { selected.remove(name) } else { selected.insert(name) }
        applyState()
    }

    private func applyState() {
        style(learnButton, name: "Học tập", color: .accent)
        style(workButton,  name: "Công việc", color: .warning)
        style(routineButton, name: "Thói quen", color: .low)
        style(healthButton, name: "Sức khoẻ", color: .primary)
    }

    private func style(_ button: UIButton?, name: String, color: UIColor) {
        guard let button = button else { return }
        let on = selected.contains(name)
        var config = button.configuration ?? .plain()
        config.background.backgroundColor = on ? color : .neutral3
        button.configuration = config
        button.setTitleColor(.white, for: .normal)
    }

    private func nameFor(_ tag: Int) -> String {
        switch tag { case 0: return "Học tập"; case 1: return "Công việc"; case 2: return "Thói quen"; default: return "Sức khoẻ" }
    }

    @objc private func cancelTapped() { navigationController?.popViewController(animated: true) }

    @objc private func doneTapped() {
        try? realm.write {
            reminder.tags.removeAll()
            reminder.tags.append(objectsIn: Array(selected))
            reminder.updatedAt = Date()
        }
        navigationController?.popViewController(animated: true)
    }
}
