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
    private var weight: Double?
    private var bmi: Double?
    var lastWeight: Double?
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
        lastWeight = 70000
        
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
    
    func getBMI() -> Double? {
        if let weightUnwrapped = weight {
            let weightRounded = (weightUnwrapped / 100).rounded() / 10
            if height == 0 {
                return nil
            } else {
                return weightRounded / pow(height, 2)
            }
        } else {
            return nil
        }
    }
    
    func getBMIClassification() -> String {
        if let bmiUnwrapped = bmi {
            switch bmiUnwrapped {
            case 0..<18.5:
                return "Underweight"
            case 18.5..<25:
                return "Normal Weight"
            case 25..<30:
                return "Overweight"
            case 30...Double.infinity:
                return "Obese"
            default:
                return "How?"
            }
        } else {
            return "Invalid BMI."
        }
    }
    
    private func addCompletedStep() {
        self.completedSteps += 1
        
        if (self.completedSteps == self.totalSteps) {
            self.completedLoad = true
            self.bmi = self.getBMI()
        }
    }
    
    private func setDefaultWeight(reason: String) {
        self.weight = 75000
        self.lastWeight = self.weight!
        
        addCompletedStep()
        
        print("\(reason) Setting weight to 75 KG.")
    }
    
    private func getRecentWeight() {
        let startDate = healthStore!.earliestPermittedSampleDate()
        let endDate = Date(timeIntervalSinceNow: 0)
        let sampleType = HKSampleType.quantityType(forIdentifier: .bodyMass)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let sortDescriptor = NSSortDescriptor(key: "endDate", ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) {
            (query, results, error) in
            
            guard let samples = results as? [HKQuantitySample] else {
                self.setDefaultWeight(reason: error?.localizedDescription ?? "Unknown error.")
                return
            }
            
            if !samples.isEmpty {
                let sample = samples.first!
                let weight = sample.quantity.doubleValue(for: HKUnit.gram())
                self.weight = weight
                self.lastWeight = weight
                self.addCompletedStep()
            } else {
                self.setDefaultWeight(reason: "No previous weight found.")
            }
        }
        
        healthStore?.execute(query)
    }
    
    func setDefaultHeight(reason: String) {
        height = 1.72
        
        addCompletedStep()
        
        print("\(reason) Setting height to 1.72 M")
    }
    
    private func getRecentHeight() {
        let startDate = healthStore!.earliestPermittedSampleDate()
        let endDate = Date(timeIntervalSinceNow: 0)
        let sampleType = HKSampleType.quantityType(forIdentifier: .height)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        let sortDescriptor = NSSortDescriptor(key: "endDate", ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) {
            (query, results, error) in
            
            guard let samples = results as? [HKQuantitySample] else {
                self.setDefaultHeight(reason: error?.localizedDescription ?? "Unknown error.")
                return
            }
            
            if !samples.isEmpty {
                let sample = samples.first!
                let sampleHeight = sample.quantity.doubleValue(for: HKUnit.meter())
                height = sampleHeight
                self.addCompletedStep()
            } else {
                self.setDefaultHeight(reason: "No previous height found.")
            }
        }
        
        healthStore?.execute(query)
    }
    
    private func authorizationHandler(for types: Set<HKSampleType>) {
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
    
    func addNewWeightSample() -> Bool {
        lastWeight = weight
        
        guard let healthStore = healthStore else { return false }
        
        let quantityType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        let date = Date(timeIntervalSinceNow: 0)
        
        if let weightUnwrapped = weight {
            let weightRounded = (weightUnwrapped / 100).rounded() * 100
            let quantity = HKQuantity(unit: HKUnit.gram(), doubleValue: weightRounded)
            let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: date, end: date)
            healthStore.save(sample) { (success, error) in
                if !success {
                    print("Error handling save request!")
                }
            }
        }
        
        return true
    }
    
    func addNewBMISample() -> Bool {
        guard let healthStore = healthStore else { return false }
        
        let quantityType = HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!
        let date = Date(timeIntervalSinceNow: 0)
        
        if let bmiUnwrapped = bmi {
            let quantity = HKQuantity(unit: HKUnit.count(), doubleValue: bmiUnwrapped)
            let sample = HKQuantitySample(type: quantityType, quantity: quantity, start: date, end: date)
            healthStore.save(sample) { (success, error) in
                if !success {
                    print("Error handling save request!")
                }
            }
        }
        
        return true
    }
    
    func incrementBy(_ value: Double) {
        guard weight != nil else { return }
        
        let newWeight = weight! + value
        
        if  (1..<999000).contains(newWeight) {
            weight! += value
        } else if newWeight < 0 {
            weight = 1
        } else {
            weight = 999000
        }
        
        if let bmiResult = getBMI() {
            bmi = bmiResult
        }
    }
    
    func setWeight(_ value: Double) {
        if  (1..<999000).contains(value) {
            weight = value
        } else if  value < 0 {
            weight = 1
        } else {
            weight = 999000
        }
        bmi = getBMI()
    }
    
    func getWeight() -> Double? {
        return weight
    }
}
