//
//  MarchingCubesTester.swift
//  Marchoooor
//
//  Created by Todd Littlejohn on 10/2/23.
//

import Foundation

struct MarchingCubesTester {
    
    let cubeDistance: Float = 0.1
    let isoLevel: Float = 0.2
    let units: Int = 20
    let seeds: [Int] = MarchingCubes.testSeeds

    let gpuMarchingCubes: GPUMarchingCubes
    let cpuMarchingCubes: CPUMarchingCubes
    
    init() {
        self.gpuMarchingCubes = GPUMarchingCubes(
            cubeDistance: cubeDistance,
            isoLevel: isoLevel,
            units: units,
            seeds: seeds
        )
        self.cpuMarchingCubes = CPUMarchingCubes(
            cubeDistance: cubeDistance,
            isoLevel: isoLevel,
            units: units,
            seed: seeds
        )
    }
    
}
