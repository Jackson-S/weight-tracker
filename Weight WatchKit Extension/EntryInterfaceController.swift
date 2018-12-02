//
//  InterfaceController.swift
//  Weight WatchKit Extension
//
//  Created by Jackson Sommerich on 8/10/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import Foundation
import WatchKit

class EntryInterfaceController: WKInterfaceController, WKCrownDelegate {
    
    @IBOutlet weak var weightLabel: WKInterfaceLabel!
    @IBOutlet weak var unitLabel: WKInterfaceLabel!
    @IBOutlet weak var previousWeightLabel: WKInterfaceLabel!
    @IBOutlet weak var previousWeightDateLabel: WKInterfaceLabel!
    
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
                weightLogic.updateWeight(updateLabels)
            }
        } else {
            // If this is the first run
            weightLogic.updateWeight(updateLabels)
        }
        
        crownSequencer.focus()
        super.willActivate()
    }
    
    override func didAppear() {
        updateLabels()
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
                                           bmiCategroy: weightLogic.bmiCategory)

        pushController(withName: "successInterface", context: parameters)
    }
    
    @IBAction func changeUnitButtonPushed() {
        switch selectedUnit {
        case .Imperial:
            self.selectedUnit = .Metric
        case .Metric:
            self.selectedUnit = .Imperial
        }
        
        updateLabels()
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
    
    private func lastWeighDateText() -> String {
        let previousWeightDate = weightLogic.lastWeightDate ?? Date(timeIntervalSinceNow: 0)

        let previousTimeString = previousWeightDate.string(timeFormat: DateFormatter.Style.short)
        let nonBreakingPreviousTimeString = previousTimeString.replacingOccurrences(of: " ", with: " ")
        
        if previousWeightDate.isSameDay(as: Date(timeIntervalSinceNow: 0)) {
            // Same day, only needs to display time
            return "Today \(nonBreakingPreviousTimeString)"
        } else if previousWeightDate.isSameDay(as: Date(timeIntervalSinceNow: -86_400)) {
            return "Yesterday \(nonBreakingPreviousTimeString)"
        } else {
            let durationPassed = DateInterval(start: previousWeightDate, end: Date(timeIntervalSinceNow: 0)).duration
            let daysPassed = ceil(durationPassed / 60 / 60 / 24)
            return "\(Int(daysPassed)) days ago at \(nonBreakingPreviousTimeString)"
        }
    }
    
    private func updateLabels() {
        var unitText: String
        var shortUnitText: String
        var previousWeightInUnit: Double
        
        switch selectedUnit {
        case .Metric:
            previousWeightInUnit = weightLogic.lastWeightKG ?? 0
            unitText = "Kilograms"
            shortUnitText = "Kg"
        case .Imperial:
            previousWeightInUnit = (weightLogic.lastWeightKG ?? 0) / 0.45359237
            unitText = "Pounds"
            shortUnitText = "lbs"
        }
        
        let previousWeightTruncated = String(format: "%.1f", previousWeightInUnit)
        let previousWeightLabelText = "\(previousWeightTruncated) \(shortUnitText) \(lastWeighDateText())"
        
        unitLabel.setText(unitText)
        previousWeightDateLabel.setText(previousWeightLabelText)
        updateWeightLabel()
    }
    
    private func updateWeightLabel() {
        switch selectedUnit {
            case .Metric:
                weightLabel.setText(String(format: "%.1f", weightLogic.weightKG ?? 0))
            case .Imperial:
                weightLabel.setText(String(format: "%.1f", weightLogic.weightLbs ?? 0))
        }
    }

}
