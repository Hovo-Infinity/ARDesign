//
//  UIColor+Extensions.swift
//  ARDesign
//
//  Created by Hovhannes Stepanyan on 4/8/18.
//  Copyright © 2018 David Varosyan. All rights reserved.
//

import UIKit

extension UIColor {
    class func mix(colors: Array<UIColor>) -> UIColor {
        if colors.count == 0 {
            return .clear
        }
        if colors.count == 1 {
            return colors.first!
        }
        var totalRed: CGFloat = 0
        var totalGreen: CGFloat = 0
        var totalBlue: CGFloat = 0
        var totalAlpha: CGFloat = 0
        for color in colors {
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
                totalBlue += blue
                totalGreen += green
                totalRed += red
                totalAlpha += alpha
            } else {
                totalBlue += 0
                totalGreen += 0
                totalRed += 0
                totalAlpha += 0
            }
        }
        return UIColor(red: totalRed, green: totalGreen, blue: totalBlue, alpha: CGFloat(Float(totalAlpha) / Float(colors.count)))
    }
}
