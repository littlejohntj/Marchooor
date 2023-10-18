//
//  MetalSystem.swift
//  MarchingCubes
//
//  Created by Todd Littlejohn on 9/15/23.
//

import Foundation
import RealityKit
import Metal

class MetalSystem: System {

    private static let metalQuery = EntityQuery(where: .has(MetalComponent.self) )
//    private let metalMarchingCubes: MetalMarchingCubes

    required init(scene: Scene) {
        
//        if let device = MTLCreateSystemDefaultDevice() {
//            metalMarchingCubes = MetalMarchingCubes(device: device)
//            metalMarchingCubes.setSeed()
//            metalMarchingCubes.setEdgeTable()
//            metalMarchingCubes.setData(cubeDistance: 0.1, isoLevel: 0.2, units: 10)
//        } else {
//            fatalError()
//        }
        
    }
    
    func update(context: SceneUpdateContext) {
        
        context.scene.performQuery(Self.metalQuery).forEach { entity in
            
//            metalMarchingCubes.sendComputeCommand()
            
        }
        
    }
    
    
}
