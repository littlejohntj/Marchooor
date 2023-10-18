//
//  MetalTesting.swift
//  Marchoooor
//
//  Created by Todd Littlejohn on 10/6/23.
//

import Foundation
import Metal

class MetalTesting {
    
    let device: MTLDevice
    let pipelineState: MTLComputePipelineState
    let commandQueue: MTLCommandQueue

    init( device: MTLDevice, arrayLength: Int ) {
        
        guard let defaultLibrary = device.makeDefaultLibrary() else { fatalError() }
        guard let computeCubeFunction = defaultLibrary.makeFunction(name: "test_grad") else { fatalError() }
        self.pipelineState = try! device.makeComputePipelineState(function: computeCubeFunction)
        guard let commandQueue = device.makeCommandQueue() else { fatalError() }
        self.commandQueue = commandQueue
        self.device = device
        
    }
    
}
