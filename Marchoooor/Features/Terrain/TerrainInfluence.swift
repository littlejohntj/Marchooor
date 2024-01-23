//
//  TerrainInfluence.swift
//  Marchoooor
//
//  Created by Todd Littlejohn on 10/20/23.
//

import Foundation

struct TerrainInfluence: Equatable {
    var x: Float
    var z: Float
    var radius: Float
    var strength: Float
    var mode: InfluenceMode
}

enum InfluenceMode {
    case lower
    case raise
}
