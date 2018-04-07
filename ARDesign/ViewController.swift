//
//  ViewController.swift
//  ARDesign
//
//  Created by David Varosyan on 3/17/18.
//  Copyright © 2018 David Varosyan. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var cameraStateLabel: UILabel!
    var sceneView: ARSCNView! = nil
    var debugView: DebugView! = nil
    
    override func viewDidLoad() {
        debugView = Bundle.main.loadNibNamed("DebugView", owner: nil, options: nil)?.first as? DebugView
        debugView.frame.size = CGSize(width: 320, height: 100)
        guard let _sceneView = self.view as? ARSCNView else { return }
        sceneView = _sceneView
        sceneView.delegate = self
        sceneView.debugOptions = []
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        debugView.stateChages = {[unowned self] tag, isOn in
            if tag == 0 {
                if isOn {
                    self.sceneView.debugOptions.update(with: ARSCNDebugOptions.showFeaturePoints)
                } else {
                    self.sceneView.debugOptions.remove(ARSCNDebugOptions.showFeaturePoints)
                }
            }
            if tag == 1 {
                if isOn {
                    self.sceneView.debugOptions.update(with: ARSCNDebugOptions.showWorldOrigin)
                } else {
                    self.sceneView.debugOptions.remove(ARSCNDebugOptions.showWorldOrigin)
                }
            }
        }
        let configration = ARWorldTrackingConfiguration()
        configration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configration)
        addGestures()
        print("success")
    }
    
    private func addGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addShip(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(showDebugMenu(_:)))
        edgeGesture.edges = .left
        sceneView.addGestureRecognizer(edgeGesture)
        edgeGesture.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @objc
    func addShip(_ sender:UIGestureRecognizer) {
        let location = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        guard let hitTestResult = hitTestResults.first else {
            return
        }
        let translation = hitTestResult.worldTransform.columns.3
        let x = translation.x
        let y = translation.y
        let z = translation.z
        guard let shipScene = SCNScene(named: "ship.scn"),
            let shipNode = shipScene.rootNode.childNode(withName: "ship", recursively: false)
            else { return }
        
        
        shipNode.position = SCNVector3(x,y,z)
        sceneView.scene.rootNode.addChildNode(shipNode)
    }
    
    @objc
    func showDebugMenu(_ sender:UIScreenEdgePanGestureRecognizer) {
        let location = sender.location(in: self.view)
        if sender.state == .began || sender.state == .changed {
            let origin = CGPoint(x: location.x - debugView.frame.width, y: location.y)
            debugView.frame.origin = origin
            sceneView.addSubview(debugView)
        }
        if sender.state == .ended {
            if location.x < (debugView.frame.width / 2) {
                debugView.hide(nil)
            }
        }
    }

}
