//
//  OptionsInterfaceController.swift
//  Weight WatchKit Extension
//
//  Created by Jackson Sommerich on 15/10/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import WatchKit
import Foundation

class OptionsInterfaceController: WKInterfaceController {
    
    @IBOutlet var bmiToggle: WKInterfaceSwitch!
    @IBOutlet weak var heightLabel: WKInterfaceLabel!
    @IBOutlet weak var heightSelector: WKInterfaceSlider!
    
    @IBAction func bmiToggle(_ value: Bool) {
        options["addBMI"] = value
    }
    
    @IBAction func heightSelectorUpdate(_ value: Float) {
        height = Double(value) / 100
        heightLabel.setText(generateHeightText())
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        bmiToggle.setOn(options["addBMI"]!)
        heightSelector.setValue(Float(height * 100))
        heightLabel.setText(generateHeightText())
    }
    
    func generateHeightText() -> String {
        return String(format: "%.2f CM", height)
    }
}
