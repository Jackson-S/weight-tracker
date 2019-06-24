//
//  SliderViewController.swift
//  Weight
//
//  Created by Jackson Sommerich on 24/6/19.
//  Copyright © 2019 Jackson Sommerich. All rights reserved.
//

import UIKit
import SpriteKit

class SliderViewController: UIViewController {
    @IBOutlet private var sliderSpriteKitView: SKView!
    @IBOutlet private var slideInstructionLabel: UILabel!

    override func viewDidLoad() {
        sliderSpriteKitView.allowsTransparency = true
        sliderSpriteKitView.backgroundColor = .clear
        sliderSpriteKitView.scene?.backgroundColor = .clear
        super.viewDidLoad()
    }
}
