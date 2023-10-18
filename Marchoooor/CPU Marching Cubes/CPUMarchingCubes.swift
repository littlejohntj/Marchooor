//
//  CPUMarchingCubes.swift
//  Marchoooor
//
//  Created by Todd Littlejohn on 10/6/23.
//

import Foundation

struct CPUMarchingCubes {
    
    let cubeDistance: Float
    let isoLevel: Float
    let units: Int
    let seed: [Int]
    
    var perlinHash: [ SIMD3<Float> : Float ] = [:]
    
    func getPositionCounts() -> [Int32] {
        
        let marchingCubesData = getAllMarchingCubesData()
        return marchingCubesData.2
        
    }
    
    func getPerlins() -> [Float] {
        
        let marchingCubesData = getAllMarchingCubesData()
        return marchingCubesData.3
        
    }
    
    func getEncodedIndexs() -> [Int32] {
        
        var encodedIndexs: [Int32] = []
        
        func encode(x: Int, y: Int, z: Int) -> Int {
            let encodedValue = x * 1000000 + y * 1000 + z
            return encodedValue
        }
        
        for x in 0...units {
            for y in 0...units {
                for z in 0...units {
                    let encodedIndex = Int32( encode(x: x, y: y, z: z) )
                    encodedIndexs.append(encodedIndex)
                }
            }
        }
        
        return encodedIndexs
    }
    
    func getPositionCounts( at encodedIndex: Int32 ) -> Int {
        
        let marchingCubesData = CPUMarchingCubes.computeCube(encodedIndex: encodedIndex, cubeDistance: cubeDistance, isoLevel: isoLevel, seed: seed)
        return marchingCubesData.1
        
    }
    
    func getPerlins( at encodedIndex: Int32 ) -> Int {
        
        let marchingCubesData = CPUMarchingCubes.computeCube(encodedIndex: encodedIndex, cubeDistance: cubeDistance, isoLevel: isoLevel, seed: seed)
        return marchingCubesData.1
        
    }
    
    func getAllMarchingCubesData() -> ( [Int32], [SIMD3<Float>], [Int32], [Float32] ) {

        var indicies: [UInt32] = []
        var positions: [SIMD3<Float>] = []
        var positionCounts: [Int32] = []
        var cubeIndexes: [Int32] = []
        var perlins: [Float32] = []

        //        for _ in 0...units {
        //            for _ in 0...units {
        //                for _ in 0...units {
        //                    positionCounts.append(0)
        //                }
        //            }
        //        }

        for x in 0...units {
            for y in 0...units {
                for z in 0...units {

//                    let xIndex = x * units * units
//                    let yIndex = y * units
//                    let zIndex = z
//                    let index = xIndex + yIndex + zIndex
                    
                    func encode(x: Int, y: Int, z: Int) -> Int {
                        let encodedValue = x * 1000000 + y * 1000 + z
                        return encodedValue
                    }
                    
                    let encodedIndex = encode(x: x, y: y, z: z)
                    
                    let newPositions = CPUMarchingCubes.computeCube(encodedIndex: Int32(encodedIndex), cubeDistance: cubeDistance, isoLevel: isoLevel, seed: seed)
                    positionCounts.append(Int32(newPositions.0.count))
                    positions.append(contentsOf: newPositions.0)
                    cubeIndexes.append(Int32(newPositions.1))
                    perlins.append(newPositions.2)

                }
            }
        }

        return ( positionCounts, positions, cubeIndexes, perlins )

    }
    
    static func computeCube( encodedIndex: Int32, cubeDistance: Float, isoLevel: Float, seed: [Int] ) -> ([SIMD3<Float>], Int, Float) {

        var positions: [SIMD3<Float>] = []
        var perlins: Float32 = 0
        
//        int x = encodedIndex / 1000000;
//        int y = (encodedIndex % 1000000) / 1000;
//        int z = encodedIndex % 1000;
        let x = encodedIndex / 1000000
        let y = (encodedIndex % 1000000) / 1000
        let z = encodedIndex % 1000

        let startingX = Float(x) * cubeDistance
        let startingY = Float(y) * cubeDistance
        let startingZ = Float(z) * cubeDistance


        let startingPosition: SIMD3<Float> = [ startingX, startingY, startingZ ]

        var vertexes: [Int] = []
        for ( index, cornerPosition ) in MarchingCubes.cornerPositions.enumerated() {

            let vertexPosition = startingPosition + ( cornerPosition * cubeDistance )

            let noiseValue: Float = PerlinNoise.perlin( vertexPosition.x, vertexPosition.y, vertexPosition.z, seed: seed)

//            per = per + noiseValue
            perlins = Float(x)

            if ( noiseValue > isoLevel ) {
                vertexes.append(index)
            }

        }

        var cubeIndex: Int = 0

        for vertex in vertexes {
            cubeIndex = cubeIndex | 1 << vertex
        }

        let edges = MarchingCubes.edgeTable[ cubeIndex ]

        for edge in edges {

            // Get the corner positions that contain the edge
            let vertex1Pos = startingPosition + (MarchingCubes.cornerPositions[MarchingCubes.edgeIndicies[edge][0]] * cubeDistance)
            let vertex2Pos = startingPosition + (MarchingCubes.cornerPositions[MarchingCubes.edgeIndicies[edge][1]] * cubeDistance)

            let vertex1Value = PerlinNoise.perlin(vertex1Pos.x, vertex1Pos.y, vertex1Pos.z, seed: seed)
            let vertex2Value = PerlinNoise.perlin(vertex2Pos.x, vertex2Pos.y, vertex2Pos.z, seed: seed)

            let t = ( isoLevel - vertex1Value) / (vertex2Value - vertex1Value)
            let interpolatedPos = vertex1Pos + t * (vertex2Pos - vertex1Pos)

            positions.append(interpolatedPos)
            
        }

        return ( positions, cubeIndex, perlins )

    }


}
