//
//  HealthKitLogic.swift
//  Weight
//
//  Created by Jackson Sommerich on 18/11/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitAdapter {
    enum HealthKitError: Error {
        case healthKitNotSupported
        case sampleTypeNotSupported
    }

    struct HealthKitResult {
        var startDate: Date
        var endDate: Date
        var value: Double
    }

    private enum HealthKitDataType {
        case height
        case weight
        case bmi
    }

    private let dataTypes: Set<HKSampleType> = Set(
        [HKObjectType.quantityType(forIdentifier: .bodyMass), HKObjectType.quantityType(forIdentifier: .bodyMassIndex), HKObjectType.quantityType(forIdentifier: .height)].compactMap { $0 }
    )

    private var healthStore: HKHealthStore

    init() throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.healthKitNotSupported
        }

        healthStore = HKHealthStore()

        healthStore.requestAuthorization(toShare: dataTypes, read: dataTypes) { success, error in
            if success {
                for type in self.dataTypes {
                    // Check through each supported type and see if we have access.
                    if self.healthStore.authorizationStatus(for: type) != .sharingAuthorized {
                        print("Access not authorised for \(type) (Reason: \(self.healthStore.authorizationStatus(for: type))")
                    }
                }
            } else {
                NSLog("Error occurred accessing health kit (Reason: \(error.debugDescription))")
            }
        }
    }

    func addWeightMeasurement(weight: Double, time: Date = Date(timeIntervalSinceNow: 0)) {
        guard let sampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            // Fail silently if phone does not support quantity type for whatever reason
            return
        }

        let weightQuantity = HKQuantity(unit: HKUnit.gram(), doubleValue: weight)
        let healthKitSample = HKQuantitySample(type: sampleType, quantity: weightQuantity, start: time, end: time)

        addMeasurement(sample: healthKitSample)
    }

    func addBmiMeasurement(bmi: Double, time: Date = Date(timeIntervalSinceNow: 0)) {
        guard let sampleType = HKSampleType.quantityType(forIdentifier: .bodyMassIndex) else {
            // Fail silently if phone does not support quantity type for whatever reason
            return
        }

        let bmiQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: bmi)
        let healthKitSample = HKQuantitySample(type: sampleType, quantity: bmiQuantity, start: time, end: time)

        addMeasurement(sample: healthKitSample)
    }

    func addHeightMeasurement(height: Double, time: Date = Date(timeIntervalSinceNow: 0)) {
        guard let sampleType = HKSampleType.quantityType(forIdentifier: .height) else {
            // Fail silently if phone does not support quantity type for whatever reason
            return
        }

        let heightQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: height)
        let healthKitSample = HKQuantitySample(type: sampleType, quantity: heightQuantity, start: time, end: time)
        addMeasurement(sample: healthKitSample)
    }

    func getHeightMeasurements(occurrences: Int = 1, completion: @escaping ([HealthKitResult]) -> Void) {
        guard let heightSampleType = HKSampleType.quantityType(forIdentifier: .height) else {
            return
        }
        getMeasurements(occurrences: occurrences, sampleType: heightSampleType, completion: completion)
    }

    func getWeightMeasurements(occurrences: Int = 1, completion: @escaping ([HealthKitResult]) -> Void) {
        guard let weightSampleType = HKSampleType.quantityType(forIdentifier: .bodyMass) else {
            return
        }
        getMeasurements(occurrences: occurrences, sampleType: weightSampleType, completion: completion)
    }

    func getBmiMeasurements(occurrences: Int = 1, completion: @escaping ([HealthKitResult]) -> Void) {
        guard let bmiSampleType = HKSampleType.quantityType(forIdentifier: .bodyMassIndex) else {
            return
        }
        getMeasurements(occurrences: occurrences, sampleType: bmiSampleType, completion: completion)
    }

    private func getMeasurements(occurrences: Int = 1, sampleType: HKSampleType, completion: @escaping ([HealthKitResult]) -> Void) {
        // Create the parameters for a HKSampleQuery
        let startDate = healthStore.earliestPermittedSampleDate()
        let endDate = Date(timeIntervalSinceNow: 0)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let sortDescriptor = NSSortDescriptor(key: "endDate", ascending: false)

        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            // If the results are nil then silently quit
            guard let samples = results as? [HKQuantitySample] else {
                NSLog("Error occurred retrieving data from HealthKit (Sample Type: \(sampleType.description)) (Reason: \(error.debugDescription))")
                return
            }

            guard samples.count >= occurrences else {
                NSLog("Error occurred retrieving data from HealthKit (Sample Type: \(sampleType.description)) (Reason: result count is \(samples.count), requesting \(occurrences))")
                return
            }

            let sampleSubrange = samples[samples.count - occurrences..<samples.count]
            var completionData: [HealthKitResult] = []

            for sample in sampleSubrange {
                var unit: HKUnit = .count()
                if sample.quantity.is(compatibleWith: .gram()) {
                    unit = .gram()
                } else if sample.quantity.is(compatibleWith: .meter()) {
                    unit = .meter()
                }
                completionData.append(HealthKitResult(startDate: sample.startDate, endDate: sample.endDate, value: sample.quantity.doubleValue(for: unit)))
            }

            completion(completionData)
        }

        self.healthStore.execute(query)
    }

    private func addMeasurement(sample: HKQuantitySample) {
        healthStore.save(sample) { success, error in
            if !success {
                // Non-crashing failure.
                NSLog("Error occurred saving measurement (Reason: \(error.debugDescription))")
            }
        }
    }
}
