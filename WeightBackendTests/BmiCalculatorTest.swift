//
//  BmiCalculatorTest.swift
//  WeightBackendTests
//
//  Created by Jackson Sommerich on 24/6/19.
//  Copyright © 2019 Jackson Sommerich. All rights reserved.
//

import XCTest

class BmiCalculatorTest: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testZeroHeight() {
        // Test zero height. Should both produce nil, zero weight should not.
        let zeroHeight = Measurement(value: 0, unit: UnitLength.meters)
        let nonZeroHeight = Measurement(value: 1, unit: UnitLength.meters)
        let weight = Measurement(value: 0, unit: UnitMass.kilograms)
        let resultBmiZeroHeight = calculateBodyMassIndex(weight: weight, height: zeroHeight)
        let resultBmiNonZeroHeight = calculateBodyMassIndex(weight: weight, height: nonZeroHeight)

        XCTAssertNil(resultBmiZeroHeight)
        XCTAssertNotNil(resultBmiNonZeroHeight)
    }

    func testNegative() {
        // Test negative height and weight. Should both produce nil as they're invalid.
        let heightNegative = Measurement(value: -10, unit: UnitLength.meters)
        let weightNetative = Measurement(value: -10, unit: UnitMass.kilograms)
        let heightPositive = Measurement(value: 10, unit: UnitLength.meters)
        let weightPositive = Measurement(value: 10, unit: UnitMass.kilograms)
        let negativeHeight = calculateBodyMassIndex(weight: weightPositive, height: heightNegative)
        let negativeWeight = calculateBodyMassIndex(weight: weightNetative, height: heightPositive)
        XCTAssertNil(negativeHeight)
        XCTAssertNil(negativeWeight)
    }

    func testCorrectness() {
        // Test for known value 1
        var weight = Measurement(value: 100, unit: UnitMass.kilograms)
        var height = Measurement(value: 100, unit: UnitLength.centimeters)
        var result = calculateBodyMassIndex(weight: weight, height: height)
        XCTAssertEqual(result, 100.0)

        // Test for known value 2
        weight = Measurement(value: 89, unit: UnitMass.kilograms)
        height = Measurement(value: 200, unit: UnitLength.centimeters)
        result = calculateBodyMassIndex(weight: weight, height: height)
        XCTAssertEqual(result, 22.25)
    }

    func testCategoryInclusivity() {
        let minimumNormalBmi = 18.5
        let minimumOverweightBmi = 25.0
        let minimumObeseBmi = 30.0

        XCTAssertEqual(getBodyMassIndexCategory(forBodyMassIndex: minimumNormalBmi), BodyMassIndexCategory.normal)
        XCTAssertEqual(getBodyMassIndexCategory(forBodyMassIndex: minimumOverweightBmi), BodyMassIndexCategory.overweight)
        XCTAssertEqual(getBodyMassIndexCategory(forBodyMassIndex: minimumObeseBmi), BodyMassIndexCategory.obese)
    }

    func testCategoryError() {
        XCTAssertNil(getBodyMassIndexCategory(forBodyMassIndex: nil))
        XCTAssertNil(getBodyMassIndexCategory(forBodyMassIndex: -10))
        XCTAssertNil(getBodyMassIndexCategory(forBodyMassIndex: Double.nan))
        XCTAssertNil(getBodyMassIndexCategory(forBodyMassIndex: Double.infinity))
        XCTAssertNil(getBodyMassIndexCategory(forBodyMassIndex: -Double.infinity))
    }

    func testBodyMassIndexCalculationPerformance() {
        let height = Measurement(value: 1, unit: UnitLength.meters)
        let weights = (1...1000).map { Measurement(value: Double($0), unit: UnitMass.kilograms) }
        var bodyMassIndicies: [Double?] = []

        self.measure {
            for weight in weights {
                bodyMassIndicies.append(calculateBodyMassIndex(weight: weight, height: height))
            }
        }

        // Stop swift from optimizing test away
        XCTAssertNotNil(bodyMassIndicies.randomElement()!)
    }

    func testBodyMassIndexCategoryCalculationPerformance() {
        let bodyMassIndicies = 1...1000
        var bodyMassIndexCategories: [BodyMassIndexCategory?] = []

        self.measure {
            for index in bodyMassIndicies {
                bodyMassIndexCategories.append(getBodyMassIndexCategory(forBodyMassIndex: Double(index)))
            }
        }

        // Stop swift from optimizing test away
        XCTAssertNotNil(bodyMassIndexCategories.randomElement()!)
    }
}
