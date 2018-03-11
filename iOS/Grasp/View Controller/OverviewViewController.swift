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
    private var salary: Double {
        get {
            return UserDefaults.standard.double(forKey: "salary")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "salary")
            UserDefaults.standard.synchronize()
            updateSalaryDisplay()
        }
    }
    private func updateSalaryDisplay() {
        let text = String(format: "$ %.2f", salary)
        salaryDisplayLabel?.text = text
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
        pastelView.startAnimation()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pastelView.animationDidStop(.any, finished: false)
    }

    private var textField: UITextField?

    private lazy var alert: UIAlertController = {
        let alert = UIAlertController.init(title: "Update Salary", message: "Input your monthly salary", preferredStyle: .alert)
        let bar = UIToolbar()
        bar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissAlert))
        ]
        bar.translatesAutoresizingMaskIntoConstraints = false
        alert.addTextField { [weak self] in
            guard let `self` = self else { return }
            self.textField = $0
            $0.delegate = self
            $0.keyboardType = .decimalPad
            $0.inputAccessoryView = bar
        }
        return alert
    }()

    @IBAction private func configureSalary() {
        present(alert, animated: true, completion: nil)
    }

    @objc private func dismissAlert() {
        textField?.resignFirstResponder()
        alert.dismiss(animated: true, completion: nil)
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        defer { textField.text = "" }
        guard let text = textField.text
            , let newSalary = Double(text)
            else { return }
        salary = newSalary
    }
}

extension CAAnimation {
    fileprivate static let any = CAAnimation()
}
