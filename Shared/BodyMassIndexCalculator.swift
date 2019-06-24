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

public func calculateBodyMassIndex(weight: Measurement<UnitMass>, height: Measurement<UnitLength>) -> Double? {
    let weightInKilograms = weight.converted(to: .kilograms).value
    let heightInMeters = height.converted(to: .meters).value

    guard heightInMeters > 0 && weightInKilograms >= 0 else {
        return nil
    }

    return weightInKilograms / pow(heightInMeters, 2.0)
}

public func getBodyMassIndexCategory(forBodyMassIndex bodyMassIndex: Double?) -> BodyMassIndexCategory? {
    guard let bodyMassIndexUnwrapped = bodyMassIndex else {
        return nil
    }

    switch bodyMassIndexUnwrapped {
    case 0..<18.5:
        return .underweight
    case 18.5..<25:
        return .normal
    case 25..<30:
        return .overweight
    case 30..<Double.infinity:
        return .obese
    default:
        return nil
    }
}
