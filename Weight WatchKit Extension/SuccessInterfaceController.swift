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
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let parameters = context as? SuccessParameters {
            
            print("\(parameters.weight), \(parameters.oldWeight)")
            weightLabel.setText(String(format: "%.1f KG", parameters.weightKG))
            bmiLabel.setText(String(format: "%.1f", parameters.bmi))
            let difference = (parameters.weight - parameters.oldWeight) / 1000
            differenceLabel.setText(String(format: "%+.1f KG", difference))
            motivationLabel.setHidden(difference > 0)
        } else {
            print("Error recieving parameters")
        }
    }
}
