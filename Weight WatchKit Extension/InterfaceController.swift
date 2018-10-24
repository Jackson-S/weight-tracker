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
    
    func updateWeightLabel() {
        if let weight = weightLogic.getWeight() {
            let weightLabelText = String(format: "%.1f KG", arguments: [weight.rounded() / 1000])
            weightLabel.setText(weightLabelText)
        } else {
            weightLabel.setText("Error")
        }
        
        if let bmi = weightLogic.getBMI() {
            let bmiLabelText = String(format: "%.1f", arguments: [bmi])
            bmiLabel.setText(bmiLabelText)
        } else {
            bmiLabel.setText("Error")
        }
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
        // This method is called when watch view controller is about to be visible to user
        while !weightLogic.completedLoad {
            usleep(100)
        }
        updateWeightLabel()
        crownSequencer.focus()
        super.willActivate()
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
        let contextForSuccess: [String: Double?] = [
            "weight": weightLogic.getWeight(),
            "previousWeight": weightLogic.lastWeight,
            "bmi": weightLogic.getBMI(),
        ]
        
        weightLogic.addNewWeightSample()
        
        if options["addBMI"]! {
            weightLogic.addNewBMISample()
        }
        
        WKInterfaceDevice.current().play(.success)
        
        presentController(withName: "successInterface", context: contextForSuccess)
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        let incrementValue = (crownSequencer?.rotationsPerSecond)! * 15
        
        var oldWeight: Double? = nil
        var newWeight: Double? = nil
        
        if let weight = weightLogic.getWeight() {
            oldWeight = (weight / 100).rounded() / 10
        }
        
        weightLogic.incrementBy(incrementValue)
        
        if let weight = weightLogic.getWeight() {
            newWeight = (weight / 100).rounded() / 10
        }
        
        if let newWeightUnwrapped = newWeight, let oldWeightUnwrapped = oldWeight {
            if newWeightUnwrapped != oldWeightUnwrapped {
                WKInterfaceDevice.current().play(.click)
            }
        }

        updateWeightLabel()
    }

}
