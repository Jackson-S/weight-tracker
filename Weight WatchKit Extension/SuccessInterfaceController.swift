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
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let defaultString = "---"
        
        if let parameters = context as? ResultsParameters {
            if let weightKG = parameters.weightKG {
                let weightLabelLocal = NSLocalizedString("%.1f KG", comment: "Weight result display")
                let weightLabelText = String.localizedStringWithFormat(weightLabelLocal, weightKG)
                weightLabel.setText(weightLabelText)
            } else {
                weightLabel.setText(defaultString)
            }
            
            if let bmi = parameters.bmi {
                let bmiLabelText = String.localizedStringWithFormat("%.1f", bmi)
                bmiLabel.setText(bmiLabelText)
            } else {
                bmiLabel.setText(defaultString)
            }
            
            if let bmiCategory = parameters.bmiCategroy {
                switch bmiCategory {
                    case .Underweight:
                        bmiCategoryLabel.setText(NSLocalizedString("Underweight", comment: "BMI Category: Underweight"))
                    case .Normal:
                        bmiCategoryLabel.setText(NSLocalizedString("Normal", comment: "BMI Category: Normal"))
                    case .Overweight:
                        bmiCategoryLabel.setText(NSLocalizedString("Overweight", comment: "BMI Category: Overweight"))
                    case .Obese:
                        bmiCategoryLabel.setText(NSLocalizedString("Obese", comment: "BMI Category: Obese"))
                }
            } else {
                bmiCategoryLabel.setText(defaultString)
            }
            
            if let weight = parameters.weight, let oldWeight = parameters.oldWeight {
                let difference = ((weight - oldWeight) / 100).rounded() / 10
                let differenceLabelLocal = NSLocalizedString("%+.1f KG", comment: "Weight difference text")
                let differenceLabelText = String.localizedStringWithFormat(differenceLabelLocal, difference)
                differenceLabel.setText(differenceLabelText)
            } else {
                differenceLabel.setText(defaultString)
            }
        } else {
            print("Error recieving parameters")
        }
    }
}
