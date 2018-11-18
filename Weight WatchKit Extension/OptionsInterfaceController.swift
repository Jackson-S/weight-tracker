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
    
    var parameters: OptionsParameters?
    
    @IBOutlet weak var heightLabel: WKInterfaceLabel!
    @IBOutlet weak var heightSelector: WKInterfaceSlider!
    
    @IBAction func heightSelectorUpdate(_ value: Float) {
        parameters?.height = Double(value) / 100
        heightLabel.setText(generateHeightText())
    }
    
    override func awake(withContext context: Any?) {
        parameters = context as? OptionsParameters
        
        let heightCM = (parameters?.height ?? 0) * 100
        
        heightSelector.setValue(Float(heightCM))
        
        super.awake(withContext: context)
        
        heightLabel.setText(generateHeightText())
    }
    
    func generateHeightText() -> String {
        return String(format: "%.2f M", parameters?.height ?? 0)
    }
}
