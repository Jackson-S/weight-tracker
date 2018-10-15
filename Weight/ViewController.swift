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
    @IBOutlet var weightStepper: UIStepper!
    @IBOutlet weak var bmiLabel: UITextField!
    @IBOutlet weak var bmiClassificationLabel: UILabel!
    
    let weightLogic = WeightLogic()
    let hkAuthorizer = HealthKitAuthorizer()
    var recordBMI = true

    @IBAction func bmiSwitchToggle(_ sender: UISwitch, forEvent event: UIEvent) {
        recordBMI = sender.isOn
    }
    
    @IBAction func weightStepperChanged() {
        weightLogic.setWeight(weightStepper.value)
        // Update stepper value in case weight logic constrains
        weightStepper.value = weightLogic.getWeight()
        updateWeightLabel()
    }
    
    @IBAction func updateButtonPushed() {
        weightLogic.addNewWeightSample()
        if bmiSwitch.isOn {
            weightLogic.addNewBMISample()
        }
    }
    
    func updateWeightLabel() {
        let weightLabelText = String(format: "%.1f KG", arguments: [weightLogic.getWeight() / 1000])
        weightEntry.text = weightLabelText
        bmiLabel.text = String(format: "%.2f", arguments: [weightLogic.getBMI()])
        bmiClassificationLabel.text = weightLogic.getBMIClassification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        hkAuthorizer.requestAuth()
        // Run an infinite loop while we wait for the weight logic to load
        while !weightLogic.completedLoad {
            usleep(100)
        }
        weightStepper.value = weightLogic.getWeight()
        updateWeightLabel()
        if !bmiSwitch.isOn {
            bmiSwitch.setOn(true, animated: false)
        }
        
    }
}

