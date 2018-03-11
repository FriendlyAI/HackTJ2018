//
//  OverviewViewController.swift
//  Grasp
//
//  Created by Apollo Zhu on 3/10/18.
//  Copyright © 2018 Grasp. All rights reserved.
//

import UIKit
import Pastel

class OverviewViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var salaryDisplayLabel: UILabel! {
        didSet { updateSalaryDisplay() }
    }
    @IBOutlet weak var remaingDisplayLabel: UILabel! {
        didSet { updateRemainingDisplay() }
    }
    private func updateSalaryDisplay() {
        let text = String(format: "$ %.2f", DataManager.shared.salary)
        salaryDisplayLabel?.text = text
    }
    private func updateRemainingDisplay() {
        let value = DataManager.shared.monthlyRemaining
        let text = String(format: "$ %.2f", value)
        remaingDisplayLabel?.text = text
        remaingDisplayLabel?.textColor =
            value < 0 ? .red : .black
    }
    private var pastelView: PastelView! {
        return view as? PastelView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        pastelView.setColors([#colorLiteral(red: 0.631372549, green: 0.5490196078, blue: 0.8196078431, alpha: 1), #colorLiteral(red: 1, green: 0.9254901961, blue: 0.8235294118, alpha: 1), #colorLiteral(red: 0.9882352941, green: 0.7137254902, blue: 0.6235294118, alpha: 1)])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        extendedLayoutIncludesOpaqueBars = true
        tabBarController?.isTranslucent = true
        pastelView.startAnimation()
        updateRemainingDisplay()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        extendedLayoutIncludesOpaqueBars = true
        tabBarController?.isTranslucent = true
        if DataManager.shared.salary <= 0 {
            changeSalary()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.isTranslucent = false
        pastelView.animationDidStop(.any, finished: false)
    }
    private var alert: UIAlertController!

    @IBAction private func configureSalary() {
        alert = UIAlertController(
            title: "What happend?",
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Got my monthly salary", style: .default) { _ in
            DataManager.shared.startNewCycle()
            self.updateSalaryDisplay()
            self.updateRemainingDisplay()
        })
        alert.addAction(UIAlertAction(title: "Got some money", style: .default) { _ in
            self.addMoney()
        })
        alert.addAction(UIAlertAction(title: "Changed my income", style: .default) { _ in
            self.changeSalary()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    private weak var addMoneyTextField: UITextField?
    private weak var changeSalaryTextField: UITextField?
    private var isDismissing = false

    private func addMoney() {
        isDismissing = true
        alert = UIAlertController(
            title: "Add Money",
            message: "I don't know how you acquired these money, but make sure it's legal!",
            preferredStyle: .alert
        )
        let bar = UIToolbar()
        bar.items = [
            UIBarButtonItem(
                barButtonSystemItem: .flexibleSpace,
                target: nil,
                action: nil
            ),
            UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(self.dismissAlert)
            )
        ]
        bar.translatesAutoresizingMaskIntoConstraints = false
        alert.addTextField {
            $0.delegate = self
            $0.keyboardType = .decimalPad
            $0.inputAccessoryView = bar
            $0.placeholder = "How much did you get?"
            self.addMoneyTextField = $0
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            self.processAddMoneyTextField()
            self.dismissAlert()
        })
        present(alert, animated: true, completion: nil)
    }

    private func changeSalary() {
        isDismissing = true
        alert = UIAlertController(
            title: "Update Salary",
            message: "Input your monthly salary",
            preferredStyle: .alert
        )
        let bar = UIToolbar()
        bar.items = [
            UIBarButtonItem(
                barButtonSystemItem: .flexibleSpace,
                target: nil,
                action: nil
            ),
            UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(self.dismissAlert)
            )
        ]
        bar.translatesAutoresizingMaskIntoConstraints = false
        alert.addTextField {
            $0.delegate = self
            $0.keyboardType = .decimalPad
            $0.inputAccessoryView = bar
            $0.placeholder = "\(DataManager.shared.salary)"
            self.changeSalaryTextField = $0
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default) { _ in
            self.processChangeSalaryTextField()
            self.dismissAlert()
        })
        present(alert, animated: true, completion: nil)
    }

    @objc private func dismissAlert() {
        isDismissing = false
        alert?.dismiss(animated: true, completion: nil)
    }

    func textFieldDidEndEditing(_ textField: UITextField,
                                reason: UITextFieldDidEndEditingReason) {
        if isDismissing { return }
        defer {
            textField.delegate = nil
            textField.text = ""
            isDismissing = false
        }
        if textField == changeSalaryTextField {
            processChangeSalaryTextField()
        } else if textField == addMoneyTextField {
            processAddMoneyTextField()
        }
    }

    private func processChangeSalaryTextField() {
        guard let text = changeSalaryTextField?.text
            , let newSalary = Double(text)
            else { return }
        DataManager.shared.salary = newSalary
        updateSalaryDisplay()
        updateRemainingDisplay()
    }

    private func processAddMoneyTextField() {
        guard let text = addMoneyTextField?.text
            , let value = Double(text)
            else { return }
        DataManager.shared.totalAllGoalsPaid -= value
        updateRemainingDisplay()
    }
}

extension CAAnimation {
    fileprivate static let any = CAAnimation()
}
