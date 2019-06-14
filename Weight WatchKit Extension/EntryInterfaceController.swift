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
        super.didAppear()
        updateLabels()
        crownSequencer.focus()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        // Set the deactivation time so we can selectively update if needed.
        self.deactivationTime = Date(timeIntervalSinceNow: 0)
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
        // Get the last weight date, defaulting to the current time if none found.
        let previousWeightDate = weightLogic.lastWeightDate ?? Date(timeIntervalSinceNow: 0)

        let previousTimeString = previousWeightDate.string(timeFormat: DateFormatter.Style.short)
        // Replace spaces with non-breaking spaces to stop time from being seperated if display isn't big enough.
        let nonBreakingPreviousTimeString = previousTimeString.replacingOccurrences(of: " ", with: " ")
        
        if previousWeightDate.isToday() {
            return String.localizedStringWithFormat(LocalizedStrings.previousWeightTimeToday, nonBreakingPreviousTimeString)
        } else if previousWeightDate.isYesterday() {
            return String.localizedStringWithFormat(LocalizedStrings.previousWeightTimeYesterday, nonBreakingPreviousTimeString)
        } else {
            let daysPassed = previousWeightDate.daysElapsedToToday()
            return String.localizedStringWithFormat(LocalizedStrings.previousWeightTimeOther, daysPassed, nonBreakingPreviousTimeString)
        }
    }
    
    private func updateLabels() {
        var unitText: String
        var shortUnitText: String
        var previousWeightInUnit: Double
        
        switch selectedUnit {
        case .Metric:
            previousWeightInUnit = weightLogic.lastWeightKG ?? 0
            unitText = LocalizedStrings.longFormKg
            shortUnitText = LocalizedStrings.shortFormKg
        case .Imperial:
            previousWeightInUnit = (weightLogic.lastWeightKG ?? 0) / 0.45359237
            unitText = LocalizedStrings.longFormLbs
            shortUnitText = LocalizedStrings.shortFormLbs
        }
        
        let previousWeightTruncated = String.localizedStringWithFormat("%.1f", previousWeightInUnit)
        let previousWeightLabelText = String.localizedStringWithFormat(LocalizedStrings.previousWeightLabel, previousWeightTruncated, shortUnitText, lastWeighDateText())
        
        unitLabel.setText(unitText)
        previousWeightDateLabel.setText(previousWeightLabelText)
        updateWeightLabel()
    }
    
    private func updateWeightLabel() {
        switch selectedUnit {
            case .Metric:
                weightLabel.setText(String.localizedStringWithFormat("%.1f", weightLogic.weightKG ?? 0))
            case .Imperial:
                weightLabel.setText(String.localizedStringWithFormat("%.1f", weightLogic.weightLbs ?? 0))
        }
    }
}
