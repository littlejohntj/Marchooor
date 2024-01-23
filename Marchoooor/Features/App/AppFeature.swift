//
//  AppFeature.swift
//  PhysicsGame
//
//  Created by Todd Littlejohn on 10/16/23.
//

import Foundation
import ComposableArchitecture

struct AppFeature: Reducer {
    
    struct State {
        var path = StackState<Path.State>()
        var terrain = TerrainFeature.State()
    }
    
    enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case terrain(TerrainFeature.Action)
    }
    
    struct Path: Reducer {
        
        enum State {
            case terrain(TerrainFeature.State)
        }
        enum Action {
            case terrain(TerrainFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: /State.terrain,
                  action: /Action.terrain) {
                TerrainFeature()
            }
        }
        
    }
    
    var body: some ReducerOf<Self> {
        
        Scope(state: \.terrain, action: /Action.terrain) {
            TerrainFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .path(_):
                return .none
            case .terrain(_):
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }


    
}
