//
//  DataManager.swift
//  Grasp
//
//  Created by Apollo Zhu on 3/11/18.
//  Copyright © 2018 Grasp. All rights reserved.
//

import Foundation

final class DataManager {
    public static let shared = DataManager()
    private init() {
        loadNeeds()
        loadGoals()
    }
    let ud = UserDefaults.standard
    var cumulativeRainyDayFund: Double {
        get {
            return ud.double(forKey: "Cumulative Rainy Day")
        }
        set {
            ud.set(newValue, forKey: "Cumulative Rainy Day")
            ud.synchronize()
        }
    }
    var currentRainyDayFund: Double {
        return cumulativeRainyDayFund + monthlyRemaining
    }
    var monthlyRemaining: Double {
        return salary - totalNeeds - totalAllGoalsPaid
    }

    var needs: [Need] = [] {
        didSet {
            saveNeeds()
        }
    }

    func loadNeeds() {
        guard let data = ud.data(forKey: "Needs")
            , let newNeeds = try? JSONDecoder().decode([Need].self, from: data)
            else { return }
        needs = newNeeds
    }

    func saveNeeds() {
        if let data = try? JSONEncoder().encode(needs) {
            ud.set(data, forKey: "Needs")
            ud.synchronize()
        }
    }

    var totalNeeds: Double {
        return needs.reduce(0) { $0 + $1.cost }
    }

    var goals: [Goal] = [] {
        didSet {
            saveGoals()
        }
    }

    func loadGoals() {
        guard let data = ud.data(forKey: "Goals")
            , let newGoals = try? JSONDecoder().decode([Goal].self, from: data)
            else { return }
        goals = newGoals
    }

    func saveGoals() {
        if let data = try? JSONEncoder().encode(goals) {
            ud.set(data, forKey: "Goals")
            ud.synchronize()
        }
    }

    var totalCurrentGoals: Double {
        return goals.reduce(0) { $0 + $1.target }
    }

    var totalCurrentGoalsPaid: Double {
        return goals.reduce(0) { $0 + $1.current }
    }

    var totalCurrentGoalsRemainig: Double {
        return totalCurrentGoals - totalCurrentGoalsPaid
    }
    
    var salary: Double {
        get {
            return ud.double(forKey: "salary")
        }
        set {
            ud.set(newValue, forKey: "salary")
            ud.synchronize()
        }
    }

    var totalAllGoalsPaid: Double {
        get {
            return ud.double(forKey: "paid")
        }
        set {
            ud.set(newValue, forKey: "paid")
            ud.synchronize()
        }
    }

    func startNewCycle() {
        cumulativeRainyDayFund += monthlyRemaining
        totalAllGoalsPaid = 0
        saveGoals()
        saveNeeds()
    }

    func reset() {
        cumulativeRainyDayFund = 0
        needs = []
        saveNeeds()
        goals = []
        saveGoals()
        salary = 0
        totalAllGoalsPaid = 0
        ud.synchronize()
    }

    func setToDemo() {
        cumulativeRainyDayFund = 500
        needs = [
            Need(name: "Rent", cost: 1800),
            Need(name: "Insurance", cost: 200),
            Need(name: "Groceries", cost: 500)
        ]
        saveNeeds()
        goals = [
            Goal(name: "Car", current: 5000, target: 25000),
            Goal(name: "Vacation", current: 0, target: 2000)
        ]
        saveGoals()
        salary = 10000
        totalAllGoalsPaid = 5000
        ud.synchronize()
    }
}
