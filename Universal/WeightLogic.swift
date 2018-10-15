//
//  WeightLogic.swift
//  Weight WatchKit Extension
//
//  Created by Jackson Sommerich on 15/10/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import Foundation
import HealthKit

class WeightLogic {
    private var weight: Double
    private var bmi: Double
    let totalSteps = 2
    var completedSteps = 0
    var completedLoad: Bool

    private var healthStore: HKHealthStore?
    private let healthDataTypes = Set([HKObjectType.quantityType(forIdentifier: .bodyMass)!,
                                       HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
                                       HKObjectType.quantityType(forIdentifier: .height)!])
    private var authorizationStatus: [HKAuthorizationStatus] = []
    
    init() {
        completedLoad = false
        weight = 70000
        bmi = (70000 / 1000) / (height * height)
        
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
            for type in healthDataTypes {
                authorizationStatus.append(healthStore!.authorizationStatus(for: type))
            }
            
            if authorizationStatus.contains(.notDetermined) {
                authorizationHandler(for: healthDataTypes)
            }
            
            getRecentWeight()
            getRecentHeight()
            bmi = getBMI()
        } else {
            healthStore = nil
            print("Device does not support HealthKit")
        }
        
        bmi = getBMI()
    }
    
    func getBMI() -> Double {
        return (weight.rounded() / 1000) / (height * height)
    }
    
    func getBMIClassification() -> String {
        switch bmi {
        case 0..<18.5:
            return "Underweight"
        case 18.5..<25:
            return "Normal Weight"
        case 25..<30:
            return "Overweight"
        default:
            return "Obese"
        }
    }
    
    func getRecentWeight() {
        let startDate = healthStore!.earliestPermittedSampleDate()
        let endDate = Date(timeIntervalSinceNow: 0)
        let sampleType = HKSampleType.quantityType(forIdentifier: .bodyMass)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: []) {
            (query, results, error) in
            
            guard let samples = results as? [HKQuantitySample] else {
                fatalError("\(String(describing: error?.localizedDescription))");
            }
            
            if !samples.isEmpty {
                let sample = samples.first!
                let weight = sample.quantity.doubleValue(for: HKUnit.gram())
                self.weight = weight
                self.completedSteps += 1
                if (self.completedSteps == self.totalSteps) {
                    self.completedLoad = true
                    self.bmi = self.getBMI()
                }
            } else {
                fatalError("Error: No weight values found!")
            }
        }
        
        healthStore?.execute(query)
    }
    
    func getRecentHeight() {
        let startDate = healthStore!.earliestPermittedSampleDate()
        let endDate = Date(timeIntervalSinceNow: 0)
        let sampleType = HKSampleType.quantityType(forIdentifier: .height)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: []) {
            (query, results, error) in
            
            guard let samples = results as? [HKQuantitySample] else {
                fatalError("\(String(describing: error?.localizedDescription))");
            }
            
            if !samples.isEmpty {
                let sample = samples.first!
                let sampleHeight = sample.quantity.doubleValue(for: HKUnit.meter())
                height = sampleHeight
                self.completedSteps += 1
                if (self.completedSteps == self.totalSteps) {
                    self.completedLoad = true
                    self.bmi = self.getBMI()
                }
            } else {
                print("Error: No height values found! Assuming the height of the developer.")
                height = 1.72
                self.completedSteps += 1
                if (self.completedSteps == self.totalSteps) {
                    self.completedLoad = true
                    self.bmi = self.getBMI()
                }
            }
        }
        
        healthStore?.execute(query)
    }
    
    func authorizationHandler(for types: Set<HKSampleType>) {
        healthStore!.requestAuthorization(toShare: types, read: types) { (success, error) in
            if success {
                // Recheck the auth statuses
                self.authorizationStatus = []
                for type in self.healthDataTypes {
                    self.authorizationStatus.append(self.healthStore!.authorizationStatus(for: type))
                }
            } else {
                print("Error requesting authorization for data access!")
            }
        }
    }
    
    func addNewWeightSample() {
        guard let healthStore = healthStore else { return }
        let quantityType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        let weightRounded = weight.rounded()
        let quantity = HKQuantity(unit: HKUnit.gram(), doubleValue: weightRounded)
        let date = Date(timeIntervalSinceNow: 0)
        let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: date, end: date)
        healthStore.save(sample) { (success, error) in
            if !success {
                print("Error handling save request!")
            }
        }
    }
    
    func addNewBMISample() {
        guard let healthStore = healthStore else { return }
        let quantityType = HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!
        // BMI = weight in KG / height^2
        let quantity = HKQuantity(unit: HKUnit.count(), doubleValue: bmi)
        let date = Date(timeIntervalSinceNow: 0)
        let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: date, end: date)
        healthStore.save(sample) { (success, error) in
            if !success {
                print("Error handling save request!")
            }
        }
    }
    
    func incrementBy(_ value: Double) {
        if weight + value > 0 && weight + value < 999000 {
            weight += value
        } else if weight + value < 0 {
            weight = 1
        } else {
            weight = 999000
        }
        bmi = getBMI()
    }
    
    func setWeight(_ value: Double) {
        if  value > 0 && value < 999000 {
            weight = value
        } else if  value < 0 {
            weight = 1
        } else {
            weight = 999000
        }
        bmi = getBMI()
    }
    
    func getWeight() -> Double{
        return weight
    }    
}
