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
        let weightLabelText = String(format: "%.1f KG", arguments: [weightLogic.getWeight().rounded() / 1000])
        let bmiLabelText = String(format: "%.1f", arguments: [weightLogic.getBMI()])
        weightLabel.setText(weightLabelText)
        bmiLabel.setText(bmiLabelText)
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
        updateWeightLabel()
    }
    
    @IBAction func decButtonClick() {
        weightLogic.incrementBy(-100)
        updateWeightLabel()
    }
    
    @IBAction func updateButtonClick() {
        weightLogic.addNewWeightSample()
        if options["addBMI"]! {
            weightLogic.addNewBMISample()
        }
        WKInterfaceDevice.current().play(.success)
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        let incrementValue = (crownSequencer?.rotationsPerSecond)! * 15
        weightLogic.incrementBy(incrementValue)
        updateWeightLabel()
    }

}
