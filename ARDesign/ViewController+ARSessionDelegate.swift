//
//  ViewController+ARSessionDelegate.swift
//  ARDesign
//
//  Created by Hovhannes Stepanyan on 4/7/18.
//  Copyright © 2018 David Varosyan. All rights reserved.
//

import ARKit

extension ViewController: ARSCNViewDelegate {    
    func sessionInterruptionEnded(_ session: ARSession) {
        session.run(session.configuration!)
    }
    
    // when renderer detect features, automaticy add anchors
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // care only about plane anchores, i.e. detecting planes
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        if planeAnchor.alignment == .horizontal {
            let carpet = createCarpetFor(planeAnchor: planeAnchor)
            node.addChildNode(carpet)
        } else {
            // TODO add poster for walls
        }
    }
    
    func createCarpetFor(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        plane.materials.first?.diffuse.contents = UIImage(named: "carpet")
        let planeNode = SCNNode(geometry: plane)
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        return planeNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { (child, _) in
            child.removeFromParentNode()
        }
        if planeAnchor.alignment == .horizontal {
            let carpet = createCarpetFor(planeAnchor: planeAnchor)
            node.addChildNode(carpet)
        } else {
            // TODO same for wall posters
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            cameraStateLabel.text = "Not available..."
            relocalizing = false
            break
        case .normal:
            cameraStateLabel.text = "Ready to detect planes..."
            relocalizing = false
            break
        case .limited(let reason): do {
            cameraStateLabel.text = "Limited tracking \(reason)..."
            if reason == .relocalizing {
                relocalizing = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[unowned self] in
                    if self.relocalizing {
                        self.askUserToResetTracking()
                    }
                }
            }
            break
            }
        }
    }
    
    func askUserToResetTracking() {
        let okAction = UIAlertAction(title: "Ok", style: .default) {[unowned self] (action) in
            self.sceneView.session.pause()
            self.sceneView.session.run(self.sceneView.session.configuration!, options: [.resetTracking, .removeExistingAnchors])
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {[unowned self] (action) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[unowned self] in
                if self.relocalizing {
                    self.askUserToResetTracking()
                }
            }
        }
        let alertController = UIAlertController(title: "Relocalizing take too long time", message: "Relocalizing take too long time, do You want to reset tracking?", preferredStyle: .alert)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
}

