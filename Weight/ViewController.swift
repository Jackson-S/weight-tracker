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
    @IBOutlet var bmiSwitch: UISwitch!
    @IBOutlet weak var bmiLabel: UITextField!
    @IBOutlet weak var bmiClassificationLabel: UILabel!
    @IBOutlet weak var sliderImage: UIImageView!
    
    let weightLogic = WeightLogic()
    let hkAuthorizer = HealthKitAuthorizer()
    var recordBMI = true

    @IBAction func bmiSwitchToggle(_ sender: UISwitch, forEvent event: UIEvent) {
        recordBMI = sender.isOn
    }
    
    @IBAction func updateButtonPushed() {
        weightLogic.addNewWeightSample()
        if bmiSwitch.isOn {
            weightLogic.addNewBMISample()
        }
    }
    
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        let verticalVelocity = Double(sender.velocity(in: sliderImage).y)
        weightLogic.incrementBy(Double(-verticalVelocity / 4))
        updateWeightLabel()
    }
    
    func updateWeightLabel() {
        if let weight = weightLogic.getWeight() {
            let weightLabelText = String(format: "%.1f KG", arguments: [weight.rounded() / 1000])
            weightEntry.text = weightLabelText
        } else {
            weightEntry.text = "Error"
        }
        
        if let bmi = weightLogic.getBMI() {
            let bmiLabelText = String(format: "%.1f", arguments: [bmi])
            bmiLabel.text = bmiLabelText
        } else {
            bmiLabel.text = "Error"
        }

        bmiClassificationLabel.text = weightLogic.getBMIClassification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hkAuthorizer.requestAuth()
        // Run an infinite loop while we wait for the weight logic to load
        while !weightLogic.completedLoad {
            usleep(100)
        }
        
        if !bmiSwitch.isOn {
            bmiSwitch.setOn(true, animated: false)
        }
        
        updateWeightLabel()
    }
}

