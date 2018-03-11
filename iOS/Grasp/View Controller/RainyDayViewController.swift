//
//  RainyDayViewController.swift
//  Grasp
//
//  Created by Apollo Zhu on 3/11/18.
//  Copyright © 2018 Grasp. All rights reserved.
//

import UIKit
import FaveButton

class RainyDayViewController: UIViewController {
    @IBOutlet weak var revealButton: FaveButton!
    @IBAction func reveal() {
        DispatchQueue.global().async {
            let value = DataManager.shared.currentRainyDayFund
            let title = String(format: "$ %.2f", value)
            var message = "That's your rainy day fund!"
            if value < 0 {
                message += "\nWhich is not looking good right now!"
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                let alert = UIAlertController(
                    title: title,
                    message: message,
                    preferredStyle: .alert
                )
                let action = UIAlertAction(title: "OK", style: .default) { _ in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(action)
                self.present(alert, animated: true) {
                    self.revealButton.isSelected = false
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        revealButton.isSelected = true
        reveal()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        tabBarController?.isTranslucent = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        extendedLayoutIncludesOpaqueBars = true
        tabBarController?.isTranslucent = true
    }
    override func viewDidAppear(_ animated: Bool) {
        extendedLayoutIncludesOpaqueBars = true
        tabBarController?.isTranslucent = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.isTranslucent = false
    }
}
