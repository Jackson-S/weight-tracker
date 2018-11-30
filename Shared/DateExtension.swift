//
//  DateExtensions.swift
//  Weight
//
//  Created by Jackson Sommerich on 30/11/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import Foundation

extension Date {
    func string(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func isSameDay(as date: Date) -> Bool {
        return self.string(dateFormat: "dd/MM") == date.string(dateFormat: "dd/MM")
    }
}
