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
            let classification = self.weightLogic.bmiCategory
            let previousWeight = self.weightLogic.lastWeightKG ?? 0
            
            let weightLabelText = String(format: "%.1f KG", weightKG)
            let bmiLabelText = String(format: "%.1f BMI", bmi)
            let lastWeightText = String(format: "Previous: %.1f KG", previousWeight)
            
            self.weightLabel.text = weightLabelText
            self.bmiLabel.text = bmiLabelText
            self.bmiClassificationLabel.text = classification
            self.lastWeightLabel.text = lastWeightText
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

