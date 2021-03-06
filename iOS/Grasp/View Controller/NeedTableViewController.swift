//
//  NeedTableViewController.swift
//  Grasp
//
//  Created by Apollo Zhu on 3/11/18.
//  Copyright © 2018 Grasp. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class NeedTableViewController: UITableViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.rowHeight = 100
        tableView.tableFooterView = UIView()
        DataManager.shared.loadNeeds()
        navigationItem.rightBarButtonItems = [
            editButtonItem,
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self, action: #selector(add))
        ]
    }

    private var alert: UIAlertController!
    private weak var nameTextField: UITextField?
    private weak var costTextField: UITextField?
    private var isDismissing = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
        updateSummary()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if isDismissing { return }
        if textField == nameTextField && costTextField?.text?.isEmpty == true {
            costTextField?.becomeFirstResponder()
        } else if textField == costTextField && nameTextField?.text?.isEmpty == true {
            nameTextField?.becomeFirstResponder()
        } else {
            dismissAlert()
        }
    }

    @objc private func add() {
        isDismissing = true
        alert = UIAlertController(title: "Add New Necesssity",
                                  message: "What else do you need to pay every month?",
                                  preferredStyle: .alert)
        alert.addTextField {
            $0.delegate = self
            $0.placeholder = "How shall we call it?"
            $0.returnKeyType = .next
            self.nameTextField = $0
        }
        alert.addTextField {
            $0.delegate = self
            $0.placeholder = "How much is it?"
            $0.keyboardType = .decimalPad
            let bar = UIToolbar()
            bar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                target: nil, action: nil),
                UIBarButtonItem(barButtonSystemItem: .done, target: self,
                                action: #selector(self.dismissAlert))
            ]
            bar.translatesAutoresizingMaskIntoConstraints = false
            $0.inputAccessoryView = bar
            self.costTextField = $0
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel)
        { _ in self.dismissNoMatterWhat() })
        alert.addAction(UIAlertAction(title: "Done", style: .default)
        { _ in self.dismissAlert() })
        present(alert, animated: true, completion: nil)
    }

    @objc private func dismissAlert() {
        isDismissing = false
        if let name = nameTextField?.text, !name.isEmpty {
            if let amount = costTextField?.text, let cost = Double(amount) {
                let size = DataManager.shared.needs.count
                let indexPath = IndexPath(row: size, section: 0)
                let need = Need(name: name, cost: cost)
                DataManager.shared.needs.append(need)
                tableView.insertRows(at: [indexPath], with: .automatic)
                if size == 0 { tableView.reloadEmptyDataSet() }
                dismissNoMatterWhat()
            } else {
                costTextField?.becomeFirstResponder()
            }
        } else {
            nameTextField?.becomeFirstResponder()
        }
    }

    private func dismissNoMatterWhat() {
        nameTextField?.delegate = nil
        costTextField?.delegate = nil
        nameTextField?.text = ""
        costTextField?.text = ""
        nameTextField?.resignFirstResponder()
        costTextField?.resignFirstResponder()
        alert?.dismiss(animated: true, completion: nil)
        isDismissing = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        let size = DataManager.shared.needs.count
        tableView.tableHeaderView?.isHidden = size == 0
        return size
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier",
                                                 for: indexPath)
        let need = DataManager.shared.needs[indexPath.row]
        (cell.viewWithTag(2) as? UILabel)?.text = need.name
        (cell.viewWithTag(1) as? UILabel)?.text = String(format: "$ %.2f", need.cost)
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataManager.shared.needs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            if DataManager.shared.needs.count == 0 {
                tableView.reloadEmptyDataSet()
            }
        }
        updateSummary()
    }

    // MARK: - Summary

    @IBOutlet weak var summaryLabel: UILabel! {
        didSet {
            updateSummary()
        }
    }

    private func updateSummary() {
        let needs = DataManager.shared.totalNeeds
        let salary = DataManager.shared.salary
        let diff = salary - needs
        if diff < 0 {
            summaryLabel.text = String(format: "You still need to pay $ %.2f", -diff)
        } else {
            summaryLabel.text = "You can pay all of them!"
        }
    }
}


extension NeedTableViewController: DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return  #imageLiteral(resourceName: "ic_lightbulb_outline_48pt")
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attr: [NSAttributedStringKey: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .title1),
            .foregroundColor: UIColor.lightGray
        ]
        return NSAttributedString(string: "Nothing to pay for every month.", attributes: attr)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        let attr: [NSAttributedStringKey: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.lightGray,
            .paragraphStyle: paragraph
        ]
        return NSAttributedString(string: "Add something that requires monthly payment here.", attributes: attr)
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let attr: [NSAttributedStringKey: Any] = [
            .foregroundColor: #colorLiteral(red: 0.4, green: 0.8, blue: 1, alpha: 1)
        ]
        return NSAttributedString(string: "Sure, let's do it!", attributes: attr)
    }
}

extension NeedTableViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        add()
    }
}
