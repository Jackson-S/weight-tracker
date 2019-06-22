//
//  SuccessParameters.swift
//  Weight
//
//  Created by Jackson Sommerich on 18/11/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import Foundation
import HealthKit

public struct InterfaceLocalDataStore {
    var dataManager: DataManager?
    var weight: Measurement<UnitMass>?
    var height: Measurement<UnitLength>?
    var lastRecordedWeight: Measurement<UnitMass>?
    var lastRecordedWeightDate: Date?
    var bodyMassIndex: Double?
    var bodyMassIndexCategory: BodyMassIndexCategory?
    var weightDisplayUnits: UnitMass
    var heightDisplayUnits: UnitLength
    var completionFunction: (() -> Void)?
}
