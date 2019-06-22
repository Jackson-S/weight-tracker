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

    private let dataManager = DataManager()
    private var localData: InterfaceLocalDataStore

    override init() {
        localData = InterfaceLocalDataStore(
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

        if !NSLocale.current.usesMetricSystem {
            localData.weightDisplayUnits = .pounds
            localData.heightDisplayUnits = .feet
        }

        super.init()

        updateDataManager()
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        crownSequencer.delegate = self
    }

    override func willActivate() {
        // Check if the interface needs to be updated and do so if necessary
        super.willActivate()
        updateLabels()
        crownSequencer.focus()
    }

    override func didAppear() {
        super.didAppear()
        updateLabels()
        crownSequencer.focus()
    }

    override func didDeactivate() {
        super.didDeactivate()
        // Set the deactivation time so we can selectively update if needed.
        crownSequencer.resignFocus()
    }

    @IBAction func incButtonClick() {
        let weightDifference = Measurement(value: 0.1, unit: localData.weightDisplayUnits)
        changeWeight(by: weightDifference)
        WKInterfaceDevice.current().play(.click)
        updateLabels()
    }

    @IBAction func decButtonClick() {
        let weightDifference = Measurement(value: 0.1, unit: localData.weightDisplayUnits)
        changeWeight(by: weightDifference)
        WKInterfaceDevice.current().play(.click)
        updateLabels()
    }

    @IBAction func updateButtonClick() {
        do {
            if let unwrappedWeight = localData.weight {
                try dataManager.addWeightMeasurement(measurement: unwrappedWeight, withBmi: true)
            }
        } catch {
            WKInterfaceDevice.current().play(.failure)
            print("Failed to update weight")
            return
        }

        WKInterfaceDevice.current().play(.success)
        pushController(withName: "resultsInterface", context: localData)
    }

    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        if let crownRotationValue = crownSequencer?.rotationsPerSecond, let startingWeight = localData.weight {
            // Round crown rotation to 1 decimal place
            let roundedRotation = (crownRotationValue * 10).rounded() / 10
            let weightDifference = Measurement(value: roundedRotation / 10, unit: localData.weightDisplayUnits)
            changeWeight(by: weightDifference)

            // Click if a digit has changed (assumes 1 decimal place)
            let startWeightFloored = floor(startingWeight.converted(to: localData.weightDisplayUnits).value * 10)
            let endWeightFloored = floor((startingWeight + weightDifference).converted(to: localData.weightDisplayUnits).value * 10)
            if startWeightFloored != endWeightFloored {
                WKInterfaceDevice.current().play(.click)
            }
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
                NSLog("Cannot obtain weight")
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

    private func getLastRecordedWeightText() -> String {
        if let unwrappedLastRecordedWeightDate = localData.lastRecordedWeightDate {
            let lastRecordedWeightTime = unwrappedLastRecordedWeightDate.string(dateFormat: .short)
            // Replace spaces with non-breaking spaces to stop time from being seperated if display isn't big enough.
            let lastRecordedWeightTimeNonBreaking = lastRecordedWeightTime.replacingOccurrences(of: " ", with: " ")
            if unwrappedLastRecordedWeightDate.isToday() {
                return String(format: LocalizedStrings.previousWeightTimeToday, lastRecordedWeightTimeNonBreaking)
            } else if unwrappedLastRecordedWeightDate.isYesterday() {
                return String(format: LocalizedStrings.previousWeightTimeYesterday, lastRecordedWeightTimeNonBreaking)
            } else {
                let daysElapsedSinceLastWeight = unwrappedLastRecordedWeightDate.daysElapsedToToday()
                return String(format: LocalizedStrings.previousWeightTimeOther, daysElapsedSinceLastWeight, lastRecordedWeightTimeNonBreaking)
            }
        } else {
            return "Unable to create weight text."
        }
    }

    private func updateLabels() {
        let longFormUnits = [UnitMass.kilograms: LocalizedUnits.longFormKilogramPlural, UnitMass.pounds: LocalizedUnits.longFormPoundPlural]

        if let lastRecordedWeightUnwrapped = localData.lastRecordedWeight {
            let lastRecordedWeightConverted = lastRecordedWeightUnwrapped.converted(to: localData.weightDisplayUnits)
            let lastRecordedWeightRounded = String(format: "%.1f", lastRecordedWeightConverted.value)
            let shortFormUnit = lastRecordedWeightConverted.unit.symbol
            let lastRecordedWeightString = String(format: LocalizedStrings.previousWeightLabel, lastRecordedWeightRounded, shortFormUnit)
            previousWeightLabel.setText(lastRecordedWeightString)
            previousWeightDateLabel.setText(getLastRecordedWeightText())
        }

        if let currentWeightUnwrapped = localData.weight {
            let currentWeightConverted = currentWeightUnwrapped.converted(to: localData.weightDisplayUnits)
            let currentWeightString = String(format: "%.1f", currentWeightConverted.value)
            weightLabel.setText(currentWeightString)
            unitLabel.setText(longFormUnits[currentWeightConverted.unit])
        }
    }

    private func changeWeight(by addedMass: Measurement<UnitMass>) {
        if let unwrappedWeight = localData.weight {
            let updatedWeight = unwrappedWeight + addedMass
            localData.weight = updatedWeight
        } else {
            print("Unable to change weight (Reason: Weight is nil)")
        }
    }
}
