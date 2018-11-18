//
//  SuccessParameters.swift
//  Weight
//
//  Created by Jackson Sommerich on 18/11/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import Foundation

class SuccessParameters {
    let weight: Double
    let oldWeight: Double
    let bmi: Double
    
    init(weight: Double?, oldWeight: Double?, bmi: Double?) {
        self.weight = weight ?? 0
        self.oldWeight = oldWeight ?? 0
        self.bmi = bmi ?? 0
    }
}
