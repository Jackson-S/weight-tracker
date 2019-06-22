//
//  SuccessInterfaceController.swift
//  Weight WatchKit Extension
//
//  Created by Jackson Sommerich on 16/10/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import Foundation
import WatchKit

class ResultsInterfaceController: WKInterfaceController {
    @IBOutlet weak var weightLabel: WKInterfaceLabel!
    @IBOutlet weak var differenceLabel: WKInterfaceLabel!
    @IBOutlet weak var bmiLabel: WKInterfaceLabel!
    @IBOutlet weak var bmiCategoryLabel: WKInterfaceLabel!
    @IBOutlet weak var motivationLabel: WKInterfaceLabel!

    private let defaultString = "---"
    private var localData: InterfaceLocalDataStore?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        if let convertedContext = context as? InterfaceLocalDataStore {
            localData = convertedContext
            updateDisplay()
        } else {
            print("Unable to convert context")
        }
    }

    func updateDisplay() {
        // Set all parameters to default in advance.
        weightLabel.setText(defaultString)
        bmiLabel.setText(defaultString)
        bmiCategoryLabel.setText(defaultString)
        differenceLabel.setText(defaultString)

        guard let units = localData?.weightDisplayUnits else {
            NSLog("Could not read units, context possibly corrupt")
            return
        }

        if let unwrappedWeight = localData?.weight {
            let weightConverted = unwrappedWeight.converted(to: units)
            let weightLabelText = String(format: LocalizedStrings.weightLabel, weightConverted.value, weightConverted.unit.symbol)
            weightLabel.setText(weightLabelText)
        }

        if let bodyMassIndexUnwrapped = localData?.bodyMassIndex {
            let bodyMassIndexLabelText = String(format: "%.1f", bodyMassIndexUnwrapped)
            bmiLabel.setText(bodyMassIndexLabelText)
        }

        if let bodyMassIndexCategoryUnwrapped = localData?.bodyMassIndexCategory {
            switch bodyMassIndexCategoryUnwrapped {
            case .underweight:
                bmiCategoryLabel.setText(LocalizedStrings.underweightBmi)
            case .normal:
                bmiCategoryLabel.setText(LocalizedStrings.normalBmi)
            case .overweight:
                bmiCategoryLabel.setText(LocalizedStrings.overweightBmi)
            case .obese:
                bmiCategoryLabel.setText(LocalizedStrings.obeseBmi)
            case .unknown:
                bmiCategoryLabel.setText("?")
            }
        }

        if let currentWeightUnwrapped = localData?.weight, let lastWeightUnwrapped = localData?.lastRecordedWeight {
            let weightDifference = currentWeightUnwrapped - lastWeightUnwrapped
            let weightDifferenceConverted = weightDifference.converted(to: units)
            let weightDifferenceText = String(format: LocalizedStrings.weightDifference, weightDifferenceConverted.value, weightDifferenceConverted.unit.symbol)
            differenceLabel.setText(weightDifferenceText)
        }
    }
}
