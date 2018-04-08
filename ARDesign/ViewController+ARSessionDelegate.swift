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
        let planeGeometry: ARSCNPlaneGeometry? = ARSCNPlaneGeometry(device: ViewController.currentDevice!)
        planeGeometry?.update(from: planeAnchor.geometry)
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "carpet")
//        let x = CGFloat(planeAnchor.center.x)
//        let y = CGFloat(planeAnchor.center.y)
//        let z = CGFloat(planeAnchor.center.z)
//        planeNode.position = SCNVector3(x,y,z)
//        planeNode.eulerAngles.x = -.pi / 2
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
            handleLimitedTrackingState(for: reason)
            break
            }
        }
    }

    private func handleLimitedTrackingState(for reason: ARCamera.TrackingState.Reason) {
        switch reason {
        case .excessiveMotion:
            askUserToSlowDownMotion()
            break
        case .initializing:
            break
        case .insufficientFeatures:
            askUserForMoreLight()
            break
        case .relocalizing:
            self.relocalizing = true
            askUserToResetTracking()
            break
        }
    }
    
    private func askUserToResetTracking() {
        if self.relocalizing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {[unowned self] in
                let okAction = UIAlertAction(title: "Ok", style: .default) {[unowned self] (action) in
                    self.sceneView.session.pause()
                    self.sceneView.session.run(self.sceneView.session.configuration!, options: [.resetTracking, .removeExistingAnchors])
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {[unowned self] (action) in
                    if self.relocalizing {
                        self.askUserToResetTracking()
                    }
                }
                let alertController = UIAlertController(title: "Relocalizing take too long time", message: "Relocalizing take too long time, do You want to reset tracking?", preferredStyle: .alert)
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    private func askUserToSlowDownMotion() {
        let okAction = UIAlertAction(title: "Ok", style: .default)
        let alertController = UIAlertController(title: "Excessive Motion", message: "Excessive motion, please slow down", preferredStyle: .alert)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func askUserForMoreLight() {
        let okAction = UIAlertAction(title: "Ok", style: .default)
        let alertController = UIAlertController(title: "Insufficient Features", message: "Lack of features visible to the camera, please provide more light", preferredStyle: .alert)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
}

