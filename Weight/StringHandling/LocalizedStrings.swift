//
//  LocalizedStrings.swift
//  Weight
//
//  Created by Jackson Sommerich on 14/6/19.
//  Copyright © 2019 Jackson Sommerich. All rights reserved.
//

import Foundation

enum LocalizedStrings {
    // Labels
    static let weightLabel = NSLocalizedString("%.1f %@", comment: "Weight label display text")
    static let bmiLabel = NSLocalizedString("BMI: %.1f", comment: "BMI label display text")
    static let previousWeight = NSLocalizedString("Previous: %.1f %@", comment: "Previous weight label display text")
    static let previousWeightTimeToday = NSLocalizedString("Today at %@", comment: "Last weight date text for current day")
    static let previousWeightTimeYesterday = NSLocalizedString("Yesterday at %@", comment: "Last weight date text for yesterday")
    static let previousWeightTimeOther = NSLocalizedString("%i days ago at %@", comment: "Last weight date text for >2 days ago")

    // BMI Values
    static let underweightBmi = NSLocalizedString("Underweight", comment: "BMI Category: Underweight")
    static let normalBmi = NSLocalizedString("Normal", comment: "BMI Category: Normal")
    static let overweightBmi = NSLocalizedString("Overweight", comment: "BMI Category: Overweight")
    static let obeseBmi = NSLocalizedString("Obese", comment: "BMI Category: Obese")
}
