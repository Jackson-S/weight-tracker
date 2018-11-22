//
//  InterfaceController.swift
//  Weight WatchKit Extension
//
//  Created by Jackson Sommerich on 8/10/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import WatchKit
import Foundation

class EntryInterfaceController: WKInterfaceController, WKCrownDelegate {
    
    @IBOutlet weak var weightLabel: WKInterfaceLabel!
    @IBOutlet weak var unitLabel: WKInterfaceLabel!
    @IBOutlet weak var previousWeightLabel: WKInterfaceLabel!
    
    
    var selectedUnit: UnitType = .Metric
    let weightLogic = WeightLogic()
    
    var deactivationTime: Date?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        crownSequencer.delegate = self
    }
    
    override func willActivate() {
        // Check if the interface needs to be updated and do so if necessary
        if let deactivationTime = self.deactivationTime {
            // Check if more than 2 minutes have passed since last run.
            if Date(timeIntervalSinceNow: 0).timeIntervalSince(deactivationTime) > TimeInterval(exactly: 120)! {
                weightLogic.updateWeight(updateWeightLabel)
            }
        } else {
            // If this is the first run
            weightLogic.updateWeight(updateWeightLabel)
        }
        
        crownSequencer.focus()
        super.willActivate()
    }
    
    override func didAppear() {
        crownSequencer.focus()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        self.deactivationTime = Date(timeIntervalSinceNow: 0)
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
        
        let parameters = ResultsParameters(weight: weightLogic.weight,
                                           weightKG: weightLogic.weightKG,
                                           oldWeight: previousWeight,
                                           bmi: weightLogic.bmi,
                                           bmiCategroy: weightLogic.bmiCategory,
                                           totalLoss: 0)

        pushController(withName: "successInterface", context: parameters)
    }
    
    @IBAction func changeUnitButtonPushed() {
        switch selectedUnit {
        case .Imperial:
            self.selectedUnit = .Metric
        case .Metric:
            self.selectedUnit = .Imperial
        }
        
        updateWeightLabel()
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
        var unitText: String
        var weightInUnit: Double
        var previousWeightInUnit: Double
        
        switch selectedUnit {
        case .Metric:
            weightInUnit = weightLogic.weightKG ?? 0
            previousWeightInUnit = weightLogic.lastWeightKG ?? 0
            unitText = "Kilograms"
        case .Imperial:
            weightInUnit = (weightLogic.weightKG ?? 0) / 0.45359237
            previousWeightInUnit = (weightLogic.lastWeightKG ?? 0) / 0.45359237
            unitText = "Pounds"
        }
        
        let weightLabelText = String(format: "%.1f", weightInUnit)
        let previousWeightLabelText = String(format: "Previous: %.1f", previousWeightInUnit)
        
        weightLabel.setText(weightLabelText)
        unitLabel.setText(unitText)
        previousWeightLabel.setText(previousWeightLabelText)
    }

}
