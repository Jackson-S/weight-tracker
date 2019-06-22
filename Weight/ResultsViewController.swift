//
//  ResultsViewController.swift
//  Weight
//
//  Created by Jackson Sommerich on 29/10/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import Foundation
import UIKit

class ResultsViewController: UIViewController, SegueTransitionable {
    // Context conforms to SegueTransitionable protocol and contains all data from MainViewController
    var context: InterfaceLocalDataStore?

    @IBOutlet private var weightLabel: UILabel!
    @IBOutlet private var bmiLabel: UILabel!
    @IBOutlet private var differenceLabel: UILabel!
    @IBOutlet private var categoryLabel: UILabel!

    override func viewDidLoad() {
        if let weightUnwrapped = context?.weight, let units = context?.weightDisplayUnits {
            let weightConverted = weightUnwrapped.converted(to: units)
            let weightString = String(format: "%.1f %@", weightConverted.value, weightConverted.unit.symbol)
            weightLabel.text = weightString

            if let lastWeightUnwrapped = context?.lastRecordedWeight {
                let weightDifference = weightUnwrapped - lastWeightUnwrapped
                let weightDifferenceConverted = weightDifference.converted(to: units)
                let weightDifferenceString = String(format: "%.1f %@", weightDifferenceConverted.value, weightDifferenceConverted.unit.symbol)
                differenceLabel.text = weightDifferenceString
            }
        }

        if let bodyMassIndexUnwrapped = context?.bodyMassIndex {
            bmiLabel.text = String(format: "%.1f", bodyMassIndexUnwrapped)
        }

        if let bodyMassIndexCategoryUnwrapped = context?.bodyMassIndexCategory {
            categoryLabel.text = getBmiClassification(bmiClassification: bodyMassIndexCategoryUnwrapped)
        }

        super.viewDidLoad()
    }
}
