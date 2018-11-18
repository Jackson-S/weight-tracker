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
    
    let weightLogic = WeightLogic()
    
    func roundedWeightInKG() -> Double {
        let weight = weightLogic.weight ?? 0
        return (weight / 100).rounded() / 10
    }
    
    func updateWeightLabel() {
        let bmi = weightLogic.bmi ?? 0
        
        let weightLabelText = String(format: "%.1f KG", roundedWeightInKG())
        
        let bmiLabelText = String(format: "%.1f", bmi)
        
        weightLabel.setText(weightLabelText)
        bmiLabel.setText(bmiLabelText)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        crownSequencer.delegate = self
        updateWeightLabel()
    }
    
    override func didAppear() {
        updateWeightLabel()
        crownSequencer.focus()
    }
    
    override func willActivate() {
//        // This method is called when watch view controller is about to be visible to user
//        while !weightLogic.completedLoad {
//            usleep(100)
//        }
        
        updateWeightLabel()
        crownSequencer.focus()
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        crownSequencer.resignFocus()
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        return OptionsParameters(height: weightLogic.height)
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
        let weightResult = weightLogic.addNewWeightSample()
        let bmiResult = weightLogic.addNewBMISample()
        
        if !(weightResult && bmiResult) {
            print("Error recording results!")
        }
        
        WKInterfaceDevice.current().play(.success)
        
        let parameters = SuccessParameters(weight: weightLogic.weight,
                                           oldWeight: weightLogic.lastWeight,
                                           bmi: weightLogic.bmi)
        
        presentController(withName: "successInterface", context: parameters)
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        let incrementValue = (crownSequencer?.rotationsPerSecond)! * 15
        
        let startWeight = roundedWeightInKG()
        
        weightLogic.incrementBy(incrementValue)
        
        // Check to see if the output display has changed
        if startWeight != roundedWeightInKG() {
            WKInterfaceDevice.current().play(.click)
        }

        updateWeightLabel()
    }

}
