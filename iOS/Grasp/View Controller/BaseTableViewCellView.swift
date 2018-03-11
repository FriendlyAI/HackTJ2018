//
//  BaseTableViewCellView.swift
//  Grasp
//
//  Created by Apollo Zhu on 3/11/18.
//  Copyright © 2018 Grasp. All rights reserved.
//

import UIKit

class BaseTableViewCellView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    func setup() {
        layer.masksToBounds = false
        layer.cornerRadius = 14
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 5)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.2
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: 14, height: 14)).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
