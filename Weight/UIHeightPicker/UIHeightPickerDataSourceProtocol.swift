//
//  HeightPickerDataSource.swift
//  Weight
//
//  Created by Jackson Sommerich on 22/6/19.
//  Copyright © 2019 Jackson Sommerich. All rights reserved.
//

import UIKit

internal protocol UIHeightPickerDataSource: UIPickerViewDataSource {
    var heightUnitValues: [[String]] { get }
    var heightUnits: [UnitLength] { get }
}
