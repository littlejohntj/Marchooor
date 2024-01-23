//
//  AppView.swift
//  Marchoooor
//
//  Created by Todd Littlejohn on 10/20/23.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct AppView: View {
    
    let store: StoreOf<AppFeature>

    var body: some View {
        
        NavigationStackStore(
            self.store.scope(state: \.path, action: { .path($0) })
        ) {
            TerrainView(
                store: self.store.scope(
                    state: \.terrain,
                    action: { .terrain( $0 ) }
                )
            )
        } destination: { state in
            switch state {
            default:
                Text("Uwu")
            }
        }
        
    }
    
}
