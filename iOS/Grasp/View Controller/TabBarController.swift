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
