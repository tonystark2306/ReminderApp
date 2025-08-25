//
//  TagVC.swift
//  ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 8/25/25.
//

import UIKit

class TagVC: UIViewController {

    @IBOutlet weak var healthButton: UIButton!
    @IBOutlet weak var routineButton: UIButton!
    @IBOutlet weak var workButton: UIButton!
    @IBOutlet weak var learnButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        containerView.layer.cornerRadius = 16
    }

}
