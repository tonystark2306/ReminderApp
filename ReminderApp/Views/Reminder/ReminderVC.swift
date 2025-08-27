//
//  ReminderVC.swift
//  ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 8/25/25.
//

import UIKit
import RealmSwift

class ReminderVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newReminderButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!

    private let realm = try! Realm()
    private var items: Results<Reminder>!
    private var token: NotificationToken?

    private var todayList: [Reminder] = []
    private var upcomingList: [Reminder] = []

    private var visibleToday: [Reminder] = []
    private var visibleUpcoming: [Reminder] = []

    private var shouldFocusNewToday = false
    private var lastInsertedID: ObjectId?
    private var searchText: String = ""
    private var searchWorkItem: DispatchWorkItem?

    private enum SortMode {
        case createdAtAsc
        case titleAsc
        case dueDateAsc
    }
    private var sortMode: SortMode = .createdAtAsc

    private var fallbackSortButton: UIButton?

    private lazy var emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No Reminders"
        l.textColor = .neutral3
        l.font = .systemFont(ofSize: 20, weight: .regular)
        l.textAlignment = .center
        return l
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        regroup()
        applyFilter()
        tableView.reloadData()
        applyEmptyStateVisible()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [.foregroundColor: UIColor.colorC6C6CB]
        )
        (searchBar.searchTextField.leftView as? UIImageView)?.tintColor = .colorC6C6CB

        tableView.register(UINib(nibName: "ReminderCell", bundle: nil), forCellReuseIdentifier: "ReminderCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none

        setupSortButton()

        items = realm.objects(Reminder.self).sorted(byKeyPath: "createdAt", ascending: true)

        token = items.observe { [weak self] _ in
            guard let self = self else { return }
            if self.view.recursiveFirstResponder() == nil {
                self.regroup()
                self.applyFilter()
                self.tableView.reloadData()
                self.applyEmptyStateVisible()
                if self.shouldFocusNewToday, let id = self.lastInsertedID, self.searchText.isEmpty {
                    self.shouldFocusNewToday = false
                    if let row = self.visibleToday.firstIndex(where: { $0.id == id }) {
                        let ip = IndexPath(row: row, section: 0)
                        self.tableView.scrollToRow(at: ip, at: .middle, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            (self.tableView.cellForRow(at: ip) as? ReminderCell)?
                                .titleTextView.becomeFirstResponder()
                        }
                    }
                }
            }
        }

        applyFilter()
        applyEmptyStateVisible()
        newReminderButton.addTarget(self, action: #selector(addNewReminder), for: .touchUpInside)
    }

    deinit {
        token?.invalidate()
    }

    private func setupSortButton() {
        let bar = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"), style: .plain, target: self, action: #selector(showSortMenu))
        navigationItem.rightBarButtonItem = bar

        if navigationController == nil {
            let btn = UIButton(type: .system)
            btn.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
            btn.addTarget(self, action: #selector(showSortMenu), for: .touchUpInside)
            btn.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(btn)
            NSLayoutConstraint.activate([
                btn.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
                btn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
            ])
            fallbackSortButton = btn
        } else {
            fallbackSortButton?.removeFromSuperview()
            fallbackSortButton = nil
        }
    }

    @objc private func showSortMenu() {
        let ac = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        let byCreated = UIAlertAction(title: "Created date", style: .default) { _ in
            self.sortMode = .createdAtAsc
            self.regroup(); self.applyFilter(); self.tableView.reloadData()
        }
        let byTitle = UIAlertAction(title: "Title", style: .default) { _ in
            self.sortMode = .titleAsc
            self.regroup(); self.applyFilter(); self.tableView.reloadData()
        }
        let byDue = UIAlertAction(title: "Due date", style: .default) { _ in
            self.sortMode = .dueDateAsc
            self.regroup(); self.applyFilter(); self.tableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(byCreated); ac.addAction(byTitle); ac.addAction(byDue); ac.addAction(cancel)

        if let pop = ac.popoverPresentationController, let btn = fallbackSortButton {
            pop.sourceView = btn
            pop.sourceRect = btn.bounds
        }
        present(ac, animated: true)
    }

    private func applyEmptyStateVisible() {
        let isVisibleEmpty = visibleToday.isEmpty && visibleUpcoming.isEmpty
        tableView.backgroundView = isVisibleEmpty ? emptyLabel : nil
    }

    @objc private func addNewReminder() {
        shouldFocusNewToday = true
        try? realm.write {
            let r = Reminder()
            r.createdAt = Date()
            r.updatedAt = Date()
            r.dueEnabled = true
            r.dueDate = Date()
            realm.add(r)
            lastInsertedID = r.id
        }
    }

    private func presentNewReminder(for reminder: Reminder) {
        guard !reminder.isInvalidated else { return }
        view.endEditing(true)
        let vc = NewReminderVC(nibName: "NewReminderVC", bundle: nil)
        vc.reminderID = reminder.id
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .automatic
        present(nav, animated: true)
    }

    private func item(at indexPath: IndexPath) -> Reminder {
        return indexPath.section == 0 ? visibleToday[indexPath.row] : visibleUpcoming[indexPath.row]
    }

    private func regroup() {
        let cal = Calendar.current
        let now = Date()
        let endOfToday = cal.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now
        let src = items.filter { $0.dueEnabled && $0.dueDate != nil }

        let todays = src.filter { cal.isDateInToday($0.dueDate!) }
        let upcomings = src.filter { ($0.dueDate ?? now) > endOfToday }

        switch sortMode {
        case .createdAtAsc:
            todayList = todays.sorted { $0.createdAt < $1.createdAt }
            upcomingList = upcomings.sorted { $0.createdAt < $1.createdAt }
        case .titleAsc:
            todayList = todays.sorted { $0.title.lowercased() < $1.title.lowercased() }
            upcomingList = upcomings.sorted { $0.title.lowercased() < $1.title.lowercased() }
        case .dueDateAsc:
            todayList = todays.sorted { ($0.dueDate ?? now) < ($1.dueDate ?? now) }
            upcomingList = upcomings.sorted { ($0.dueDate ?? now) < ($1.dueDate ?? now) }
        }
    }

    private func applyFilter() {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty {
            visibleToday = todayList
            visibleUpcoming = upcomingList
        } else {
            visibleToday = todayList.filter { $0.title.lowercased().contains(q) }
            visibleUpcoming = upcomingList.filter { $0.title.lowercased().contains(q) }
        }
    }
}

extension ReminderVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? visibleToday.count : visibleUpcoming.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = section == 0 ? "Today" : "Upcoming"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .neutral1
        let container = UIView()
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4)
        ])
        return container
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0, todayList.isEmpty { return 0 }
        if section == 1, upcomingList.isEmpty { return 0 }
        return 32
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ReminderCell",
            for: indexPath
        ) as! ReminderCell

        let obj = item(at: indexPath)
        cell.configure(title: obj.title, note: obj.note, useHints: true)

        cell.onTitleChanged = { [weak self] text in
            guard let self = self else { return }
            try? self.realm.write { obj.title = text; obj.updatedAt = Date() }
        }
        cell.onNoteChanged = { [weak self] text in
            guard let self = self else { return }
            try? self.realm.write { obj.note = text; obj.updatedAt = Date() }
        }

        weak var weakCell = cell
        cell.onTapInfo = { [weak self] in
            guard let self = self,
                let ip = tableView.indexPath(for: weakCell!) else { return }
            self.presentNewReminder(for: self.item(at: ip))
        }

        cell.onTapDone = { [weak self] in
            guard let self = self,
                  let ip = tableView.indexPath(for: weakCell!) else { return }
            let obj = self.item(at: ip)
            try? self.realm.write { self.realm.delete(obj) }
            self.regroup()
            self.applyFilter()
            self.tableView.reloadData()
            self.applyEmptyStateVisible()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _,_,done in
            guard let self = self else { return }
            let obj = self.item(at: indexPath)
            try? self.realm.write { self.realm.delete(obj) }
            self.regroup()
            self.applyFilter()
            self.tableView.reloadData()
            self.applyEmptyStateVisible()
            done(true)
        }
        delete.backgroundColor = .primary
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension ReminderVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.searchText = searchText
            self.applyFilter()
            self.tableView.reloadData()
            self.applyEmptyStateVisible()
        }
        searchWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: work)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

private extension UIView {
    func recursiveFirstResponder() -> UIView? {
        if isFirstResponder { return self }
        for v in subviews {
            if let r = v.recursiveFirstResponder() { return r }
        }
        return nil
    }
}
