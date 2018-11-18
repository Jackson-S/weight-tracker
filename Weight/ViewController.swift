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
    
    @IBOutlet var weightEntry: UITextField!
    @IBOutlet weak var bmiLabel: UITextField!
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
        updateWeightLabel()
    }
    
    func updateWeightLabel() {
        let weight = weightLogic.weight ?? 0
        let bmi = weightLogic.bmi ?? 0
        let classification = weightLogic.bmiCategory
        
        let weightKG = weight.rounded() / 1000
        let weightLabelText = String(format: "%.1f KG", weightKG)
        
        let bmiLabelText = String(format: "%.1f BMI", bmi)
        
        weightEntry.text = weightLabelText
        bmiLabel.text = bmiLabelText
        bmiClassificationLabel.text = classification
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateWeightLabel()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newView = segue.destination as! ResultsViewController
        let parameters = SuccessParameters(weight: weightLogic.weight,
                                           oldWeight: weightLogic.lastWeight,
                                           bmi: weightLogic.bmi)
        newView.parameters = parameters
    }
}

