//
//  UIHeightPickerDataStore.swift
//  Weight
//
//  Created by Jackson Sommerich on 22/6/19.
//  Copyright © 2019 Jackson Sommerich. All rights reserved.
//

import Foundation
import UIKit

internal class UIHeightPickerImperialDataSource: NSObject, UIHeightPickerDataSource {
    // [Feet(0...10), Inches(0...12)]
    internal let heightUnitValues: [[String]] = [Array(0..<10).map(String.init), Array(0..<12).map(String.init)]
    internal let heightUnits: [UnitLength] = [.feet, .inches]

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return heightUnitValues.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard heightUnitValues.count > component else {
            return 0
        }

        return heightUnitValues[component].count
    }
}
