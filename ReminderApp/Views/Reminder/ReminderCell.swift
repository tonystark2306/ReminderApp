//
//  ReminderCell.swift
//  ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 8/25/25.
//

import UIKit

class ReminderCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var infoButton: UIButton!
    
    private let hintTitle = "Title"
    private let hintNote = "Reminders"
    private var isHintTitle = false
    private var isHintNote = false
    
    var onTitleChanged: ((String) -> Void)?
    var onNoteChanged: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        infoButton.isHidden = true
        
        [titleTextView, noteTextView].forEach {
            $0?.delegate = self
            $0?.isScrollEnabled = false
            $0?.textContainerInset = .zero
            $0?.textContainer.lineFragmentPadding = 0
        }
        titleTextView.font = .systemFont(ofSize: 17)
        titleTextView.textColor = .neutral1
        noteTextView.font = .systemFont(ofSize: 15)
        noteTextView.textColor = .neutral2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        infoButton.isHidden = true
        isHintTitle = false
        isHintNote = false
    }
    
    func configure(title: String?, note: String?, useHints: Bool) {
        if let t = title, !t.isEmpty {
            titleTextView.text = t
            isHintTitle = false
        } else if useHints {
            titleTextView.text = hintTitle
            isHintTitle = true
        } else {
            titleTextView.text = ""
            isHintTitle = false
        }
        
        if let n = note, !n.isEmpty {
            noteTextView.text = n
            isHintNote = false
        } else if useHints {
            noteTextView.text = hintNote
            isHintNote = true
        } else {
            noteTextView.text = ""
            isHintNote = false
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        infoButton.isHidden = false
        if textView === titleTextView, isHintTitle {
            isHintTitle = false
            titleTextView.text = ""
        } else if textView === noteTextView, isHintNote {
            isHintNote = false
            noteTextView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView === titleTextView, textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = hintTitle
            isHintTitle = true
            onTitleChanged?("")
        } else if textView === noteTextView, textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = hintNote
            isHintNote = true
            onNoteChanged?("")
        }
        if !titleTextView.isFirstResponder && !noteTextView.isFirstResponder { infoButton.isHidden = true }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView === titleTextView, !isHintTitle { onTitleChanged?(textView.text) }
        if textView === noteTextView, !isHintNote { onNoteChanged?(textView.text) }
        
        let tv = textView
        let size = CGSize(width: tv.bounds.width, height: .greatestFiniteMagnitude)
        let h = ceil(tv.sizeThatFits(size).height)
        if abs(h - tv.bounds.height) > 0.5, let table = superview as? UITableView {
            UIView.performWithoutAnimation { table.beginUpdates(); table.endUpdates() }
        }
    }
    
}
