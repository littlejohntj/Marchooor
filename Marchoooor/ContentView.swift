//
//  ContentView.swift
//  Marchoooor
//
//  Created by Todd Littlejohn on 10/2/23.
//

import SwiftUI

struct ContentView: View {

    let marchingCubes = MarchingCubesTester()
    
    var body: some View {
        VStack {
            Button("March") {
                compareGpuAndCpu()
            }
        }
        .padding()
    }
    
    func compareGpuAndCpu() {
        
        let results = marchingCubes.gpuMarchingCubes.getPositionCounts()
        for r in results {
            print(r)
        }
        
    }
}

#Preview {
    ContentView()
}
