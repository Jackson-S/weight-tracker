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
                let weightLabelText = String.localizedStringWithFormat(LocalizedStrings.weightLabel, weightKG)
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
                        bmiCategoryLabel.setText(LocalizedStrings.underweightBmi)
                    case .Normal:
                        bmiCategoryLabel.setText(LocalizedStrings.normalBmi)
                    case .Overweight:
                        bmiCategoryLabel.setText(LocalizedStrings.overweightBmi)
                    case .Obese:
                        bmiCategoryLabel.setText(LocalizedStrings.obeseBmi)
                }
            } else {
                bmiCategoryLabel.setText(defaultString)
            }
            
            if let weight = parameters.weight, let oldWeight = parameters.oldWeight {
                let difference = ((weight - oldWeight) / 100).rounded() / 10
                let differenceLabelText = String.localizedStringWithFormat(LocalizedStrings.weightDifference, difference)
                differenceLabel.setText(differenceLabelText)
            } else {
                differenceLabel.setText(defaultString)
            }
        } else {
            print("Error recieving parameters")
        }
    }
}
