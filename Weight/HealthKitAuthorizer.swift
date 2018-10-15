//
//  HealthKitAuthorizer.swift
//  Weight
//
//  Created by Jackson Sommerich on 15/10/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitAuthorizer {
    private var healthStore: HKHealthStore?
    private let healthDataTypes: Set<HKSampleType> = Set([HKObjectType.quantityType(forIdentifier: .bodyMass)!,
                                                          HKObjectType.quantityType(forIdentifier: .bodyMassIndex)!,
                                                          HKObjectType.quantityType(forIdentifier: .height)!])
    private var authorizationStatus: [HKAuthorizationStatus] = []
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        } else {
            healthStore = nil
        }
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
    
    func requestAuth() {
        for type in healthDataTypes {
            authorizationStatus.append(healthStore!.authorizationStatus(for: type))
        }
        
        if authorizationStatus.contains(.notDetermined) {
            authorizationHandler(for: healthDataTypes)
        }
    }
}
