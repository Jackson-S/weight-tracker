//
//  UIHeightPickerViewDataSourceMetric.swift
//  Weight
//
//  Created by Jackson Sommerich on 22/6/19.
//  Copyright © 2019 Jackson Sommerich. All rights reserved.
//

import Foundation
import UIKit

internal class UIHeightPickerMetricDataSource: NSObject, UIHeightPickerDataSource {
    // [Meters(0..10), Centimeters(0...99)]
    internal let heightUnitValues: [[String]] = [Array(0..<10).map(String.init), Array(0..<100).map(String.init)]
    internal let heightUnits: [UnitLength] = [.meters, .centimeters]

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return heightUnitValues.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if heightUnitValues.count > component {
            return heightUnitValues[component].count
        } else {
            return 0
        }
    }
}
