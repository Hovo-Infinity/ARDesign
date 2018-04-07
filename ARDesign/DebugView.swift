//
//  DebugView.swift
//  ARDesign
//
//  Created by David Varosyan on 3/20/18.
//  Copyright © 2018 David Varosyan. All rights reserved.
//

import UIKit

class DebugView: UIView {

    var stateChages: ((Int, Bool) -> Void)?
    @IBAction public func hide(_ sender: UIButton?) {
        self.removeFromSuperview()
    }
    
    @IBAction private func stateCnage(_ sender: UISwitch) {
        if let callback = stateChages {
            callback(sender.tag, sender.isOn)
        }
    }
}
