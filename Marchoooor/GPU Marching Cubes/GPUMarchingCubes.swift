//
//  MarchingCubesManager.swift
//  MarchingCubes
//
//  Created by Todd Littlejohn on 9/15/23.
//

import Foundation
import RealityKit
import Combine
import Metal

enum MarchingCubesTest {
    case counts
}

class GPUMarchingCubes: ObservableObject {
    
    let metalMarchingCubes: MetalMarchingCubes
    
    init( cubeDistance: Float, isoLevel: Float, units: Int, seeds: [Int], influences: [TerrainInfluence] ) {
        if let device = MTLCreateSystemDefaultDevice() {
            metalMarchingCubes = MetalMarchingCubes(device: device, arrayLength: ( units + 1 ) * ( units + 1 ) * ( units + 1 ) )
            metalMarchingCubes.setTestSeed(seeds: seeds)
            metalMarchingCubes.setEdgeTable()
            metalMarchingCubes.setData(cubeDistance: cubeDistance, isoLevel: isoLevel, units: units, influences: influences)
        } else {
            fatalError()
        }
    }
    
    func setData( cubeDistance: Float, isoLevel: Float, units: Int, influences: [TerrainInfluence] = [] ) {
        metalMarchingCubes.setData(cubeDistance: cubeDistance, isoLevel: isoLevel, units: units, influences: influences)
    }
    
    func getPositions() -> [SIMD3<Float>] {
        metalMarchingCubes.sendComputeCommand()
        return metalMarchingCubes.getResults()
    }
    
    func getPositionCounts() -> [Int32] {
        metalMarchingCubes.sendComputeCommand()
        return metalMarchingCubes.getPositionCounts()
    }
    
    func getPerlin() -> [Float32] {
        metalMarchingCubes.sendComputeCommand()
        return metalMarchingCubes.getPerlin()
    }
    
}
