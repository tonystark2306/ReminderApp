//
//  ReminderVC.swift
//  ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 8/25/25.
//

import UIKit

class ReminderVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newReminderButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [.foregroundColor: UIColor.colorC6C6CB]
        )
        
        if let iconView = searchBar.searchTextField.leftView as? UIImageView {
            iconView.tintColor = .colorC6C6CB
        }
    }
    

}
