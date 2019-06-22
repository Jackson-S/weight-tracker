//
//  WeightLogic.swift
//  Weight WatchKit Extension
//
//  Created by Jackson Sommerich on 15/10/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import Foundation
import HealthKit

class DataManager {
    enum DataManagerError: Error {
        case healthKitUnavailable
        case valueUnavailable
        case unsupportedUnit
        case unknownError
    }

    private struct DataStore {
        var height: HealthKitAdapter.HealthKitResult? // Stored in meters
        var weight: HealthKitAdapter.HealthKitResult? // Stored in grams
    }

    private var healthKitAdapter: HealthKitAdapter?
    private var localDataStore: DataStore

    init() {
        do {
            try healthKitAdapter = HealthKitAdapter()
        } catch HealthKitAdapter.HealthKitError.healthKitNotSupported {
            print("Cannot invoke health kit on this device.")
            healthKitAdapter = nil
        } catch HealthKitAdapter.HealthKitError.sampleTypeNotSupported {
            print("HealthKit does not support required sample types. Maybe this program needs to be updated?")
        } catch {
            print("Unknown error occurred while initializing HealthKit")
        }

        // Instantiate a nil-filled object, will be completed asyncronously by fetchRecentValues()
        localDataStore = DataStore(height: nil, weight: nil)
        refreshValues()
    }

    func refreshValues(callback: (() -> Void)? = nil) {
        // Query for each of the stored data types
        healthKitAdapter?.getHeightMeasurements { result in
            if let unwrappedResult = result.first {
                self.localDataStore.height = unwrappedResult
            }

            if let callbackUnwrapped = callback {
                callbackUnwrapped()
            }
        }

        healthKitAdapter?.getWeightMeasurements { result in
            if let unwrappedResult = result.first {
                self.localDataStore.weight = unwrappedResult
            }

            if let callbackUnwrapped = callback {
                callbackUnwrapped()
            }
        }
    }

    func getMostRecentHeight() throws -> Measurement<UnitLength> {
        guard let height = localDataStore.height?.value else {
            throw DataManagerError.valueUnavailable
        }

        return Measurement(value: height, unit: UnitLength.meters)
    }

    func getMostRecentWeight() throws -> Measurement<UnitMass> {
        guard let weight = localDataStore.weight?.value else {
            throw DataManagerError.valueUnavailable
        }

        return Measurement(value: weight, unit: UnitMass.grams)
    }

    func getMostRecentWeightDate() throws -> Date {
        guard let weightDate = localDataStore.weight?.startDate else {
            throw DataManagerError.valueUnavailable
        }

        return weightDate
    }

    func addWeightMeasurement(measurement: Measurement<UnitMass>, withBmi: Bool = true) throws {
        // Store BMI first so that if a height is unavailable we don't have to rollback.
        if withBmi {
            // Check there is a height value available and throw before any changes have been made.
            guard let height = localDataStore.height?.value else {
                throw DataManagerError.valueUnavailable
            }

            let heightMeasurement = Measurement(value: height, unit: UnitLength.meters)
            let bodyMassIndex = calculateBodyMassIndex(weight: measurement, height: heightMeasurement)
            healthKitAdapter?.addBmiMeasurement(bmi: bodyMassIndex)
        }

        // Convert the measurement to grams and store it in HealthKit
        let measurementInGrams = measurement.converted(to: .grams).value
        healthKitAdapter?.addWeightMeasurement(weight: measurementInGrams)
    }

    func addHeightMeasurement(measurement: Measurement<UnitLength>) {
        let measurementInMeters = measurement.converted(to: .meters).value
        healthKitAdapter?.addHeightMeasurement(height: measurementInMeters)
    }
}
