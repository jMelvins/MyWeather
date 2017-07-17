//
//  RotateAnimation.swift
//  MyWeather
//
//  Created by Vladislav Shilov on 17.07.17.
//  Copyright © 2017 Vladislav Shilov. All rights reserved.
//

import QuartzCore
import UIKit

class RotateAnimation {
    
    func rotator(for viewForLabel: UILabel){

        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")

        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 100.0
        logoRotator.fromValue = 0.0
        logoRotator.toValue = 20 * Double.pi
        logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)

        viewForLabel.layer.add(logoRotator, forKey: "logoRotator")

    }

}
