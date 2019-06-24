//
//  Measurement.swift
//  Weight
//
//  Created by Jackson Sommerich on 24/6/19.
//  Copyright © 2019 Jackson Sommerich. All rights reserved.
//

import Foundation
import simd

extension Measurement {
    public func clamped(_ min: Measurement, _ max: Measurement) -> Measurement? {
        guard min.unit == max.unit && min.value <= max.value else {
            return nil
        }

        return Measurement(value: simd_clamp(self.value, min.value, max.value), unit: self.unit)
    }

    public func clamped(_ min: Double, _ max: Double) -> Measurement? {
        guard min <= max else {
            return nil
        }

        return Measurement(value: simd_clamp(self.value, min, max), unit: self.unit)
    }
}
