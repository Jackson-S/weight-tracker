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
    
    var weightLogic: WeightLogic?
    
    @IBOutlet weak var heightLabel: WKInterfaceLabel!
    @IBOutlet weak var heightSelector: WKInterfaceSlider!
    
    @IBAction func heightSelectorUpdate(_ value: Float) {
        weightLogic?.height = Double(value) / 100
        heightLabel.setText(generateHeightText())
    }
    
    override func awake(withContext context: Any?) {
        weightLogic = context as? WeightLogic
        super.awake(withContext: context)
    }
    
    override func didAppear() {
        let heightCM = (weightLogic?.height ?? 0) * 100
        
        heightSelector.setValue(Float(heightCM))
        heightLabel.setText(generateHeightText())
    }
    
    func generateHeightText() -> String {
        return String(format: "%.2f M", weightLogic?.height ?? 0)
    }
}
