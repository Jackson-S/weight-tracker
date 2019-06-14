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
}
