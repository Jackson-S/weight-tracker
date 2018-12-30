//
//  ResultsViewController.swift
//  Weight
//
//  Created by Jackson Sommerich on 29/10/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import Foundation
import UIKit

class ResultsViewController: UIViewController {
    
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var bmiLabel: UILabel!
    @IBOutlet weak var differenceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var parameters: ResultsParameters?
    
    override func viewDidLoad() {
        if let parameters = self.parameters {
            if let weightKG = parameters.weightKG {
                weightLabel.text = String.localizedStringWithFormat("%.1f KG", weightKG)
            } else {
                weightLabel.text = "---"
            }
            
            if let weight = parameters.weight, let oldWeight = parameters.oldWeight {
                let differenceKG = ((weight - oldWeight) / 100).rounded() / 10
                differenceLabel.text = String.localizedStringWithFormat("%+.1f KG", differenceKG)
            } else {
                differenceLabel.text = "---"
            }
            
            if let bmi = parameters.bmi {
                bmiLabel.text = String.localizedStringWithFormat("%.1f", bmi)
            } else {
                bmiLabel.text = "---"
            }
            
            if let bmiCategory = parameters.bmiCategroy {
                switch bmiCategory {
                    case .Underweight:
                        categoryLabel.text = NSLocalizedString("Underweight", comment: "BMI Category: Underweight")
                    case .Normal:
                        categoryLabel.text = NSLocalizedString("Normal", comment: "BMI Category: Normal")
                    case .Overweight:
                        categoryLabel.text = NSLocalizedString("Overweight", comment: "BMI Category: Overweight")
                    case .Obese:
                        categoryLabel.text = NSLocalizedString("Obese", comment: "BMI Category: Obese")
                }
            } else {
                categoryLabel.text = "---"
            }
        }
    }
}
