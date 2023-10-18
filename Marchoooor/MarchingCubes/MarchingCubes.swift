//
//  TriangleTable.swift
//  MarchingCubes
//
//  Created by Todd Littlejohn on 9/8/23.
//

import Foundation

struct MarchingCubes {
    
    static let cornerPositions: [SIMD3<Float>] = [
        [0, 0, 0],
        [1, 0, 0],
        [0, 1, 0],
        [1, 1, 0],
        [0, 0, 1],
        [1, 0, 1],
        [0, 1, 1],
        [1, 1, 1]
    ]
    
    static var midpointPositions: [SIMD3<Float>] {
        var midpoints: [SIMD3<Float>] = []
        for i in 0...edgeIndicies.count - 1 {
            midpoints.append( edgeMidpoint(edgeIndex: i) )
        }
        return midpoints
    }
    
    static func edgeMidpoint( edgeIndex: Int ) -> SIMD3<Float> {
        let firstCornerIndex = edgeIndicies[edgeIndex][0]
        let secondCornerIndex = edgeIndicies[edgeIndex][1]
        let firstCornerPosition = MarchingCubes.cornerPositions[ firstCornerIndex ]
        let secondCornerPosition = MarchingCubes.cornerPositions[ secondCornerIndex ]
        let midpoint = ( firstCornerPosition + secondCornerPosition ) / 2
        return midpoint
    }
    
    // Scale should only be a value between 0 and 1
    static func edgeScalePoint( edgeIndex: Int, scale: Float ) -> SIMD3<Float> {
        
        if scale < 0 || scale > 1 {
            fatalError()
        }
        
        let firstCornerIndex = edgeIndicies[edgeIndex][0]
        let secondCornerIndex = edgeIndicies[edgeIndex][1]
        let firstCornerPosition = MarchingCubes.cornerPositions[ firstCornerIndex ]
        let secondCornerPosition = MarchingCubes.cornerPositions[ secondCornerIndex ]
        let midpoint = ( firstCornerPosition + secondCornerPosition ) * scale
        return midpoint
    }
    
    static let edgeIndicies = [
        [0, 1],
        [1, 3],
        [2, 3],
        [0, 2],
        [4, 5],
        [5, 7],
        [6, 7],
        [4, 6],
        [0, 4],
        [1, 5],
        [3, 7],
        [2, 6],
    ];
    
    static private let largeEdgeTable = [
        [ -1 ],
        [ 0, 3, 8, -1 ],
        [ 0, 9, 1, -1 ],
        [ 3, 8, 1, 1, 8, 9, -1 ],
        [ 2, 11, 3, -1 ],
        [ 8, 0, 11, 11, 0, 2, -1 ],
        [ 3, 2, 11, 1, 0, 9, -1 ],
        [ 11, 1, 2, 11, 9, 1, 11, 8, 9, -1 ],
        [ 1, 10, 2, -1 ],
        [ 0, 3, 8, 2, 1, 10, -1 ],
        [ 10, 2, 9, 9, 2, 0, -1 ],
        [ 8, 2, 3, 8, 10, 2, 8, 9, 10, -1 ],
        [ 11, 3, 10, 10, 3, 1, -1 ],
        [ 10, 0, 1, 10, 8, 0, 10, 11, 8, -1 ],
        [ 9, 3, 0, 9, 11, 3, 9, 10, 11, -1 ],
        [ 8, 9, 11, 11, 9, 10, -1 ],
        [ 4, 8, 7, -1 ],
        [ 7, 4, 3, 3, 4, 0, -1 ],
        [ 4, 8, 7, 0, 9, 1, -1 ],
        [ 1, 4, 9, 1, 7, 4, 1, 3, 7, -1 ],
        [ 8, 7, 4, 11, 3, 2, -1 ],
        [ 4, 11, 7, 4, 2, 11, 4, 0, 2, -1 ],
        [ 0, 9, 1, 8, 7, 4, 11, 3, 2, -1 ],
        [ 7, 4, 11, 11, 4, 2, 2, 4, 9, 2, 9, 1, -1 ],
        [ 4, 8, 7, 2, 1, 10, -1 ],
        [ 7, 4, 3, 3, 4, 0, 10, 2, 1, -1 ],
        [ 10, 2, 9, 9, 2, 0, 7, 4, 8, -1 ],
        [ 10, 2, 3, 10, 3, 4, 3, 7, 4, 9, 10, 4, -1 ],
        [ 1, 10, 3, 3, 10, 11, 4, 8, 7, -1 ],
        [ 10, 11, 1, 11, 7, 4, 1, 11, 4, 1, 4, 0, -1 ],
        [ 7, 4, 8, 9, 3, 0, 9, 11, 3, 9, 10, 11, -1 ],
        [ 7, 4, 11, 4, 9, 11, 9, 10, 11, -1 ],
        [ 9, 4, 5, -1 ],
        [ 9, 4, 5, 8, 0, 3, -1 ],
        [ 4, 5, 0, 0, 5, 1, -1 ],
        [ 5, 8, 4, 5, 3, 8, 5, 1, 3, -1 ],
        [ 9, 4, 5, 11, 3, 2, -1 ],
        [ 2, 11, 0, 0, 11, 8, 5, 9, 4, -1 ],
        [ 4, 5, 0, 0, 5, 1, 11, 3, 2, -1 ],
        [ 5, 1, 4, 1, 2, 11, 4, 1, 11, 4, 11, 8, -1 ],
        [ 1, 10, 2, 5, 9, 4, -1 ],
        [ 9, 4, 5, 0, 3, 8, 2, 1, 10, -1 ],
        [ 2, 5, 10, 2, 4, 5, 2, 0, 4, -1 ],
        [ 10, 2, 5, 5, 2, 4, 4, 2, 3, 4, 3, 8, -1 ],
        [ 11, 3, 10, 10, 3, 1, 4, 5, 9, -1 ],
        [ 4, 5, 9, 10, 0, 1, 10, 8, 0, 10, 11, 8, -1 ],
        [ 11, 3, 0, 11, 0, 5, 0, 4, 5, 10, 11, 5, -1 ],
        [ 4, 5, 8, 5, 10, 8, 10, 11, 8, -1 ],
        [ 8, 7, 9, 9, 7, 5, -1 ],
        [ 3, 9, 0, 3, 5, 9, 3, 7, 5, -1 ],
        [ 7, 0, 8, 7, 1, 0, 7, 5, 1, -1 ],
        [ 7, 5, 3, 3, 5, 1, -1 ],
        [ 5, 9, 7, 7, 9, 8, 2, 11, 3, -1 ],
        [ 2, 11, 7, 2, 7, 9, 7, 5, 9, 0, 2, 9, -1 ],
        [ 2, 11, 3, 7, 0, 8, 7, 1, 0, 7, 5, 1, -1 ],
        [ 2, 11, 1, 11, 7, 1, 7, 5, 1, -1 ],
        [ 8, 7, 9, 9, 7, 5, 2, 1, 10, -1 ],
        [ 10, 2, 1, 3, 9, 0, 3, 5, 9, 3, 7, 5, -1 ],
        [ 7, 5, 8, 5, 10, 2, 8, 5, 2, 8, 2, 0, -1 ],
        [ 10, 2, 5, 2, 3, 5, 3, 7, 5, -1 ],
        [ 8, 7, 5, 8, 5, 9, 11, 3, 10, 3, 1, 10, -1 ],
        [ 5, 11, 7, 10, 11, 5, 1, 9, 0, -1 ],
        [ 11, 5, 10, 7, 5, 11, 8, 3, 0, -1 ],
        [ 5, 11, 7, 10, 11, 5, -1 ],
        [ 6, 7, 11, -1 ],
        [ 7, 11, 6, 3, 8, 0, -1 ],
        [ 6, 7, 11, 0, 9, 1, -1 ],
        [ 9, 1, 8, 8, 1, 3, 6, 7, 11, -1 ],
        [ 3, 2, 7, 7, 2, 6, -1 ],
        [ 0, 7, 8, 0, 6, 7, 0, 2, 6, -1 ],
        [ 6, 7, 2, 2, 7, 3, 9, 1, 0, -1 ],
        [ 6, 7, 8, 6, 8, 1, 8, 9, 1, 2, 6, 1, -1 ],
        [ 11, 6, 7, 10, 2, 1, -1 ],
        [ 3, 8, 0, 11, 6, 7, 10, 2, 1, -1 ],
        [ 0, 9, 2, 2, 9, 10, 7, 11, 6, -1 ],
        [ 6, 7, 11, 8, 2, 3, 8, 10, 2, 8, 9, 10, -1 ],
        [ 7, 10, 6, 7, 1, 10, 7, 3, 1, -1 ],
        [ 8, 0, 7, 7, 0, 6, 6, 0, 1, 6, 1, 10, -1 ],
        [ 7, 3, 6, 3, 0, 9, 6, 3, 9, 6, 9, 10, -1 ],
        [ 6, 7, 10, 7, 8, 10, 8, 9, 10, -1 ],
        [ 11, 6, 8, 8, 6, 4, -1 ],
        [ 6, 3, 11, 6, 0, 3, 6, 4, 0, -1 ],
        [ 11, 6, 8, 8, 6, 4, 1, 0, 9, -1 ],
        [ 1, 3, 9, 3, 11, 6, 9, 3, 6, 9, 6, 4, -1 ],
        [ 2, 8, 3, 2, 4, 8, 2, 6, 4, -1 ],
        [ 4, 0, 6, 6, 0, 2, -1 ],
        [ 9, 1, 0, 2, 8, 3, 2, 4, 8, 2, 6, 4, -1 ],
        [ 9, 1, 4, 1, 2, 4, 2, 6, 4, -1 ],
        [ 4, 8, 6, 6, 8, 11, 1, 10, 2, -1 ],
        [ 1, 10, 2, 6, 3, 11, 6, 0, 3, 6, 4, 0, -1 ],
        [ 11, 6, 4, 11, 4, 8, 10, 2, 9, 2, 0, 9, -1 ],
        [ 10, 4, 9, 6, 4, 10, 11, 2, 3, -1 ],
        [ 4, 8, 3, 4, 3, 10, 3, 1, 10, 6, 4, 10, -1 ],
        [ 1, 10, 0, 10, 6, 0, 6, 4, 0, -1 ],
        [ 4, 10, 6, 9, 10, 4, 0, 8, 3, -1 ],
        [ 4, 10, 6, 9, 10, 4, -1 ],
        [ 6, 7, 11, 4, 5, 9, -1 ],
        [ 4, 5, 9, 7, 11, 6, 3, 8, 0, -1 ],
        [ 1, 0, 5, 5, 0, 4, 11, 6, 7, -1 ],
        [ 11, 6, 7, 5, 8, 4, 5, 3, 8, 5, 1, 3, -1 ],
        [ 3, 2, 7, 7, 2, 6, 9, 4, 5, -1 ],
        [ 5, 9, 4, 0, 7, 8, 0, 6, 7, 0, 2, 6, -1 ],
        [ 3, 2, 6, 3, 6, 7, 1, 0, 5, 0, 4, 5, -1 ],
        [ 6, 1, 2, 5, 1, 6, 4, 7, 8, -1 ],
        [ 10, 2, 1, 6, 7, 11, 4, 5, 9, -1 ],
        [ 0, 3, 8, 4, 5, 9, 11, 6, 7, 10, 2, 1, -1 ],
        [ 7, 11, 6, 2, 5, 10, 2, 4, 5, 2, 0, 4, -1 ],
        [ 8, 4, 7, 5, 10, 6, 3, 11, 2, -1 ],
        [ 9, 4, 5, 7, 10, 6, 7, 1, 10, 7, 3, 1, -1 ],
        [ 10, 6, 5, 7, 8, 4, 1, 9, 0, -1 ],
        [ 4, 3, 0, 7, 3, 4, 6, 5, 10, -1 ],
        [ 10, 6, 5, 8, 4, 7, -1 ],
        [ 9, 6, 5, 9, 11, 6, 9, 8, 11, -1 ],
        [ 11, 6, 3, 3, 6, 0, 0, 6, 5, 0, 5, 9, -1 ],
        [ 11, 6, 5, 11, 5, 0, 5, 1, 0, 8, 11, 0, -1 ],
        [ 11, 6, 3, 6, 5, 3, 5, 1, 3, -1 ],
        [ 9, 8, 5, 8, 3, 2, 5, 8, 2, 5, 2, 6, -1 ],
        [ 5, 9, 6, 9, 0, 6, 0, 2, 6, -1 ],
        [ 1, 6, 5, 2, 6, 1, 3, 0, 8, -1 ],
        [ 1, 6, 5, 2, 6, 1, -1 ],
        [ 2, 1, 10, 9, 6, 5, 9, 11, 6, 9, 8, 11, -1 ],
        [ 9, 0, 1, 3, 11, 2, 5, 10, 6, -1 ],
        [ 11, 0, 8, 2, 0, 11, 10, 6, 5, -1 ],
        [ 3, 11, 2, 5, 10, 6, -1 ],
        [ 1, 8, 3, 9, 8, 1, 5, 10, 6, -1 ],
        [ 6, 5, 10, 0, 1, 9, -1 ],
        [ 8, 3, 0, 5, 10, 6, -1 ],
        [ 6, 5, 10, -1 ],
        [ 10, 5, 6, -1 ],
        [ 0, 3, 8, 6, 10, 5, -1 ],
        [ 10, 5, 6, 9, 1, 0, -1 ],
        [ 3, 8, 1, 1, 8, 9, 6, 10, 5, -1 ],
        [ 2, 11, 3, 6, 10, 5, -1 ],
        [ 8, 0, 11, 11, 0, 2, 5, 6, 10, -1 ],
        [ 1, 0, 9, 2, 11, 3, 6, 10, 5, -1 ],
        [ 5, 6, 10, 11, 1, 2, 11, 9, 1, 11, 8, 9, -1 ],
        [ 5, 6, 1, 1, 6, 2, -1 ],
        [ 5, 6, 1, 1, 6, 2, 8, 0, 3, -1 ],
        [ 6, 9, 5, 6, 0, 9, 6, 2, 0, -1 ],
        [ 6, 2, 5, 2, 3, 8, 5, 2, 8, 5, 8, 9, -1 ],
        [ 3, 6, 11, 3, 5, 6, 3, 1, 5, -1 ],
        [ 8, 0, 1, 8, 1, 6, 1, 5, 6, 11, 8, 6, -1 ],
        [ 11, 3, 6, 6, 3, 5, 5, 3, 0, 5, 0, 9, -1 ],
        [ 5, 6, 9, 6, 11, 9, 11, 8, 9, -1 ],
        [ 5, 6, 10, 7, 4, 8, -1 ],
        [ 0, 3, 4, 4, 3, 7, 10, 5, 6, -1 ],
        [ 5, 6, 10, 4, 8, 7, 0, 9, 1, -1 ],
        [ 6, 10, 5, 1, 4, 9, 1, 7, 4, 1, 3, 7, -1 ],
        [ 7, 4, 8, 6, 10, 5, 2, 11, 3, -1 ],
        [ 10, 5, 6, 4, 11, 7, 4, 2, 11, 4, 0, 2, -1 ],
        [ 4, 8, 7, 6, 10, 5, 3, 2, 11, 1, 0, 9, -1 ],
        [ 1, 2, 10, 11, 7, 6, 9, 5, 4, -1 ],
        [ 2, 1, 6, 6, 1, 5, 8, 7, 4, -1 ],
        [ 0, 3, 7, 0, 7, 4, 2, 1, 6, 1, 5, 6, -1 ],
        [ 8, 7, 4, 6, 9, 5, 6, 0, 9, 6, 2, 0, -1 ],
        [ 7, 2, 3, 6, 2, 7, 5, 4, 9, -1 ],
        [ 4, 8, 7, 3, 6, 11, 3, 5, 6, 3, 1, 5, -1 ],
        [ 5, 0, 1, 4, 0, 5, 7, 6, 11, -1 ],
        [ 9, 5, 4, 6, 11, 7, 0, 8, 3, -1 ],
        [ 11, 7, 6, 9, 5, 4, -1 ],
        [ 6, 10, 4, 4, 10, 9, -1 ],
        [ 6, 10, 4, 4, 10, 9, 3, 8, 0, -1 ],
        [ 0, 10, 1, 0, 6, 10, 0, 4, 6, -1 ],
        [ 6, 10, 1, 6, 1, 8, 1, 3, 8, 4, 6, 8, -1 ],
        [ 9, 4, 10, 10, 4, 6, 3, 2, 11, -1 ],
        [ 2, 11, 8, 2, 8, 0, 6, 10, 4, 10, 9, 4, -1 ],
        [ 11, 3, 2, 0, 10, 1, 0, 6, 10, 0, 4, 6, -1 ],
        [ 6, 8, 4, 11, 8, 6, 2, 10, 1, -1 ],
        [ 4, 1, 9, 4, 2, 1, 4, 6, 2, -1 ],
        [ 3, 8, 0, 4, 1, 9, 4, 2, 1, 4, 6, 2, -1 ],
        [ 6, 2, 4, 4, 2, 0, -1 ],
        [ 3, 8, 2, 8, 4, 2, 4, 6, 2, -1 ],
        [ 4, 6, 9, 6, 11, 3, 9, 6, 3, 9, 3, 1, -1 ],
        [ 8, 6, 11, 4, 6, 8, 9, 0, 1, -1 ],
        [ 11, 3, 6, 3, 0, 6, 0, 4, 6, -1 ],
        [ 8, 6, 11, 4, 6, 8, -1 ],
        [ 10, 7, 6, 10, 8, 7, 10, 9, 8, -1 ],
        [ 3, 7, 0, 7, 6, 10, 0, 7, 10, 0, 10, 9, -1 ],
        [ 6, 10, 7, 7, 10, 8, 8, 10, 1, 8, 1, 0, -1 ],
        [ 6, 10, 7, 10, 1, 7, 1, 3, 7, -1 ],
        [ 3, 2, 11, 10, 7, 6, 10, 8, 7, 10, 9, 8, -1 ],
        [ 2, 9, 0, 10, 9, 2, 6, 11, 7, -1 ],
        [ 0, 8, 3, 7, 6, 11, 1, 2, 10, -1 ],
        [ 7, 6, 11, 1, 2, 10, -1 ],
        [ 2, 1, 9, 2, 9, 7, 9, 8, 7, 6, 2, 7, -1 ],
        [ 2, 7, 6, 3, 7, 2, 0, 1, 9, -1 ],
        [ 8, 7, 0, 7, 6, 0, 6, 2, 0, -1 ],
        [ 7, 2, 3, 6, 2, 7, -1 ],
        [ 8, 1, 9, 3, 1, 8, 11, 7, 6, -1 ],
        [ 11, 7, 6, 1, 9, 0, -1 ],
        [ 6, 11, 7, 0, 8, 3, -1 ],
        [ 11, 7, 6, -1 ],
        [ 7, 11, 5, 5, 11, 10, -1 ],
        [ 10, 5, 11, 11, 5, 7, 0, 3, 8, -1 ],
        [ 7, 11, 5, 5, 11, 10, 0, 9, 1, -1 ],
        [ 7, 11, 10, 7, 10, 5, 3, 8, 1, 8, 9, 1, -1 ],
        [ 5, 2, 10, 5, 3, 2, 5, 7, 3, -1 ],
        [ 5, 7, 10, 7, 8, 0, 10, 7, 0, 10, 0, 2, -1 ],
        [ 0, 9, 1, 5, 2, 10, 5, 3, 2, 5, 7, 3, -1 ],
        [ 9, 7, 8, 5, 7, 9, 10, 1, 2, -1 ],
        [ 1, 11, 2, 1, 7, 11, 1, 5, 7, -1 ],
        [ 8, 0, 3, 1, 11, 2, 1, 7, 11, 1, 5, 7, -1 ],
        [ 7, 11, 2, 7, 2, 9, 2, 0, 9, 5, 7, 9, -1 ],
        [ 7, 9, 5, 8, 9, 7, 3, 11, 2, -1 ],
        [ 3, 1, 7, 7, 1, 5, -1 ],
        [ 8, 0, 7, 0, 1, 7, 1, 5, 7, -1 ],
        [ 0, 9, 3, 9, 5, 3, 5, 7, 3, -1 ],
        [ 9, 7, 8, 5, 7, 9, -1 ],
        [ 8, 5, 4, 8, 10, 5, 8, 11, 10, -1 ],
        [ 0, 3, 11, 0, 11, 5, 11, 10, 5, 4, 0, 5, -1 ],
        [ 1, 0, 9, 8, 5, 4, 8, 10, 5, 8, 11, 10, -1 ],
        [ 10, 3, 11, 1, 3, 10, 9, 5, 4, -1 ],
        [ 3, 2, 8, 8, 2, 4, 4, 2, 10, 4, 10, 5, -1 ],
        [ 10, 5, 2, 5, 4, 2, 4, 0, 2, -1 ],
        [ 5, 4, 9, 8, 3, 0, 10, 1, 2, -1 ],
        [ 2, 10, 1, 4, 9, 5, -1 ],
        [ 8, 11, 4, 11, 2, 1, 4, 11, 1, 4, 1, 5, -1 ],
        [ 0, 5, 4, 1, 5, 0, 2, 3, 11, -1 ],
        [ 0, 11, 2, 8, 11, 0, 4, 9, 5, -1 ],
        [ 5, 4, 9, 2, 3, 11, -1 ],
        [ 4, 8, 5, 8, 3, 5, 3, 1, 5, -1 ],
        [ 0, 5, 4, 1, 5, 0, -1 ],
        [ 5, 4, 9, 3, 0, 8, -1 ],
        [ 5, 4, 9, -1 ],
        [ 11, 4, 7, 11, 9, 4, 11, 10, 9, -1 ],
        [ 0, 3, 8, 11, 4, 7, 11, 9, 4, 11, 10, 9, -1 ],
        [ 11, 10, 7, 10, 1, 0, 7, 10, 0, 7, 0, 4, -1 ],
        [ 3, 10, 1, 11, 10, 3, 7, 8, 4, -1 ],
        [ 3, 2, 10, 3, 10, 4, 10, 9, 4, 7, 3, 4, -1 ],
        [ 9, 2, 10, 0, 2, 9, 8, 4, 7, -1 ],
        [ 3, 4, 7, 0, 4, 3, 1, 2, 10, -1 ],
        [ 7, 8, 4, 10, 1, 2, -1 ],
        [ 7, 11, 4, 4, 11, 9, 9, 11, 2, 9, 2, 1, -1 ],
        [ 1, 9, 0, 4, 7, 8, 2, 3, 11, -1 ],
        [ 7, 11, 4, 11, 2, 4, 2, 0, 4, -1 ],
        [ 4, 7, 8, 2, 3, 11, -1 ],
        [ 9, 4, 1, 4, 7, 1, 7, 3, 1, -1 ],
        [ 7, 8, 4, 1, 9, 0, -1 ],
        [ 3, 4, 7, 0, 4, 3, -1 ],
        [ 7, 8, 4, -1 ],
        [ 11, 10, 8, 8, 10, 9, -1 ],
        [ 0, 3, 9, 3, 11, 9, 11, 10, 9, -1 ],
        [ 1, 0, 10, 0, 8, 10, 8, 11, 10, -1 ],
        [ 10, 3, 11, 1, 3, 10, -1 ],
        [ 3, 2, 8, 2, 10, 8, 10, 9, 8, -1 ],
        [ 9, 2, 10, 0, 2, 9, -1 ],
        [ 8, 3, 0, 10, 1, 2, -1 ],
        [ 2, 10, 1, -1 ],
        [ 2, 1, 11, 1, 9, 11, 9, 8, 11, -1 ],
        [ 11, 2, 3, 9, 0, 1, -1 ],
        [ 11, 0, 8, 2, 0, 11, -1 ],
        [ 3, 11, 2, -1 ],
        [ 1, 8, 3, 9, 8, 1, -1 ],
        [ 1, 9, 0, -1 ],
        [ 8, 3, 0, -1 ],
        [ -1 ],
    ]
    
    static var edgeTable: [[Int]] {
        return largeEdgeTable.map { row in
            if ( row.count == 1 ) {
                return []
            } else {
                var cleanRow: [Int] = []
                for r in 0...row.count - 2 {
                    cleanRow.append( row[r] )
                }
                return cleanRow
            }
        }
    }
    
}

extension MarchingCubes {
    
    static let testSeeds: [Int] = [124, 35, 50, 27, 217, 187, 60, 140, 144, 137, 234, 113, 142, 20, 255, 76, 63, 36, 43, 171, 6, 176, 57, 42, 159, 14, 177, 104, 82, 66, 239, 93, 189, 184, 83, 199, 219, 41, 94, 73, 169, 29, 107, 154, 85, 150, 162, 127, 0, 227, 62, 250, 114, 123, 178, 151, 180, 238, 34, 120, 197, 19, 100, 7, 130, 8, 253, 28, 170, 209, 167, 145, 126, 134, 96, 13, 59, 12, 89, 78, 213, 33, 216, 92, 37, 181, 105, 15, 135, 110, 116, 45, 183, 143, 161, 155, 97, 95, 241, 61, 212, 118, 218, 77, 136, 158, 9, 64, 54, 2, 146, 44, 132, 160, 166, 246, 152, 49, 81, 230, 84, 153, 30, 240, 210, 98, 221, 40, 147, 198, 90, 232, 117, 252, 22, 119, 205, 247, 139, 194, 249, 3, 122, 195, 91, 157, 200, 79, 148, 242, 17, 193, 11, 175, 16, 182, 237, 4, 39, 88, 235, 211, 201, 163, 115, 21, 71, 102, 25, 215, 24, 32, 106, 185, 251, 125, 46, 202, 112, 56, 109, 236, 1, 53, 229, 48, 108, 129, 58, 68, 80, 190, 156, 233, 141, 38, 133, 208, 87, 70, 128, 26, 5, 138, 204, 173, 165, 72, 101, 248, 186, 192, 228, 103, 191, 207, 225, 18, 188, 47, 74, 67, 23, 226, 75, 51, 224, 10, 69, 214, 164, 222, 131, 52, 231, 172, 31, 174, 55, 203, 254, 111, 245, 99, 244, 196, 149, 223, 243, 86, 220, 179, 121, 168, 65, 206, 124, 35, 50, 27, 217, 187, 60, 140, 144, 137, 234, 113, 142, 20, 255, 76, 63, 36, 43, 171, 6, 176, 57, 42, 159, 14, 177, 104, 82, 66, 239, 93, 189, 184, 83, 199, 219, 41, 94, 73, 169, 29, 107, 154, 85, 150, 162, 127, 0, 227, 62, 250, 114, 123, 178, 151, 180, 238, 34, 120, 197, 19, 100, 7, 130, 8, 253, 28, 170, 209, 167, 145, 126, 134, 96, 13, 59, 12, 89, 78, 213, 33, 216, 92, 37, 181, 105, 15, 135, 110, 116, 45, 183, 143, 161, 155, 97, 95, 241, 61, 212, 118, 218, 77, 136, 158, 9, 64, 54, 2, 146, 44, 132, 160, 166, 246, 152, 49, 81, 230, 84, 153, 30, 240, 210, 98, 221, 40, 147, 198, 90, 232, 117, 252, 22, 119, 205, 247, 139, 194, 249, 3, 122, 195, 91, 157, 200, 79, 148, 242, 17, 193, 11, 175, 16, 182, 237, 4, 39, 88, 235, 211, 201, 163, 115, 21, 71, 102, 25, 215, 24, 32, 106, 185, 251, 125, 46, 202, 112, 56, 109, 236, 1, 53, 229, 48, 108, 129, 58, 68, 80, 190, 156, 233, 141, 38, 133, 208, 87, 70, 128, 26, 5, 138, 204, 173, 165, 72, 101, 248, 186, 192, 228, 103, 191, 207, 225, 18, 188, 47, 74, 67, 23, 226, 75, 51, 224, 10, 69, 214, 164, 222, 131, 52, 231, 172, 31, 174, 55, 203, 254, 111, 245, 99, 244, 196, 149, 223, 243, 86, 220, 179, 121, 168, 65, 206]
    
}
