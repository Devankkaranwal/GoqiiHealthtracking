//
//  HydrationModel.swift
//  GoqiiHealthtracking
//
//  Created by Devank on 17/04/24.
//

import Foundation


struct WaterData {
    var amount: Int
    var drinkID: Int
    var date: Date
}

struct HydrationModel {
    var date: Date
    var goal: Int
    var goalIndex: Int
    var totalIntake: Int
    var progress: Double
    var intake: [WaterData]

    mutating func removeIntake(offset: Int) {
        intake.remove(at: offset)
    }
}
