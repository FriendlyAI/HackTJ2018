//
//  GoalTableViewCell.swift
//  Grasp
//
//  Created by Apollo Zhu on 3/10/18.
//  Copyright © 2018 Grasp. All rights reserved.
//

import UIKit

protocol GoalTableViewCellDelegate: class {
    func payForCell(_ cell: GoalTableViewCell)
}

class GoalTableViewCell: UITableViewCell {
    weak var delegate: GoalTableViewCellDelegate?
    var goal: Goal! = nil {
        didSet {
            guard let newGoal = goal else { return }
            goalLabel.text = newGoal.name
            progressLabel.text = String.init(format: "%.2f/%.2f",
                                             newGoal.current, newGoal.target)
            progressView.setProgress(Float(newGoal.current / newGoal.target),
                                     animated: true)
        }
    }
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBAction func pay() {
        delegate?.payForCell(self)
    }
}
