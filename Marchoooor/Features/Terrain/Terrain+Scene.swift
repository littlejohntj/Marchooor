//
//  Terrain+Scene.swift
//  Marchoooor
//
//  Created by Todd Littlejohn on 10/20/23.
//

import RealityKit
import ARKit

extension Scene {
    // Add an anchor and remove it from the scene after the specified number of seconds.
/// - Tag: AddAnchorExtension
    func addAnchor(_ anchor: HasAnchoring, removeAfter seconds: TimeInterval) {
        guard let model = anchor.children.first as? HasPhysics else {
            return
        }
        
        // Set up model to participate in physics simulation
        if model.collision == nil {
            model.generateCollisionShapes(recursive: true)
            model.physicsBody = .init()
        }
        // ... but prevent it from being affected by simulation forces for now.
        model.physicsBody?.mode = .kinematic
        
        addAnchor(anchor)
        // Making the physics body dynamic at this time will let the model be affected by forces.
        Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { (timer) in
            model.physicsBody?.mode = .dynamic
        }
        Timer.scheduledTimer(withTimeInterval: seconds + 3, repeats: false) { (timer) in
            self.removeAnchor(anchor)
        }
    }
}

