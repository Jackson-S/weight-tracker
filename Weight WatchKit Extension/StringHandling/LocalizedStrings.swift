//
//  LocalizedStrings.swift
//  Weight WatchKit Extension
//
//  Created by Jackson Sommerich on 14/6/19.
//  Copyright © 2019 Jackson Sommerich. All rights reserved.
//

import Foundation

struct LocalizedStrings {
    // Time differences for previous weight saving date
    static let previousWeightTimeToday = NSLocalizedString("Today at %@", comment: "Last weight date text for current day")
    static let previousWeightTimeYesterday = NSLocalizedString("Yesterday at %@", comment: "Last weight date text for yesterday")
    static let previousWeightTimeOther = NSLocalizedString("%i days ago at %@", comment: "Last weight date text for >2 days ago")
    
    // BMI categories
    static let underweightBmi = NSLocalizedString("Underweight", comment: "BMI Category: Underweight")
    static let normalBmi = NSLocalizedString("Normal", comment: "BMI Category: Normal")
    static let overweightBmi = NSLocalizedString("Overweight", comment: "BMI Category: Overweight")
    static let obeseBmi = NSLocalizedString("Obese", comment: "BMI Category: Obese")
    
    // Weight unit names
    static let longFormKg = NSLocalizedString("Kilograms", comment: "KG long form unit text")
    static let shortFormKg = NSLocalizedString("KG", comment: "KG short form unit text")
    static let longFormLbs = NSLocalizedString("Pounds", comment: "Pounds long form unit text")
    static let shortFormLbs = NSLocalizedString("lbs", comment: "Pounds short form unit text")
    static let previousWeightLabel = NSLocalizedString("%@ %@ %@", comment: "(PreviousWeight) (Unit) (last date)")
    
    // Result format strings
    static let weightLabel = NSLocalizedString("%.1f KG", comment: "Weight result display")
    static let weightDifference = NSLocalizedString("%+.1f KG", comment: "Weight difference text")
}
