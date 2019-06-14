//
//  SuccessInterfaceController.swift
//  Weight WatchKit Extension
//
//  Created by Jackson Sommerich on 16/10/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import Foundation
import WatchKit

class SuccessInterfaceController: WKInterfaceController {
    @IBOutlet weak var weightLabel: WKInterfaceLabel!
    @IBOutlet weak var differenceLabel: WKInterfaceLabel!
    @IBOutlet weak var bmiLabel: WKInterfaceLabel!
    @IBOutlet weak var bmiCategoryLabel: WKInterfaceLabel!
    @IBOutlet weak var motivationLabel: WKInterfaceLabel!
    
    let defaultString = "---"
    var resultParameters: ResultsParameters?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let parameters = context as? ResultsParameters {
            self.resultParameters = parameters
            updateDisplay(parameters)
        } else {
            print("Error recieving parameters")
        }
    }
    
    func updateDisplay(_ resultParameters: ResultsParameters) {
        // Set all parameters to default in advance.
        weightLabel.setText(defaultString)
        bmiLabel.setText(defaultString)
        bmiCategoryLabel.setText(defaultString)
        differenceLabel.setText(defaultString)

        if let weightKG = resultParameters.weightKG {
            let weightLabelText = String.localizedStringWithFormat(LocalizedStrings.weightLabel, weightKG)
            weightLabel.setText(weightLabelText)
        }

        if let bmi = resultParameters.bmi {
            let bmiLabelText = String(format: "%.1f", bmi)
            bmiLabel.setText(bmiLabelText)
        }

        if let bmiCategory = resultParameters.bmiCategroy {
            switch bmiCategory {
                case .Underweight:
                    bmiCategoryLabel.setText(LocalizedStrings.underweightBmi)
                case .Normal:
                    bmiCategoryLabel.setText(LocalizedStrings.normalBmi)
                case .Overweight:
                    bmiCategoryLabel.setText(LocalizedStrings.overweightBmi)
                case .Obese:
                    bmiCategoryLabel.setText(LocalizedStrings.obeseBmi)
            }
        }

        if let weight = resultParameters.weight, let oldWeight = resultParameters.oldWeight {
            let difference = ((weight - oldWeight) / 100).rounded() / 10
            let differenceLabelText = String.localizedStringWithFormat(LocalizedStrings.weightDifference, difference)
            differenceLabel.setText(differenceLabelText)
        }
    }
}
