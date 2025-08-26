import UIKit

struct ReminderItem { var title: String; var note: String }

final class ReminderVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newReminderButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var items: [ReminderItem] = []
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No Reminders"
        label.textColor = .neutral3
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [.foregroundColor: UIColor.colorC6C6CB]
        )        
        tableView.register(UINib(nibName: "ReminderCell", bundle: nil), forCellReuseIdentifier: "ReminderCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .singleLine
        
        applyEmptyState(isEmpty: items.isEmpty)
        newReminderButton.addTarget(self, action: #selector(addNewReminder), for: .touchUpInside)
    }
    
    private func applyEmptyState(isEmpty: Bool) {
        tableView.backgroundView = isEmpty ? emptyLabel : nil
    }
    
    @objc private func addNewReminder() {
        let wasEmpty = items.isEmpty
        items.insert(ReminderItem(title: "", note: ""), at: 0)
        
        if wasEmpty {
            applyEmptyState(isEmpty: false)
            tableView.reloadData()
        } else {
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        let ip = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: ip, at: .top, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            (self.tableView.cellForRow(at: ip) as? ReminderCell)?.titleTextView.becomeFirstResponder()
        }
    }
}

extension ReminderVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ReminderCell",
            for: indexPath
        ) as! ReminderCell
        
        let item = items[indexPath.row]
        cell.configure(title: item.title, note: item.note, useHints: true)
        
        cell.onTitleChanged = { [weak self] text in
            guard let self = self, indexPath.row < self.items.count else { return }
            self.items[indexPath.row].title = text
        }
        cell.onNoteChanged = { [weak self] text in
            guard let self = self, indexPath.row < self.items.count else { return }
            self.items[indexPath.row].note = text
        }
        //        cell.onTapInfo = { [weak self] in
        //            self?.view.endEditing(true)
        //            // mở màn chi tiết nếu cần
        //        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _,_,done in
            guard let self = self else { return }
            self.items.remove(at: indexPath.row)
            if self.items.isEmpty {
                self.applyEmptyState(isEmpty: true)
                tableView.reloadData()
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
