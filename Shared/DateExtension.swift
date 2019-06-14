//
//  DateExtensions.swift
//  Weight
//
//  Created by Jackson Sommerich on 30/11/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import Foundation

// Adds string formatting to the Date class.
extension Date {
    func string(dateFormat format: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = format
        return dateFormatter.string(from: self)
    }
    
    func string(timeFormat format: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = format
        return dateFormatter.string(from: self)
    }

    private func string(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}


// Adds day comparison to Date class.
extension Date {
    func isSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func isYesterday() -> Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    func daysElapsedToToday() -> Int {
        let elapsedTime = DateInterval(start: self, end: Date(timeIntervalSinceNow: 0)).duration
        return Int(ceil(elapsedTime / 60 / 60 / 24))
    }
}
