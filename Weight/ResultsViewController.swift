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
    @IBOutlet weak var totalLostLabel: UILabel!
    
    var parameters: ResultsParameters?
    
    override func viewDidLoad() {
        if let parameters = self.parameters {
            if let weightKG = parameters.weightKG {
                weightLabel.text = String(format: "%.1f KG", weightKG)
            } else {
                weightLabel.text = "--- KG"
            }
            
            if let weight = parameters.weight, let oldWeight = parameters.oldWeight {
                let differenceKG = ((weight - oldWeight) / 100).rounded() / 10
                differenceLabel.text = String(format: "%+.1f KG", differenceKG)
            } else {
                differenceLabel.text = "--- KG"
            }
            
            if let bmi = parameters.bmi {
                bmiLabel.text = String(format: "%.1f", bmi)
            } else {
                bmiLabel.text = "---"
            }
            
            if let bmiCategory = parameters.bmiCategroy {
                categoryLabel.text = bmiCategory
            } else {
                categoryLabel.text = "---"
            }
            
            if let totalLoss = parameters.totalLoss {
                let totalDiffereceKG = (totalLoss / 100).rounded() / 10
                totalLostLabel.text = String(format: "%+.1f KG", totalDiffereceKG)
            } else {
                totalLostLabel.text = "--- KG"
            }
        }
    }
}
