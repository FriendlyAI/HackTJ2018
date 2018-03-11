//
//  TabBarController.swift
//  Grasp
//
//  Created by Apollo Zhu on 3/10/18.
//  Copyright © 2018 Grasp. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        isTranslucent = true
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        guard motion == .motionShake else { return }
        let alert = UIAlertController(
            title: "Reset?",
            message: "This feature is intended for demonstration version only.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "YES", style: .destructive) { _ in
            DataManager.shared.reset()
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateInitialViewController()!
            self.present(vc, animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "Demo", style: .default) { _ in
            DataManager.shared.setToDemo()
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateInitialViewController()!
            self.present(vc, animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}

extension UITabBarController {
    var isTranslucent: Bool {
        get {
            return tabBar.isTranslucent
        }
        set {
            if newValue {
                tabBar.backgroundImage = UIImage()
                tabBar.shadowImage = UIImage()
                tabBar.isTranslucent = true
            } else {
                tabBar.backgroundColor = nil
                tabBar.shadowImage = nil
                tabBar.isTranslucent = false
            }
        }
    }
}
