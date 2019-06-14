//
//  StringFormatting.swift
//  Weight
//
//  Created by Jackson Sommerich on 14/6/19.
//  Copyright © 2019 Jackson Sommerich. All rights reserved.
//

import Foundation

func getTemporalNounString(previousDate: Date) -> String {
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

func getBmiClassification(bmiClassification: BMICategory) -> String {
    switch bmiClas {
    case .Underweight:
        return String(format: "(%@)", LocalizedStrings.underweightBmi)
    case .Normal:
        return String(format: "(%@)", LocalizedStrings.normalBmi)
    case .Overweight:
        return String(format: "(%@)", LocalizedStrings.overweightBmi)
    case .Obese:
        return String(format: "(%@)", LocalizedStrings.obeseBmi)
    }
}
    
