//
//  MarchingCubesTester.swift
//  Marchoooor
//
//  Created by Todd Littlejohn on 10/2/23.
//

import Foundation
import RealityKit

struct MarchingCubesTester {
    
    var cubeDistance: Float = 0.2
    var isoLevel: Float = -0.2
    var units: Int = 30
    var influences: [TerrainInfluence] = []
    var seeds: [Int] = MarchingCubes.testSeeds

    let gpuMarchingCubes: GPUMarchingCubes
    let cpuMarchingCubes: CPUMarchingCubes
    
    init() {
        self.gpuMarchingCubes = GPUMarchingCubes(
            cubeDistance: cubeDistance,
            isoLevel: isoLevel,
            units: units,
            seeds: seeds, 
            influences: influences
        )
        self.cpuMarchingCubes = CPUMarchingCubes(
            cubeDistance: cubeDistance,
            isoLevel: isoLevel,
            units: units,
            seed: seeds
        )
    }
    
    mutating func updateIsoLevel( newValue: Float ) {
        self.isoLevel = newValue
        self.gpuMarchingCubes.setData(cubeDistance: cubeDistance, isoLevel: isoLevel, units: units, influences: influences)
    }
    
    mutating func setTerrainInfluences( influences: [TerrainInfluence] ) {
        self.influences = influences
        self.gpuMarchingCubes.setData(cubeDistance: cubeDistance, isoLevel: isoLevel, units: units, influences: influences)
    }
    
    func createMeshResource() -> MeshResource {
        
        let results = gpuMarchingCubes.getPositions()
        
        let indicies: [UInt32] = Array(0..<results.count).map { indicie in
            UInt32(indicie)
        }
        var meshDescriptor = MeshDescriptor()
        meshDescriptor.positions = .init( results )
        meshDescriptor.primitives = .triangles(indicies)
        
        let mesh = try! MeshResource.generate(from: [meshDescriptor])
        return mesh
        
    }
    
}
