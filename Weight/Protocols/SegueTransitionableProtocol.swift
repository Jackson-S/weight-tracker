//
//  SegueTransitionProtocol.swift
//  Weight
//
//  Created by Jackson Sommerich on 22/6/19.
//  Copyright © 2019 Jackson Sommerich. All rights reserved.
//

import Foundation

protocol SegueTransitionable {
    // Provides a context variable which is assigned to whenever a segue from MainViewController is performed.
    var context: InterfaceLocalDataStore? {get set}
}
