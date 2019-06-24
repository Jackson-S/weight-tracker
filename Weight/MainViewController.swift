//
//  ViewController.swift
//  Weight
//
//  Created by Jackson Sommerich on 8/10/18.
//  Copyright © 2018 Jackson Sommerich. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    private let dataManager = DataManager()

    private var localData = InterfaceLocalDataStore(
        dataManager: nil,
        weight: nil,
        height: nil,
        lastRecordedWeight: nil,
        lastRecordedWeightDate: nil,
        bodyMassIndex: nil,
        bodyMassIndexCategory: nil,
        weightDisplayUnits: .kilograms,
        heightDisplayUnits: .meters,
        completionFunction: nil
    )

    @IBOutlet private var weightLabel: UILabel!
    @IBOutlet private var bodyMassIndexLabel: UILabel!
    @IBOutlet private var bodyMassIndexClassificationLabel: UILabel!
    @IBOutlet private var previousWeightLabel: UILabel!
    @IBOutlet private var previousWeightDateLabel: UILabel!
    @IBOutlet private var sliderView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        localData.dataManager = dataManager

        if !NSLocale.current.usesMetricSystem {
            localData.weightDisplayUnits = .pounds
            localData.heightDisplayUnits = .inches
        }

        dataManager.refreshValues(callback: updateDataManager)
    }

    @IBAction private func updateButtonPushed() {
        let confirmationFeedbackGenerator = UINotificationFeedbackGenerator()
        confirmationFeedbackGenerator.prepare()
        do {
            if let unwrappedWeight = localData.weight {
                try dataManager.addWeightMeasurement(measurement: unwrappedWeight, withBmi: true)
            } else {
                confirmationFeedbackGenerator.notificationOccurred(.error)
            }
        } catch {
            confirmationFeedbackGenerator.notificationOccurred(.error)
            NSLog("Failed to update weight")
            return
        }

        confirmationFeedbackGenerator.notificationOccurred(.success)
    }

    @IBAction private func settingsButtonPushed(_ sender: Any) {
        self.performSegue(withIdentifier: "settings", sender: self)
    }

    @IBAction private func panGesture(_ sender: UIPanGestureRecognizer) {
        let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        selectionFeedbackGenerator.prepare()

        let slideVelocity = Double(-sender.velocity(in: sliderView).y)
        if let startingWeight = localData.weight {
            let weightDifference = Measurement(value: slideVelocity / 8, unit: UnitMass.grams)

            // Click if a digit has changed (assumes 1 decimal place)
            let startWeightFloored = floor(startingWeight.converted(to: localData.weightDisplayUnits).value * 10)
            let endWeightFloored = floor((startingWeight + weightDifference).converted(to: localData.weightDisplayUnits).value * 10)
            if startWeightFloored != endWeightFloored {
                selectionFeedbackGenerator.selectionChanged()
            }

            changeWeight(by: weightDifference)
            updateLabels()
        }
    }

    private func updateDataManager() {
        DispatchQueue.main.async {
            do {
                let weight = try self.dataManager.getMostRecentWeight()
                let weightDate = try self.dataManager.getMostRecentWeightDate()
                self.localData.weight = weight
                self.localData.lastRecordedWeight = weight
                self.localData.lastRecordedWeightDate = weightDate
            } catch {
                // Assign a default weight value
                NSLog("Using default weight value of 75 kilograms")
                self.localData.weight = Measurement(value: 75, unit: .kilograms)
            }

            do {
                self.localData.height = try self.dataManager.getMostRecentHeight()
            } catch {
                // Prompt the user to enter their height
                self.settingsButtonPushed(self)
            }

            if let weightUnwrapped = self.localData.weight, let heightUnwrapped = self.localData.height {
                let bodyMassIndex = calculateBodyMassIndex(weight: weightUnwrapped, height: heightUnwrapped)
                let bodyMassIndexCategory = getBodyMassIndexCategory(forBodyMassIndex: bodyMassIndex)
                self.localData.bodyMassIndex = bodyMassIndex
                self.localData.bodyMassIndexCategory = bodyMassIndexCategory
            }

            self.updateLabels()
        }
    }

    private func updateLocalData() {
        DispatchQueue.main.async {
            do {
                self.localData.height = try self.dataManager.getMostRecentHeight()
            } catch {
                print("Cannot update local height")
            }

            if let unwrappedWeight = self.localData.weight, let unwrappedHeight = self.localData.height {
                let bodyMassIndex = calculateBodyMassIndex(weight: unwrappedWeight, height: unwrappedHeight)
                let bodyMassIndexCategory = getBodyMassIndexCategory(forBodyMassIndex: bodyMassIndex)
                self.localData.bodyMassIndex = bodyMassIndex
                self.localData.bodyMassIndexCategory = bodyMassIndexCategory
            }

            self.updateLabels()
        }
    }

    private func updateLabels() {
        // Update the UI on the main thread
        DispatchQueue.main.async {
            if let weightUnwrapped = self.localData.weight {
                let weightConverted = weightUnwrapped.converted(to: self.localData.weightDisplayUnits)
                let weightFloored = floor(weightConverted.value * 10) / 10
                let weightLabelString = String(format: LocalizedStrings.weightLabel, weightFloored, weightConverted.unit.symbol)
                self.weightLabel.text = weightLabelString
            }

            if let bodyMassIndexUnwrapped = self.localData.bodyMassIndex {
                let bodyMassIndexLabelText = String(format: LocalizedStrings.bmiLabel, bodyMassIndexUnwrapped)
                self.bodyMassIndexLabel.text = bodyMassIndexLabelText
            }

            if let bodyMassIndexCategoryUnwrapped = self.localData.bodyMassIndexCategory {
                self.bodyMassIndexClassificationLabel.text = getBmiClassification(bmiClassification: bodyMassIndexCategoryUnwrapped)
            }

            if let lastRecordedWeightUnwrapped = self.localData.lastRecordedWeight {
                let lastRecordedWeightConverted = lastRecordedWeightUnwrapped.converted(to: self.localData.weightDisplayUnits)
                let lastRecordedWeightText = String(format: LocalizedStrings.previousWeight, lastRecordedWeightConverted.value, lastRecordedWeightConverted.unit.symbol)
                self.previousWeightLabel.text = lastRecordedWeightText
            }

            if let lastRecordedWeightDateUnwrapped = self.localData.lastRecordedWeightDate {
                let temporalNounString = getTemporalNounString(previousDate: lastRecordedWeightDateUnwrapped)
                let lastRecordedTime = lastRecordedWeightDateUnwrapped.string(timeFormat: .short)
                let lastRecordedWeightDateString = String(format: temporalNounString, lastRecordedTime)
                self.previousWeightDateLabel.text = "(\(lastRecordedWeightDateString))"
            }
        }
    }

    private func changeWeight(by addedMass: Measurement<UnitMass>) {
        if let unwrappedWeight = localData.weight {
            // Update the weight
            let updatedWeight = (unwrappedWeight + addedMass).clamped(0, Double.infinity)
            localData.weight = updatedWeight
            // Recalculate Body Mass Index
            if let unwrappedHeight = self.localData.height {
                let bodyMassIndex = calculateBodyMassIndex(weight: unwrappedWeight, height: unwrappedHeight)
                let bodyMassIndexCategory = getBodyMassIndexCategory(forBodyMassIndex: bodyMassIndex)
                self.localData.bodyMassIndex = bodyMassIndex
                self.localData.bodyMassIndexCategory = bodyMassIndexCategory
            } else {
                print("Unable to update height (Reason: Height is nil)")
            }
        } else {
            print("Unable to change weight (Reason: Weight is nil)")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var segueTransitionable = segue.destination as? SegueTransitionable {
            var contextForSegue = localData
            contextForSegue.completionFunction = updateLocalData.self
            segueTransitionable.context = contextForSegue
        } else {
            NSLog("Transition does not conform to SegueTransitionable protocol")
        }
    }
}
