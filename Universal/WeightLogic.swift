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
    private var healthLogic: HealthKitLogic?
    
    // Height must be positive, otherwise crashes will happen
    public var height: Double? {
        didSet {
            if let heightUnwrap = height {
                if heightUnwrap <= 0 {
                    height = 0.01
                }
            }
        }
    }
    
    // Weight doesn't have to be positive, but it'll look nicer
    private(set) public var weight: Double? {
        didSet {
            if let weightUnwrap = weight {
                if weightUnwrap <= 0 {
                    weight = 1
                }
            }
        }
    }
    
    public var bmi: Double? {
        get {
            // Compute BMI when requested
            if let height = self.height, let weight = self.weight {
                return (weight / 1000) / pow(height, 2)
            } else {
                print("Error setting bmi")
                return nil
            }
        }
    }
    
    public var bmiCategory: String? {
        get {
            let ranges = [(-Double.infinity..<18.5): "Underweight",
                          (18.5..<25): "Normal",
                          (25..<30): "Overweight",
                          (30..<Double.infinity): "Obese"]
            
            
            for (range, string) in ranges {
                if range.contains(bmi ?? 0) {
                    return string
                }
            }
            
            // Should never occur, silences compiler warning
            return nil
        }
    }
    
    private(set) public var lastWeight: Double?
    
    init() {
        do {
            try healthLogic = HealthKitLogic()
        } catch {
            print("Error invoking health logic")
            healthLogic = nil
        }
        
        self.getRecentWeight()
        self.getRecentHeight()
    }
    
    private func getRecentWeight() {
        healthLogic?.getMeasurement(sampleType: HKSampleType.quantityType(forIdentifier: .bodyMass)!) {
            value in
            
            if self.lastWeight == nil {
                self.lastWeight = value ?? 72 * 1000
            } else {
                self.lastWeight = self.weight
            }
            
            self.weight = value ?? 72 * 1000
        }
    }
    
    private func getRecentHeight() {
        healthLogic?.getMeasurement(sampleType: HKSampleType.quantityType(forIdentifier: .height)!) {
            value in
            self.height = value ?? 1.72
        }
    }
    
    func addNewWeightSample() -> Bool {
        lastWeight = weight
        
        let sampleType = HKSampleType.quantityType(forIdentifier: .bodyMass)!
        let sampleDate = Date(timeIntervalSinceNow: 0)
        
        // May cause issues due to concurrency?
        return (healthLogic?.addMeasurement(type: sampleType, quantity: weight!, date: sampleDate))!
    }
    
    func addNewBMISample() -> Bool {
        let sampleType = HKSampleType.quantityType(forIdentifier: .bodyMassIndex)!
        let sampleDate = Date(timeIntervalSinceNow: 0)
        
        return (healthLogic?.addMeasurement(type: sampleType, quantity: bmi!, date: sampleDate))!
    }
    
    func incrementBy(_ value: Double) {
        if weight == nil {
            print("Cannot increment nil weight!")
            return
        }
        
        if let weight = self.weight {
            self.weight! += value
            
            if weight < 1 {
                self.weight! = 1
            }
        }
    }
}
