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

    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraStateLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    var sceneView: ARSCNView! = nil
    var debugView: DebugView! = nil
    var relocalizing = false
    var datas = [#imageLiteral(resourceName: "carpet_category"), #imageLiteral(resourceName: "wallPoster"), #imageLiteral(resourceName: "chair"), #imageLiteral(resourceName: "table"), #imageLiteral(resourceName: "wallPicture")]
    
    private var menuOpened = false {
        didSet {
            if menuOpened {
                menuButton.transform = CGAffineTransform(rotationAngle: .pi)
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(5)
                collectionViewBottomConstraint.constant = -44
                UIView.commitAnimations()
            } else {
                menuButton.transform = CGAffineTransform(rotationAngle: 0)
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(5)
                collectionViewBottomConstraint.constant = 0
                UIView.commitAnimations()
            }
        }
    }
    static let currentDevice: MTLDevice? = MTLCreateSystemDefaultDevice()
    
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
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotateShip(_:)))
        sceneView.addGestureRecognizer(rotationGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @objc
    func rotateShip(_ sender:UIRotationGestureRecognizer) {
        if sender.state == .began {
            let location = sender.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(location, options: nil)
            guard let hitTestResult = hitTestResults.first else {
                return
            }
            let node = hitTestResult.node
            let rotation = sender.rotation
            let action = SCNAction.rotate(by: rotation, around: SCNVector3(0, 1, 0), duration: 2)
            node.runAction(action)
            sender.rotation = 0
        }
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
        guard let shipScene = SCNScene(named: "ship.scn") else { return }

        let shipNode = shipScene.rootNode.childNode(withName: "ship", recursively: true)
        shipNode?.position = SCNVector3(x, y, z)
        sceneView.scene.rootNode.addChildNode(shipNode!)
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

    @IBAction func buttonTapped(_ sender: UIButton!) {
        menuOpened = !menuOpened
    }
}
