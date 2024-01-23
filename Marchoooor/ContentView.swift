//
//  ContentView.swift
//  Marchoooor
//
//  Created by Todd Littlejohn on 10/2/23.
//

import SwiftUI
import RealityKit
import Combine
import ARKit

struct ContentView: View {
    
    @State var arView = ARView(frame: .zero)
        
    var body: some View {
        ZStack {
            ARViewContainer(arView: arView)
                .edgesIgnoringSafeArea(.all)
            }
    }
    
}

struct ARViewContainer: UIViewRepresentable {
    
    @State var arView: ARView
    
    let marchingCubes = MarchingCubesTester()
    
    func makeUIView(context: Context) -> ARView {
        
//        arView.environment.sceneUnderstanding.options = []
//        
//        // Turn on occlusion from the scene reconstruction's mesh.
//        arView.environment.sceneUnderstanding.options.insert(.occlusion)
//        
//        // Turn on physics for the scene reconstruction's mesh.
//        arView.environment.sceneUnderstanding.options.insert(.physics)
//
//        // Display a debug visualization of the mesh.
//        arView.debugOptions.insert(.showSceneUnderstanding)
//        
//        // For performance, disable render options that are not required for this app.
//        arView.renderOptions = [.disablePersonOcclusion, .disableDepthOfField, .disableMotionBlur]
//        
//        // Manually configure what kind of AR session to run since
//        // ARView on its own does not turn on mesh classification.
//        arView.automaticallyConfigureSession = false
//                
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.sceneReconstruction = .meshWithClassification
//
//        configuration.environmentTexturing = .automatic
//        arView.session.run(configuration)
                
        let mesh = marchingCubes.createMeshResource()
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint:.blue)
        material.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.0)
        material.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 1.0)
        material.faceCulling = .none
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.transform.scale = [ 0.15, 0.15, 0.15 ]
        model.name = "terrain"
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        anchor.children.append(model)
        arView.scene.anchors.append(anchor)

        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}


#Preview {
    ContentView()
}

extension ARView {
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: sender.view as! ARSCNView)
        let hitTestResults = (sender.view as! ARSCNView).hitTest(tapLocation, types: .existingPlaneUsingGeometry)

        guard let hitResult = hitTestResults.first else {
            print("No mesh detected at tapped location")
            return
        }

        let hitPosition = SCNVector3Make(
            hitResult.worldTransform.columns.3.x,
            hitResult.worldTransform.columns.3.y,
            hitResult.worldTransform.columns.3.z
        )

        let x = hitPosition.x
        let z = hitPosition.z
        print("X: \(x), Z: \(z)")
    }
    
}
