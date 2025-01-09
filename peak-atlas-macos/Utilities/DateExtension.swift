//
//  DateExtension.swift
//  peak-atlas-macos
//
//  Created by Christopher Sonny on 21/11/24.
//

import Foundation
import SwiftUI

extension Date {
    func singleUnitRelativeString() -> String {
        let now = Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.second, .minute, .hour, .day, .month, .year], from: self, to: now)
        
        if let years = components.year, years != 0 {
            return "\(abs(years)) \(abs(years) == 1 ? "year" : "years") ago"
        }
        if let months = components.month, months != 0 {
            return "\(abs(months)) \(abs(months) == 1 ? "month" : "months") ago"
        }
        if let days = components.day, days != 0 {
            return "\(abs(days)) \(abs(days) == 1 ? "day" : "days") ago"
        }
        if let hours = components.hour, hours != 0 {
            return "\(abs(hours)) \(abs(hours) == 1 ? "hour" : "hours") ago"
        }
        if let minutes = components.minute, minutes != 0 {
            return "\(abs(minutes)) \(abs(minutes) == 1 ? "minute" : "minutes") ago"
        }
        if let seconds = components.second, seconds != 0 {
            return "\(abs(seconds)) \(abs(seconds) == 1 ? "second" : "seconds") ago"
        }
        
        return "just now"
    }
}
