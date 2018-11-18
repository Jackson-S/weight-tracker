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
    
    func differenceLabelText(_ oldWeight: Double?, _ newWeight: Double?) -> String {
        let difference = ((newWeight ?? 0) - (oldWeight ?? 0)) / 1000
        
        if difference > 0 {
            motivationLabel.setHidden(true)
        }
        
        return String(format: "%+.1f KG", difference)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let parameters = context as? SuccessParameters {
            weightLabel.setText(String(format: "%.1f KG", parameters.weightKG))
            bmiLabel.setText(String(format: "%.1f", parameters.bmi))
            differenceLabel.setText(differenceLabelText(parameters.weight, parameters.oldWeight))
        } else {
            print("Error recieving parameters")
        }
    }
}
