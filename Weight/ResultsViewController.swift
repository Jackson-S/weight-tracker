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
    
    var parameters: SuccessParameters?
    
    override func viewDidLoad() {
        if let parameters = self.parameters {
            let weightKG = parameters.weight / 1000
            let differenceKG = (parameters.weight - parameters.oldWeight) / 1000
            let bmi = parameters.bmi
            
            weightLabel.text = String(format: "%.1f KG", weightKG)
            differenceLabel.text = String(format: "%+.1f KG", differenceKG)
            bmiLabel.text = String(format: "%.1f", bmi)
        }
    }
}
