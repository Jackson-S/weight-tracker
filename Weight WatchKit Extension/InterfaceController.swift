//
//  InterfaceController.swift
//  Weight WatchKit Extension
//
//  Created by Jackson Sommerich on 8/10/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController, WKCrownDelegate {
    
    @IBOutlet weak var weightLabel: WKInterfaceLabel!
    @IBOutlet weak var bmiLabel: WKInterfaceLabel!
    @IBOutlet weak var bmiCategoryLabel: WKInterfaceLabel!
    
    let weightLogic = WeightLogic()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        crownSequencer.delegate = self
        updateWeightLabel()
    }
    
    override func willActivate() {
        updateWeightLabel()
        crownSequencer.focus()
        super.willActivate()
    }
    
    override func didAppear() {
        updateWeightLabel()
        crownSequencer.focus()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        crownSequencer.resignFocus()
    }
    
    @IBAction func incButtonClick() {
        weightLogic.incrementBy(100)
        WKInterfaceDevice.current().play(.click)
        updateWeightLabel()
    }
    
    @IBAction func decButtonClick() {
        weightLogic.incrementBy(-100)
        WKInterfaceDevice.current().play(.click)
        updateWeightLabel()
    }
    
    @IBAction func updateButtonClick() {
        // Capture this now because adding a new sample will overwrite it
        let previousWeight = weightLogic.lastWeight
        
        let weightResult = weightLogic.addNewWeightSample()
        let bmiResult = weightLogic.addNewBMISample()
        
        if !(weightResult && bmiResult) {
            print("Error recording results!")
        }
        
        WKInterfaceDevice.current().play(.success)
        
        let parameters = SuccessParameters(weight: weightLogic.weight,
                                           weightKG: weightLogic.weightKG,
                                           oldWeight: previousWeight,
                                           bmi: weightLogic.bmi)
        
        pushController(withName: "successInterface", context: parameters)
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        let incrementValue = (crownSequencer?.rotationsPerSecond)! * 15
        
        let startWeight = weightLogic.weightKG
        
        weightLogic.incrementBy(incrementValue)
        
        // Check to see if the output display has changed
        if startWeight != weightLogic.weightKG {
            WKInterfaceDevice.current().play(.click)
        }

        updateWeightLabel()
    }
    
    func updateWeightLabel() {
        let bmi = weightLogic.bmi ?? 0
        
        let weightLabelText = String(format: "%.1f KG", weightLogic.weightKG ?? 0)
        
        let bmiLabelText = String(format: "%.1f", bmi)
        
        weightLabel.setText(weightLabelText)
        bmiLabel.setText(bmiLabelText)
        bmiCategoryLabel.setText(weightLogic.bmiCategory)
    }

}
