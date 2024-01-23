//
//  MarchoooorApp.swift
//  Marchoooor
//
//  Created by Todd Littlejohn on 10/2/23.
//

import SwiftUI
import ComposableArchitecture

@main
struct MarchoooorApp: App {
    
    let store = Store(initialState: AppFeature.State(
        terrain: TerrainFeature.State()
    )) {
        AppFeature()
    }

    
    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
