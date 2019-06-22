//
//  LocalizedUnits.swift
//  Weight
//
//  Created by Jackson Sommerich on 22/6/19.
//  Copyright © 2019 Jackson Sommerich. All rights reserved.
//

import Foundation

enum LocalizedUnits {
    // Long Form Units
    // Metric - Singular
    static let longFormKilogram = NSLocalizedString("kilogram", comment: "Kilogram long form unit singular")
    static let longFormGram = NSLocalizedString("gram", comment: "Gram long form unit singular")
    static let longFormMeter = NSLocalizedString("meter", comment: "Meter long form unit singular")
    static let longFormCentimeter = NSLocalizedString("centimeter", comment: "Centimeter long form unit singular")
    // Metric - Plural
    static let longFormKilogramPlural = NSLocalizedString("kilograms", comment: "Kilograms long form unit plural")
    static let longFormGramPlural = NSLocalizedString("grams", comment: "Grams long form unit plural")
    static let longFormMeterPlural = NSLocalizedString("meters", comment: "Meters long form unit plural")
    static let longFormCentimeterPlural = NSLocalizedString("centimeters", comment: "Centimeters long form unit plural")
    // Imperial - Singular
    static let longFormPound = NSLocalizedString("pound", comment: "Pound long form unit singular")
    static let longFormFoot = NSLocalizedString("foot", comment: "foot long form unit singular")
    static let longFormInch = NSLocalizedString("inch", comment: "Inch long form unit singular")
    // Imperial - Plural
    static let longFormPoundPlural = NSLocalizedString("pounds", comment: "Pounds long form unit plural")
    static let longFormFootPlural = NSLocalizedString("feet", comment: "Feet long form unit plural")
    static let longFormInchPlural = NSLocalizedString("inches", comment: "Inches long form unit plural")
    // British - Singular
    static let longFormStone = NSLocalizedString("stone", comment: "Stone long form unit singular")
    // British - Plural
    static let longFormStonePlural = NSLocalizedString("stone", comment: "Stone long form unit plural")
}
