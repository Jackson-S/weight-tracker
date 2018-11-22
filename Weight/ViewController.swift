//
//  ViewController.swift
//  Weight
//
//  Created by Jackson Sommerich on 8/10/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var bmiLabel: UILabel!
    @IBOutlet weak var bmiClassificationLabel: UILabel!
    @IBOutlet weak var sliderImage: UIImageView!
    
    
    let weightLogic = WeightLogic()
    
    @IBAction func updateButtonPushed() {
        // TODO: Display errors nicely
        let weightStatus = weightLogic.addNewWeightSample()
        let bmiStatus = weightLogic.addNewBMISample()
        
        if !(weightStatus && bmiStatus) {
            print("Failed to record")
        }
    }
    
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        let verticalVelocity = Double(sender.velocity(in: sliderImage).y)
        weightLogic.incrementBy(Double(-verticalVelocity / 4))
        updateLabels()
    }
    
    func updateLabels() {
        let weightKG = weightLogic.weightKG ?? 0
        let bmi = weightLogic.bmi ?? 0
        let classification = weightLogic.bmiCategory
        
        let weightLabelText = String(format: "%.1f KG", weightKG)
        let bmiLabelText = String(format: "%.1f BMI", bmi)
        
        weightLabel.text = weightLabelText
        bmiLabel.text = bmiLabelText
        bmiClassificationLabel.text = classification
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weightLogic.updateWeight(updateLabels)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newView = segue.destination as! ResultsViewController
        let parameters = ResultsParameters(weight: weightLogic.weight,
                                           weightKG: weightLogic.weightKG,
                                           oldWeight: weightLogic.lastWeight,
                                           bmi: weightLogic.bmi,
                                           bmiCategroy: weightLogic.bmiCategory,
                                           totalLoss: 0)
        newView.parameters = parameters
    }
}

