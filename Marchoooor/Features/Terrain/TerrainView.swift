//
//  TerrainView.swift
//  Marchoooor
//
//  Created by Todd Littlejohn on 10/20/23.
//

import Foundation
import SwiftUI
import RealityKit
import ARKit
import ComposableArchitecture

struct TerrainView: View {
    
    @State var arView = ARView(frame: .zero)
    let store: StoreOf<TerrainFeature>
    @State var marchingCubes = MarchingCubesTester()
    
    var body: some View {
        WithViewStore( self.store, observe: { $0 } ) { viewStore in
            ZStack {
                ARViewContainer(arView: arView)
                    .edgesIgnoringSafeArea(.all)
                HStack {
                    Form {
                        Section("ISO Level") {
                            Stepper(String(format: "ISO Level: %.2f", viewStore.isoLevel), value: viewStore.binding(get: \.isoLevel, send: { .updateIsoLevel($0) }), step: 0.1)

                        }
                        Section("Modify Terrain") {
                            Picker(selection: viewStore.binding( get: \.influenceMode, send: { .setInfluenceMode($0) } )) {
                                Text("Lower")
                                    .tag(InfluenceMode.lower)
                                Text("Raise")
                                    .tag(InfluenceMode.raise)
                            } label: {
                                Text("OMG SO CLOSE")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            Stepper(String(format: "Radius: %.2f", viewStore.radius), value: viewStore.binding(get: \.radius, send: { .setRadius($0) }), step: 0.1)
                            Stepper(String(format: "Strength: %.2f", viewStore.strength), value: viewStore.binding(get: \.strength, send: { .setStrength($0) }), step: 0.05)
                            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                                .fill(Color.blue) // Color of the square
                                .frame(width: 250, height: 250) // Dimensions of the square
                                .padding() // Some padding around the square for aesthetics
                                .onTapGesture { location in
                                    
                                    let x = 6 * min(250, max(0, location.x - 25)) / 250
                                    let z = 6 * min(250, max(0, location.y - 25)) / 250
                                    
                                    let newInfluence = TerrainInfluence(
                                        x: Float(x),
                                        z: Float(z),
                                        radius: viewStore.radius,
                                        strength: viewStore.strength,
                                        mode: viewStore.influenceMode
                                    )
                                    viewStore.send( .addInfluence(newInfluence) )
                                }
                                .padding(0)
                            
                        }
                        .padding(0)
                        
                    }
                    .frame(width: 300)
                    Spacer()
                }
                .onChange(of: viewStore.isoLevel ) { oldValue, newValue in
                    
                    marchingCubes.updateIsoLevel(newValue: newValue)
                    let mesh = marchingCubes.createMeshResource()
                    if let terrainEntity = arView.scene.findEntity(named: "terrain") as? ModelEntity {
                        try! terrainEntity.model?.mesh.replace(with: mesh.contents)
                    }
                }
                .onChange(of: viewStore.influences ) { oldValue, newValue in
                    
                    marchingCubes.setTerrainInfluences(influences: newValue)
                    let mesh = marchingCubes.createMeshResource()
                    if let terrainEntity = arView.scene.findEntity(named: "terrain") as? ModelEntity {
                        try! terrainEntity.model?.mesh.replace(with: mesh.contents)
                    }
                }
            }
        }
    }

}

func sphere(radius: Float, color: UIColor) -> ModelEntity {
    let sphere = ModelEntity(mesh: .generateSphere(radius: radius), materials: [SimpleMaterial(color: color, isMetallic: false)])
    // Move sphere up by half its diameter so that it does not intersect with the mesh
    sphere.position.y = radius
    return sphere
}
