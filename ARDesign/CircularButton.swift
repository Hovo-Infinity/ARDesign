//
//  CircularButton.swift
//  ARDesign
//
//  Created by Hovhannes Stepanyan on 4/8/18.
//  Copyright © 2018 David Varosyan. All rights reserved.
//

import UIKit

@IBDesignable
class CircularButton: UIButton {
    
    @IBInspectable var borderColor: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var fillColor: UIColor = .red {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var cornerRadius: CGFloat = 22.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let path = UIBezierPath(ovalIn: bounds)
        fillColor.setFill()
        path.fill()
        borderColor.setStroke()
        path.stroke()
        path.lineWidth = borderWidth
    }

}
