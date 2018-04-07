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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        plane.materials.first?.diffuse.contents = UIColor.blue
        let planeNode = SCNNode(geometry: plane)
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        node.addChildNode(planeNode)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            cameraStateLabel.text = "Not available..."
            break
        case .normal:
            cameraStateLabel.text = "Ready to detect planes..."
            break
        case .limited(let reason):
            cameraStateLabel.text = "Limited tracking \(reason)..."
            break
        }
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
}

