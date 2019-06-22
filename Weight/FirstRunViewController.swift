//
//  FirstRunViewController.swift
//  Weight
//
//  Created by Jackson Sommerich on 22/6/19.
//  Copyright © 2019 Jackson Sommerich. All rights reserved.
//

import UIKit

class FirstRunViewController: UIViewController, SegueTransitionable, UIPickerViewDelegate {
    private let confirmationFeedbackGenerator = UINotificationFeedbackGenerator()
    private var pickerDataSource: UIHeightPickerDataSource?

    internal var context: InterfaceLocalDataStore?

    @IBOutlet private var heightPicker: UIPickerView!
    @IBOutlet private var confirmButton: UIButton!
    @IBOutlet private var cancelButton: UIButton!
    @IBOutlet private var largeUnitLabel: UILabel!
    @IBOutlet private var smallUnitLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        heightPicker.setValue(UIColor.white, forKey: "textColor")

        if NSLocale.current.usesMetricSystem {
            pickerDataSource = UIHeightPickerMetricDataSource()
            largeUnitLabel.text = UnitLength.meters.symbol
            smallUnitLabel.text = UnitLength.centimeters.symbol
        } else {
            pickerDataSource = UIHeightPickerImperialDataSource()
            largeUnitLabel.text = UnitLength.feet.symbol
            smallUnitLabel.text = UnitLength.inches.symbol
        }

        // Set up the height picker with a delegate and data source according to the system locale
        heightPicker.delegate = self
        heightPicker.dataSource = pickerDataSource

        // If a height is already in HealthKit (i.e. this screen is onboarding first time instead of height not found error) then
        // display the height that's been found inside HealthKit on heightPicker
        if let contextHeight = context?.height, let units = pickerDataSource?.heightUnits {
            // Create a new measurement by flooring the large units after converting them and assigning the remainder to the small units
            let convertedLargeUnits = Measurement(value: floor(contextHeight.converted(to: units[0]).value), unit: units[0])
            let convertedSmallUnits = (contextHeight - convertedLargeUnits).converted(to: units[1])
            heightPicker.selectRow(Int(convertedLargeUnits.value), inComponent: 0, animated: false)
            heightPicker.selectRow(Int(convertedSmallUnits.value), inComponent: 1, animated: false)
            cancelButton.isEnabled = true
        }
    }

    @IBAction func cancelButtonPushed(_ sender: Any) {
        dismiss(animated: true, completion: context?.completionFunction)
    }

    @IBAction func confirmButtonPushed(_ sender: Any) {
        if let dataManager = context?.dataManager {
            guard let height = convertSelectionToMeasurement() else {
                NSLog("Could not convert picker selection to height")
                return
            }

            // Record picker's selected value in health kit
            dataManager.addHeightMeasurement(measurement: height)

            confirmationFeedbackGenerator.notificationOccurred(.success)

            dismiss(animated: true, completion: context?.completionFunction)
        } else {
            print("Could not save height value")
        }
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let pickerDataSourceUnwrapped = pickerDataSource else {
            return nil
        }
        // Should never be out of bounds as bounds is reported ahead of time by UIHeightPickerDataSource
        let attributeKeys = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let string = pickerDataSourceUnwrapped.heightUnitValues[component][row]
        let attributedString = NSAttributedString(string: string, attributes: attributeKeys)
        return attributedString
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let selectionMeasurement = convertSelectionToMeasurement() {
            confirmButton.isEnabled = isValid(height: selectionMeasurement)
        } else {
            confirmButton.isEnabled = false
        }
    }

    func isValid(height: Measurement<UnitLength>) -> Bool {
        let minimumHeight = Measurement(value: 30, unit: UnitLength.centimeters)
        return height > minimumHeight
    }

    func convertSelectionToMeasurement() -> Measurement<UnitLength>? {
        // Convert the indices of the picker (corresponding from 0..n) into units and sum them.
        if let units = pickerDataSource?.heightUnits {
            let largeUnitValue = Measurement(value: Double(heightPicker.selectedRow(inComponent: 0)), unit: units[0])
            let smallUnitValue = Measurement(value: Double(heightPicker.selectedRow(inComponent: 1)), unit: units[1])
            let unitValueSum = largeUnitValue + smallUnitValue
            return unitValueSum
        } else {
            return nil
        }
    }
}
