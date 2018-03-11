//
//  GoalTableViewController.swift
//  Grasp
//
//  Created by Apollo Zhu on 3/10/18.
//  Copyright © 2018 Grasp. All rights reserved.
//

import UIKit

class GoalTableViewController: UITableViewController, UITextFieldDelegate, GoalTableViewCellDelegate {

    private var goals: [Goal] = [] {
        didSet {
            saveGoals()
        }
    }

    private func loadGoals() {
        guard let data = UserDefaults.standard.data(forKey: "Goals")
            , let newGoals = try? JSONDecoder().decode([Goal].self, from: data)
            else { return }
        goals = newGoals
        tableView?.reloadData()
    }

    private func saveGoals() {
        if let data = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(data, forKey: "Goals")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadGoals()
        navigationItem.rightBarButtonItems = [
            editButtonItem,
            UIBarButtonItem(barButtonSystemItem: .add,
                            target: self, action: #selector(add))
        ]
    }

    private weak var goalTextField: UITextField?
    private weak var costTextField: UITextField?

    private lazy var alert: UIAlertController = {
        let alert = UIAlertController(title: "Add New Goal",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = "Name of this goal?"
            $0.returnKeyType = .next
            self.goalTextField = $0
        }
        alert.addTextField {
            $0.placeholder = "What's the cost?"
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
        return alert
    }()

    @objc private func add() {
        isDismissing = true
        goalTextField?.delegate = self
        costTextField?.delegate = self
        present(alert, animated: true, completion: nil)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if isDismissing { return }
        if textField == payTextField {
            if let text = textField.text,
                let payment = Double(text),
                let indexPath = payIndexPath {
                let goal = goals[indexPath.row]
                let newGoal = Goal(name: goal.name,
                                  current: goal.current + payment,
                                  target: goal.target)
                if newGoal.current > newGoal.target {
                    goals.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                } else {
                    (tableView.cellForRow(at: indexPath)
                        as? GoalTableViewCell)?.goal = newGoal
                    goals[indexPath.row] = newGoal
                }
                dismissNoMatterWhat()
            } else {
                textField.text = ""
                textField.becomeFirstResponder()
            }
        } else if textField == goalTextField && costTextField?.text?.isEmpty == true {
            costTextField?.becomeFirstResponder()
        } else if textField == costTextField && goalTextField?.text?.isEmpty == true {
            goalTextField?.becomeFirstResponder()
        } else {
            dismissAlert()
        }
    }

    private var isDismissing = false

    private func dismissNoMatterWhat() {
        goalTextField?.delegate = nil
        costTextField?.delegate = nil
        payTextField?.delegate = nil

        goalTextField?.resignFirstResponder()
        costTextField?.resignFirstResponder()
        payTextField?.resignFirstResponder()

        goalTextField?.text = ""
        costTextField?.text = ""
        payTextField?.text = ""

        alert.dismiss(animated: true, completion: nil)
        payAlert?.dismiss(animated: true, completion: nil)
        isDismissing = false
    }

    @objc private func dismissAlert() {
        isDismissing = false
        if let goalName = goalTextField?.text, !goalName.isEmpty {
            if let amount = costTextField?.text, let cost = Double(amount) {
                let indexPath = IndexPath(row: goals.count, section: 0)
                let newGoal = Goal(name: goalName, current: 0, target: cost)
                goals.append(newGoal)
                tableView.insertRows(at: [indexPath], with: .automatic)
                dismissNoMatterWhat()
            } else {
                costTextField?.text = ""
                costTextField?.becomeFirstResponder()
            }
        } else {
            goalTextField?.becomeFirstResponder()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalTableViewCell",
                                                 for: indexPath)

        if let goalCell = cell as? GoalTableViewCell {
            goalCell.goal = goals[indexPath.row]
            goalCell.delegate = self
        }

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            goals.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .insert, .none:
            return
        }
    }

    private var payAlert: UIAlertController?
    private weak var payTextField: UITextField?
    private var payIndexPath: IndexPath?

    @objc private func dismissPaymentAlert() {
        isDismissing = false
        payTextField?.resignFirstResponder()
    }

    func payForCell(_ cell: GoalTableViewCell) {
        isDismissing = true
        payIndexPath = tableView.indexPath(for: cell)
        let row = payIndexPath!.row
        let goal = goals[row]
        payAlert = UIAlertController(title: "Pay for \(goal.name)", message: "You have already paid \(goal.current) out of \(goal.target)", preferredStyle: .alert)
        payAlert?.addTextField {
            $0.keyboardType = .decimalPad
            $0.placeholder = "How much are you paying now?"
            $0.delegate = self
            let bar = UIToolbar()
            bar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                target: nil, action: nil),
                UIBarButtonItem(barButtonSystemItem: .done, target: self,
                                action: #selector(self.dismissPaymentAlert))
            ]
            bar.translatesAutoresizingMaskIntoConstraints = false
            $0.inputAccessoryView = bar
            self.payTextField = $0
        }
        payAlert?.addAction(UIAlertAction(title: "Cancel", style: .cancel)
        { _ in self.dismissNoMatterWhat() })
        present(payAlert!, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
