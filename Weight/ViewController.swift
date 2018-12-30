//
//  ViewController.swift
//  Weight
//
//  Created by Jackson Sommerich on 8/10/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var bmiLabel: UILabel!
    @IBOutlet weak var bmiClassificationLabel: UILabel!
    @IBOutlet weak var lastWeightLabel: UILabel!
    @IBOutlet weak var lastWeightDateLabel: UILabel!
    @IBOutlet weak var sliderImage: UIImageView!
    
    let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
    let confirmationFeedbackGenerator = UINotificationFeedbackGenerator()
    let weightLogic = WeightLogic()
    
    @IBAction func updateButtonPushed() {
        // TODO: Display errors nicely
        confirmationFeedbackGenerator.prepare()
        
        let weightStatus = weightLogic.addNewWeightSample()
        let bmiStatus = weightLogic.addNewBMISample()
        
        if !(weightStatus && bmiStatus) {
            confirmationFeedbackGenerator.notificationOccurred(.error)
            print("Failed to record")
        } else {
            confirmationFeedbackGenerator.notificationOccurred(.success)
        }
    }
    
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        selectionFeedbackGenerator.prepare()
        let verticalVelocity = Double(-sender.velocity(in: sliderImage).y)
        let startWeight = weightLogic.weightKG

        weightLogic.incrementBy(verticalVelocity / 8)
        
        // Check to see if the output display has changed
        if startWeight != weightLogic.weightKG {
            selectionFeedbackGenerator.selectionChanged()
        }
        
        updateLabels()
    }
    
    func updateLabels() {
        // Update the UI on the main thread
        DispatchQueue.main.async {
            let weightKG = self.weightLogic.weightKG ?? 0
            let bmi = self.weightLogic.bmi ?? 0
            let classification = self.weightLogic.bmiCategory ?? BMICategory.Normal
            let previousWeight = self.weightLogic.lastWeightKG ?? 0
            let previousWeightDate = self.weightLogic.lastWeightDate ?? Date(timeIntervalSinceNow: 0)
            
            let weightLabelLocalString = NSLocalizedString("%.1f KG", comment: "Weight label display text")
            let weightLabelText = String.localizedStringWithFormat(weightLabelLocalString, weightKG)
            let bmiLabelLocalString = NSLocalizedString("BMI: %.1f", comment: "BMI label display text")
            let bmiLabelText = String.localizedStringWithFormat(bmiLabelLocalString, bmi)
            let previousWeightLocalString = NSLocalizedString("Previous: %.1f KG", comment: "Previous weight label display text")
            let lastWeightText = String.localizedStringWithFormat(previousWeightLocalString, previousWeight)
            
            var lastWeightDateText = ""
            let previousTimeString = previousWeightDate.string(timeFormat: DateFormatter.Style.short)
            if previousWeightDate.isSameDay(as: Date(timeIntervalSinceNow: 0)) {
                // Same day, only needs to display time
                let lastWeightLocalString = NSLocalizedString("Today at %@", comment: "Last weight date text for current day")
                lastWeightDateText = String.localizedStringWithFormat(lastWeightLocalString, previousTimeString)
            } else if previousWeightDate.isSameDay(as: Date(timeIntervalSinceNow: -86_400)) {
                let lastWeightLocalString = NSLocalizedString("Yesterday at %@", comment: "Last weight date text for yesterday")
                lastWeightDateText = String.localizedStringWithFormat(lastWeightLocalString, previousTimeString)
            } else {
                let lastWeightLocalString = NSLocalizedString("%i days ago at %@", comment: "Last weight date text for >2 days ago")
                let daysPassed = ceil(DateInterval(start: previousWeightDate, end: Date(timeIntervalSinceNow: 0)).duration / 60 / 60 / 24)
                lastWeightDateText = String.localizedStringWithFormat(lastWeightLocalString, daysPassed, previousTimeString)
            }
            
            self.weightLabel.text = weightLabelText
            self.bmiLabel.text = bmiLabelText
            switch classification {
                case .Underweight:
                    self.bmiClassificationLabel.text = String(format: "(%@)", NSLocalizedString("Underweight", comment: "BMI Category: Underweight"))
                case .Normal:
                    self.bmiClassificationLabel.text = String(format: "(%@)", NSLocalizedString("Normal", comment: "BMI Category: Normal"))
                case .Overweight:
                    self.bmiClassificationLabel.text = String(format: "(%@)", NSLocalizedString("Overweight", comment: "BMI Category: Overweight"))
                case .Obese:
                    self.bmiClassificationLabel.text = String(format: "(%@)", NSLocalizedString("Obese", comment: "BMI Category: Obese"))
            }
            self.lastWeightLabel.text = lastWeightText
            self.lastWeightDateLabel.text = "(\(lastWeightDateText))"
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Update HealthKit data and then update labels
        weightLogic.updateWeight(updateLabels)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueName = segue.identifier {
            if segueName == "results" {
                let newView = segue.destination as! ResultsViewController
                let parameters = ResultsParameters(weight: weightLogic.weight,
                                                   weightKG: weightLogic.weightKG,
                                                   oldWeight: weightLogic.lastWeight,
                                                   bmi: weightLogic.bmi,
                                                   bmiCategroy: weightLogic.bmiCategory)
                newView.parameters = parameters
            }
        }
    }
}

