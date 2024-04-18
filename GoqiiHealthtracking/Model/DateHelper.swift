//
//  DateHelper.swift
//  GoqiiHealthtracking
//
//  Created by Devank on 17/04/24.
//

import Foundation

class DateHelper {
    static func getDateString(day: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: day)
    }

    static func getTimeString(time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}
