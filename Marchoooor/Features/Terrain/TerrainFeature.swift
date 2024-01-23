//
//  TerrainGenerationFeature.swift
//  Marchoooor
//
//  Created by Todd Littlejohn on 10/20/23.
//

import Foundation
import ComposableArchitecture

struct TerrainFeature: Reducer {
    
    struct State: Equatable {
        var isoLevel: Float = 0.2
        var radius: Float = 1.5
        var strength: Float = 0.75
        var influences: [TerrainInfluence] = []
        var influenceMode: InfluenceMode = .raise
    }
    enum Action {
        case addInfluence(TerrainInfluence)
        case setRadius(Float)
        case setInfluenceMode(InfluenceMode)
        case setStrength(Float)
        case updateIsoLevel(Float)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .addInfluence(newInfluence):
                state.influences.append(newInfluence)
                return .none
            case let .setInfluenceMode(newMode):
                state.influenceMode = newMode
                return .none
            case let .setRadius(newRadius):
                state.radius = newRadius
                return .none
            case let .setStrength(newStrength):
                state.strength = newStrength
                return .none
            case let .updateIsoLevel(newValue):
                state.isoLevel = newValue
                return .none
            }
        }
    }
}
