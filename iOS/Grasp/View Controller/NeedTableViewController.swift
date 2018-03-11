//
//  NeedTableViewController.swift
//  Grasp
//
//  Created by Apollo Zhu on 3/11/18.
//  Copyright © 2018 Grasp. All rights reserved.
//

import UIKit

class NeedTableViewController: UITableViewController, UITextFieldDelegate {

    private var needs: [Need] = [] {
        didSet {
            saveNeeds()
        }
    }

    private func loadNeeds() {
        guard let data = UserDefaults.standard.data(forKey: "Needs")
            , let newNeeds = try? JSONDecoder().decode([Need].self, from: data)
            else { return }
        needs = newNeeds
        tableView?.reloadData()
    }

    private func saveNeeds() {
        if let data = try? JSONEncoder().encode(needs) {
            UserDefaults.standard.set(data, forKey: "Needs")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadNeeds()
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
        present(alert, animated: true, completion: nil)
    }

    @objc private func dismissAlert() {
        isDismissing = false
        if let name = nameTextField?.text, !name.isEmpty {
            if let amount = costTextField?.text, let cost = Double(amount) {
                let indexPath = IndexPath(row: needs.count, section: 0)
                let need = Need(name: name, cost: cost)
                needs.append(need)
                tableView.insertRows(at: [indexPath], with: .automatic)
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return needs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier",
                                                 for: indexPath)
        let need = needs[indexPath.row]
        cell.textLabel?.text = need.name
        cell.detailTextLabel?.text = String(format: "$ %.2f", need.cost)
        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            // Delete the row from the data source
            needs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            return
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
}
