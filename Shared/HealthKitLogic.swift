//
//  HealthKitLogic.swift
//  Weight
//
//  Created by Jackson Sommerich on 18/11/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitLogic {
    private var healthStore: HKHealthStore
    
    private var authorizationStatus = [
        HKObjectType.quantityType(forIdentifier: .bodyMass)!: false,
        HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!: false,
        HKObjectType.quantityType(forIdentifier: .height)!: false
    ]
    
    init() throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit Data Unavailable")
            throw HKError(.errorHealthDataUnavailable)
        }
        
        healthStore = HKHealthStore()
        
        // Request authorisation
        let dataTypes = Set(authorizationStatus.keys)
        
        healthStore.requestAuthorization(toShare: dataTypes, read: dataTypes) {
            (success, error) in
            if success {
                for type in self.authorizationStatus.keys {
                    if self.healthStore.authorizationStatus(for: type) == .sharingAuthorized {
                        self.authorizationStatus[type] = true
                    }
                }
            } else {
                print("Error requesting authorization for data access!")
            }
        }
    }
    
    func addMeasurement(type: HKQuantityType, quantity: Double, date: Date) -> Bool {
        guard authorizationStatus[type]! else {
            return false
        }
        
        var unit: HKUnit? = nil
        switch type {
            case HKObjectType.quantityType(forIdentifier: .bodyMass)!:
                unit = HKUnit.gram()
            case HKObjectType.quantityType(forIdentifier: .bodyMassIndex):
                unit = HKUnit.count()
            case HKObjectType.quantityType(forIdentifier: .height):
                unit = HKUnit.meter()
            default:
                break
        }
        
        if unit != nil {
            let hkQuantity = HKQuantity.init(unit: unit!, doubleValue: quantity)
            
            let sample = HKQuantitySample(type: type, quantity: hkQuantity, start: date, end: date)
            
            healthStore.save(sample) { (_, _) in () }
            
            return true
        }
        
        return false
    }
    
    func getMeasurement(sampleType: HKSampleType, completion: @escaping (HealthKitResult?) -> Void) {
        let startDate = healthStore.earliestPermittedSampleDate()
        let endDate = Date(timeIntervalSinceNow: 0)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let sortDescriptor = NSSortDescriptor(key: "endDate", ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) {
            query, results, error in
            
            guard results != nil else {
                completion(nil)
                return
            }
            
            if let sample = (results as! [HKQuantitySample]).last {
                var completionData = HealthKitResult(startDate: sample.startDate, endDate: sample.endDate, value: 0)

                if sampleType == HKObjectType.quantityType(forIdentifier: .bodyMass)! {
                    completionData.value = sample.quantity.doubleValue(for: .gram())
                } else if sampleType == HKObjectType.quantityType(forIdentifier: .height)! {
                    completionData.value = sample.quantity.doubleValue(for: .meter())
                }
                
                completion(completionData)
            } else {
                print("Error getting value \(sampleType.description)")
                // Return a nil value and completion should fill in default
                completion(nil)
            }
        }
        
        self.healthStore.execute(query)
    }
    
    func getMeasurements(sampleType: HKSampleType, completion: @escaping ([Date: Double?]?) -> Void) {
        let startDate = healthStore.earliestPermittedSampleDate()
        let endDate = Date(timeIntervalSinceNow: 0)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let sortDescriptor = NSSortDescriptor(key: "endDate", ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) {
            query, results, error in
            
            guard results != nil else {
                completion(nil)
                return
            }
            
            var result = [Date: Double?]()
            
            if let samples = results as? [HKQuantitySample] {
                if sampleType == HKObjectType.quantityType(forIdentifier: .bodyMass) {
                    for sample in samples {
                        result[sample.endDate] = sample.quantity.doubleValue(for: .gram())
                    }
                }
            }
            completion(result)
        }
        self.healthStore.execute(query)
    }
}
