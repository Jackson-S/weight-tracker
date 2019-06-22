//
//  BodyMassIndexCalculator.swift
//  Weight
//
//  Created by Jackson Sommerich on 15/6/19.
//  Copyright © 2019 Jackson Sommerich. All rights reserved.
//

import Foundation

public enum BodyMassIndexCategory {
    case underweight
    case normal
    case overweight
    case obese
    case unknown
}

public func calculateBodyMassIndex(weight: Measurement<UnitMass>, height: Measurement<UnitLength>) -> Double {
    let weightInKilograms = weight.converted(to: .kilograms).value
    let heightInMeters = height.converted(to: .meters).value
    return weightInKilograms / pow(heightInMeters, 2.0)
}

public func getBodyMassIndexCategory(forBodyMassIndex bmi: Double) -> BodyMassIndexCategory {
    let bodyMassIndexCategories: [Range<Double>: BodyMassIndexCategory] = [
        (-Double.infinity..<18.5): .underweight,
        (18.5..<25): .normal,
        (25..<30): .overweight,
        (30..<Double.infinity): .obese
    ]

    for (range, category) in bodyMassIndexCategories {
        if range.contains(bmi) {
            return category
        }
    }

    return BodyMassIndexCategory.unknown
}
