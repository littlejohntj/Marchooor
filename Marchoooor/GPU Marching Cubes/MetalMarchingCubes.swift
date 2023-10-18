//
//  MetalMarchingCubes.swift
//  MarchingCubes
//
//  Created by Todd Littlejohn on 9/15/23.
//

import Foundation
import Metal

class MetalMarchingCubes {
    
    private let arrayLength: Int
    private let bufferSize: Int
    private let positionXBufferLength: Int
    private let positionCountBufferLength: Int
    
    let device: MTLDevice
    let pipelineState: MTLComputePipelineState
    let commandQueue: MTLCommandQueue
    
    var bufferEncodedInputs: MTLBuffer
    var bufferX: MTLBuffer
    var bufferY: MTLBuffer
    var bufferZ: MTLBuffer
    var bufferSeed: MTLBuffer
    var bufferEdgeTable: MTLBuffer
    var bufferEdgeTableOffsets: MTLBuffer
    var bufferEdgeTableSize: MTLBuffer
//    var bufferEdgeTableCount: MTLBuffer
    var bufferCubeDistance: MTLBuffer
    var bufferIsoLevel: MTLBuffer
    var bufferPositionsX: MTLBuffer
//    var bufferPositionsY: MTLBuffer
//    var bufferPositionsZ: MTLBuffer
    var bufferPositionCount: MTLBuffer
//    var bufferCubeIndex: MTLBuffer
//    var bufferPerlin: MTLBuffer
    
    init( device: MTLDevice, arrayLength: Int ) {
                
        let bufferSize = arrayLength * MemoryLayout<Float>.size
        let edgeTableCount = MarchingCubes.edgeTable.reduce(0) { partialResult, edges in
            return partialResult + edges.count
        }
        let edgeTableLength = MarchingCubes.edgeTable.count
        
        print(device.maxBufferLength)
        print(arrayLength * 20 * MemoryLayout<Float32>.size)
        
        print(device.maxThreadgroupMemoryLength)
        print(device.maxArgumentBufferSamplerCount)
        print(device.recommendedMaxWorkingSetSize)
        
//        print(MemoryLayout<Float32>.size * 41 * 41 * 41)
        
        self.positionCountBufferLength = arrayLength * MemoryLayout<Int32>.size
        self.positionXBufferLength = arrayLength * 20 * MemoryLayout<Float32>.size
        
        guard let defaultLibrary = device.makeDefaultLibrary() else { fatalError() }
        guard let computeCubeFunction = defaultLibrary.makeFunction(name: "compute_cube") else { fatalError() }
        self.pipelineState = try! device.makeComputePipelineState(function: computeCubeFunction)
        guard let commandQueue = device.makeCommandQueue() else { fatalError() }
        self.commandQueue = commandQueue
        self.bufferEncodedInputs = device.makeBuffer(length: MemoryLayout<Int32>.size * arrayLength, options: .storageModeShared)!
        self.bufferX = device.makeBuffer(length: MemoryLayout<Float32>.size * arrayLength, options: .storageModeShared)!
        self.bufferY = device.makeBuffer(length: MemoryLayout<Float32>.size * arrayLength, options: .storageModeShared)!
        self.bufferZ = device.makeBuffer(length: MemoryLayout<Float32>.size * arrayLength, options: .storageModeShared)!
        self.bufferSeed = device.makeBuffer(length: 512 * MemoryLayout<Int32>.size, options: .storageModeShared)!
        self.bufferEdgeTable = device.makeBuffer(length: edgeTableCount * MemoryLayout<Int32>.size, options: .storageModeShared)!
        self.bufferEdgeTableOffsets = device.makeBuffer(length: edgeTableLength * MemoryLayout<Int32>.size, options: .storageModeShared)!
        self.bufferEdgeTableSize = device.makeBuffer(length: edgeTableLength * MemoryLayout<Int32>.size, options: .storageModeShared)!
        self.bufferCubeDistance = device.makeBuffer(length: MemoryLayout<Float32>.size, options: .storageModeShared)!
        self.bufferIsoLevel = device.makeBuffer(length: MemoryLayout<Float32>.size, options: .storageModeShared)!
        self.bufferPositionsX = device.makeBuffer(length: arrayLength * 20 * MemoryLayout<Float32>.size, options: .storageModeShared)!
        self.bufferPositionCount = device.makeBuffer(length: arrayLength * MemoryLayout<Int32>.size , options: .storageModeShared)!

//        self.bufferPositionsY = device.makeBuffer(length: arrayLength * 20 * MemoryLayout<Float32>.size, options: .storageModeShared)!
//        self.bufferPositionsZ = device.makeBuffer(length: arrayLength * 20 * MemoryLayout<Float32>.size, options: .storageModeShared)!
//        self.bufferCubeIndex = device.makeBuffer(length: arrayLength * MemoryLayout<Int32>.size , options: .storageModeShared)!
//        self.bufferPerlin = device.makeBuffer(length: arrayLength * MemoryLayout<Float32>.size, options: .storageModeShared)!
        
        self.device = device
        self.arrayLength = arrayLength
        self.bufferSize = bufferSize
        
    }
        
    func generateRandomFloat( buffer: inout MTLBuffer ) {
        let dataPtr = buffer.contents()
        dataPtr.storeBytes(of: Float.random(in: 0...20), as: Float.self)
    }
    
    func setData( cubeDistance: Float, isoLevel: Float, units: Int ) {
        
        let bufferEncodedInputsPtr = self.bufferEncodedInputs.contents()
        let bufferXPtr = self.bufferX.contents()
        let bufferYPtr = self.bufferY.contents()
        let bufferZPtr = self.bufferZ.contents()
        let cubeDistancePtr = self.bufferCubeDistance.contents()
        let isoLevelPtr = self.bufferIsoLevel.contents()
        
        
        let intLen: Int = MemoryLayout<Int32>.size
        let floatLen: Int = MemoryLayout<Float32>.size
        
        func encode(x: Int, y: Int, z: Int) -> Int {
            let encodedValue = x * 1000000 + y * 1000 + z
            return encodedValue
        }
                
        for x in 0...units {
            for y in 0...units {
                for z in 0...units {
                    bufferEncodedInputsPtr.storeBytes(of: Int32( encode(x: x, y: y, z: z) ), toByteOffset: ( ( x * ( units + 1 ) * ( units + 1 ) ) + ( y * ( units + 1 ) ) + z ) * intLen, as: Int32.self)
                    bufferXPtr.storeBytes(of: Float32(x), toByteOffset: ( ( x * ( units + 1 ) * ( units + 1 ) ) + ( y * ( units + 1 ) ) + z ) * floatLen, as: Float32.self)
                    bufferYPtr.storeBytes(of: Float32(y) , toByteOffset: ( ( x * ( units + 1 ) * ( units + 1 ) ) + ( y * ( units + 1 ) ) + z ) * floatLen, as: Float32.self)
                    bufferZPtr.storeBytes(of: Float32(z) , toByteOffset: ( ( x * ( units + 1 ) * ( units + 1 ) ) + ( y * ( units + 1 ) ) + z ) * floatLen , as: Float32.self)
                }
            }
        }
        
        cubeDistancePtr.storeBytes(of: Float32(cubeDistance), as: Float32.self)
        isoLevelPtr.storeBytes(of: Float32(isoLevel), as: Float32.self)
        
    }
        
    func setSeed() {
        let dataPtr = self.bufferSeed.contents()
        let seeds = PerlinNoise.p
        let intLen = MemoryLayout<Int32>.size
        for ( index, seed ) in seeds.enumerated() {
            dataPtr.storeBytes(of: Int32(seed), toByteOffset: index * intLen, as: Int32.self)
        }
    }
    
    func setTestSeed( seeds: [Int] ) {
        let dataPtr = self.bufferSeed.contents()
        let intLen = MemoryLayout<Int32>.size
        for ( index, seed ) in seeds.enumerated() {
            dataPtr.storeBytes(of: Int32(seed), toByteOffset: index * intLen, as: Int32.self)
        }
    }
    
    func setEdgeTable() {
        
        let edgeTable = MarchingCubes.edgeTable
        let intLen = MemoryLayout<Int32>.size
        
        let edgeTablePtr = self.bufferEdgeTable.contents()
        let edgeTableOffsetsPtr = self.bufferEdgeTableOffsets.contents()
        let edgeTableLengthPtr = self.bufferEdgeTableSize.contents()
        
        for ( index, edges ) in edgeTable.enumerated() {
            edgeTableLengthPtr.storeBytes(of: Int32(edges.count), toByteOffset: index * intLen, as: Int32.self)
        }
        
        var edgeCount: Int = 0
        for ( edgesIndex, edges ) in edgeTable.enumerated() {
            
            if edges.count == 0 {
                edgeTableOffsetsPtr.storeBytes(of: Int32(-1), toByteOffset: edgesIndex * intLen, as: Int32.self)
            } else {
                edgeTableOffsetsPtr.storeBytes(of: Int32(edgeCount), toByteOffset: edgesIndex * intLen, as: Int32.self)
            }
            
            for ( _, edge ) in edges.enumerated() {
                edgeTablePtr.storeBytes(of: Int32(edge), toByteOffset: edgeCount * intLen, as: Int32.self)
                edgeCount += 1
            }
        }
        
        let totalFlatEdgeTableSize = edgeTable.reduce(0) { partialResult, edges in
            return partialResult + edges.count
        }
        
        var flatEdgeTable: [Int32] = []
        var flatEdgeOffsets: [Int32] = []
        var flatEdgeLens: [Int32] = []
        for i in 0..<totalFlatEdgeTableSize {
            flatEdgeTable.append( self.bufferEdgeTable.contents().load(fromByteOffset: i * intLen, as: Int32.self) )
        }
        
        for j in 0..<edgeTable.count {
            flatEdgeOffsets.append( self.bufferEdgeTableOffsets.contents().load(fromByteOffset: j * intLen, as: Int32.self) )
            flatEdgeLens.append( self.bufferEdgeTableSize.contents().load(fromByteOffset: j * intLen, as: Int32.self) )
        }
                
    }
    
    func sendComputeCommand() {
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { fatalError() }
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else { fatalError() }
        self.encoderAddCommand(encoder: computeEncoder)
        computeEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    
    }
    
    func encoderAddCommand( encoder: MTLComputeCommandEncoder ) {
        
        encoder.setComputePipelineState(pipelineState)
        encoder.setBuffer(bufferEncodedInputs, offset: 0, index: 0)
        encoder.setBuffer(bufferX, offset: 0, index: 1)
        encoder.setBuffer(bufferY, offset: 0, index: 2)
        encoder.setBuffer(bufferZ, offset: 0, index: 3)
        encoder.setBuffer(bufferSeed, offset: 0, index: 4)
        encoder.setBuffer(bufferEdgeTable, offset: 0, index: 5)
        encoder.setBuffer(bufferEdgeTableOffsets, offset: 0, index: 6)
        encoder.setBuffer(bufferEdgeTableSize, offset: 0, index: 7)
        encoder.setBuffer(bufferCubeDistance, offset: 0, index: 8)
        encoder.setBuffer(bufferIsoLevel, offset: 0, index: 9)
        encoder.setBuffer(bufferPositionsX, offset: 0, index: 10)
        encoder.setBuffer(bufferPositionCount, offset: 0, index: 11)
        
        let gridSize = MTLSize(width: arrayLength, height: 1, depth: 1)
        var threadGroupSize = pipelineState.maxTotalThreadsPerThreadgroup
        if threadGroupSize > arrayLength {
            threadGroupSize = arrayLength
        }
        let threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);
        encoder.dispatchThreadgroups(gridSize, threadsPerThreadgroup: threadgroupSize)
        
    }
        
    func getResults() -> [SIMD3<Float>] {
        
        var positions: [SIMD3<Float>] = []
//        let intLen: Int = MemoryLayout<Int32>.size
//        let floatLen: Int  = MemoryLayout<Float32>.size
//        let resultsBufferPtr = resultBuffer.contents()
//        let positionCounts = (0..<positionCountBufferLength).map { index in
//            return resultsBufferPtr.load(fromByteOffset: index * intLen, as: Int32.self)
//        }
                
//        for ( index, count ) in positionCounts.enumerated() {
//            
//            if ( count != 0 ) {
//                
//                for i in 0..<count {
//                    let gpuXposition = bufferPositionXPtr.load(fromByteOffset: ( ( 20 * index ) + Int(i) ) * MemoryLayout<Float32>.size , as: Float32.self)
//                    let gpuYposition = bufferPositionYPtr.load(fromByteOffset: ( ( 20 * index ) + Int(i) ) * MemoryLayout<Float32>.size , as: Float32.self)
//                    let gpuZposition = bufferPositionZPtr.load(fromByteOffset: ( ( 20 * index ) + Int(i) ) * MemoryLayout<Float32>.size , as: Float32.self)
//                    positions.append([gpuXposition, gpuYposition, gpuZposition])
//                }
//                
//            }
//            
//            
//            
//        }
        
        return positions
    }
    
    func getPerlin() -> [Float32] {
        
//        let floatLen: Int = MemoryLayout<Float32>.size
//
//        let perlinPtr = bufferPerlin.contents()
//
//        let perlinValues = (0..<(arrayLength)).map { index in
//            return perlinPtr.load(fromByteOffset: index * floatLen, as: Float32.self)
//        }
        
//        var perlins: [Float32] = []
        
//        for i in 0..<arrayLength {
//            perlins.append(perlinPtr.load(fromByteOffset: i * MemoryLayout<Float32>.size, as: Float32.self))
//        }
        
//        let perlin = (0..<arrayLength).map { index in
//            return
//        }
        
        return []
        
    }

    
    func getPositionCounts() -> [Int32] {
        
        let intLen: Int = MemoryLayout<Int32>.size
        let positionCountBufferPtr = bufferPositionCount.contents()
        let positionCounts = (0..<arrayLength).map { index in
            return positionCountBufferPtr.load(fromByteOffset: index * intLen, as: Int32.self)
        }
                
        return positionCounts
        
    }
    

    
}
