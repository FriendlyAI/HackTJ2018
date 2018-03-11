//
//  LoginViewController.swift
//  Grasp
//
//  Created by Apollo Zhu on 3/10/18.
//  Copyright © 2018 Grasp. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        BiometricAuthentication.authenticate { state in
            switch state {
            case .success:
                DispatchQueue.main.async { [weak self] in
                    self?.showMainUI()
                }
            case .failure(error: let error):
                print(error ?? "Failed")
            }
        }
    }

    @IBAction func didTapLoginButton() {
        // #warning Check
        showMainUI()
    }

    private func showMainUI() {
        performSegue(withIdentifier: "Show Main UI",
                     sender: loginButton)
    }
}
