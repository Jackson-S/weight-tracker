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
    @IBOutlet weak var motivationLabel: WKInterfaceLabel!
    
    func weightLabelText(_ weight: Double?) -> String {
        if let weightUnwrapped = weight {
            return String(format: "%.1f KG", (weightUnwrapped / 100).rounded() / 10)
        } else {
            return "- KG"
        }
    }
    
    func bmiLabelText(_ bmi: Double?) -> String {
        if let bmiUnwrapped = bmi {
            return String(format: "%.1f", bmiUnwrapped)
        } else {
            return "-"
        }
    }
    
    func differenceLabelText(_ oldWeight: Double?, _ newWeight: Double?) -> String {
        guard oldWeight != nil && newWeight != nil else {
            return "- KG"
        }
        
        let difference = ((newWeight! - oldWeight!) / 100).rounded() / 10
        
        motivationLabel.setHidden(difference > 0)
        
        return String(format: "%+.1f KG", ((newWeight! - oldWeight!) / 100).rounded() / 10)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let parameters = context as? [String: Double] {
            weightLabel.setText(weightLabelText(parameters["weight"]))
            bmiLabel.setText(bmiLabelText(parameters["bmi"]))
            differenceLabel.setText(differenceLabelText(parameters["previousWeight"], parameters["weight"]))
        }
    }
}
