//
//  StringFormatting.swift
//  Weight
//
//  Created by Jackson Sommerich on 14/6/19.
//  Copyright © 2019 Jackson Sommerich. All rights reserved.
//

import Foundation

internal func getTemporalNounString(previousDate: Date) -> String {
    // Return the localized string for the previous weight time
    if previousDate.isToday() {
        return LocalizedStrings.previousWeightTimeToday
    } else if previousDate.isYesterday() {
        return LocalizedStrings.previousWeightTimeYesterday
    } else {
        let otherTime = LocalizedStrings.previousWeightTimeOther
        // Add in days elapsed.
        return String.localizedStringWithFormat(otherTime, previousDate.daysElapsedToToday())
    }
}

internal func getBmiClassification(bmiClassification: BodyMassIndexCategory) -> String {
    switch bmiClassification {
    case .underweight:
        return String(format: "(%@)", LocalizedStrings.underweightBmi)

    case .normal:
        return String(format: "(%@)", LocalizedStrings.normalBmi)

    case .overweight:
        return String(format: "(%@)", LocalizedStrings.overweightBmi)

    case .obese:
        return String(format: "(%@)", LocalizedStrings.obeseBmi)

    case .unknown:
        return "?"
    }
}
