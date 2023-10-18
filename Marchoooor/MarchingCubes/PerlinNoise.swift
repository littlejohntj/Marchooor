//
//  PerlinNoise.swift
//  MarchingCubes
//
//  Created by Todd Littlejohn on 9/8/23.
//

import Foundation
import UIKit

struct PerlinNoise {
    
    // Permutation table
    static var p: [Int] = {
        var tempP = Array(0..<256)
        tempP.shuffle()
        return tempP + tempP
        
    }()
    
    private static let g3: [(Float, Float, Float)] = [
        (1,1,0),(-1,1,0),(1,-1,0),(-1,-1,0),
        (1,0,1),(-1,0,1),(1,0,-1),(-1,0,-1),
        (0,1,1),(0,-1,1),(0,1,-1),(0,-1,-1)
    ]
    
    static func perlin(_ x: Float, _ y: Float, _ z: Float, seed: [Int]) -> Float {
        let X = Int(x) & 255
        let Y = Int(y) & 255
        let Z = Int(z) & 255
        
        let x = x - floor(x)
        let y = y - floor(y)
        let z = z - floor(z)
        
                
        let u = fade(x)
        let v = fade(y)
        let w = fade(z)
                        
        let A = seed[X] + Y
        let AA = seed[A] + Z
        let AB = seed[A + 1] + Z
        let B = seed[X + 1] + Y
        let BA = seed[B] + Z
        let BB = seed[B + 1] + Z
                                
        return lerp(
            lerp(
                lerp(grad(seed[AA], x, y, z),
                     grad(seed[BA], x-1, y, z),
                     u),
                lerp(grad(seed[AB], x, y-1, z),
                     grad(seed[BB], x-1, y-1, z),
                     u),
                v),
            lerp(
                lerp(grad(seed[AA+1], x, y, z-1),
                     grad(seed[BA+1], x-1, y, z-1),
                     u),
                lerp(grad(seed[AB+1], x, y-1, z-1),
                     grad(seed[BB+1], x-1, y-1, z-1),
                     u),
                v),
            w)
    }
    
    private static func fade(_ t: Float) -> Float {
        return t * t * t * (t * (t * 6 - 15) + 10)
    }
    
    private static func lerp(_ a: Float, _ b: Float, _ t: Float) -> Float {
        return a + t * (b - a)
    }
    
    private static func grad(_ hash: Int, _ x: Float, _ y: Float, _ z: Float) -> Float {
        let h = hash & 15
        let grad = g3[h % 12]
        return grad.0*x + grad.1*y + grad.2*z
    }
    

    static func grayShade(from value: Float) -> UIColor {
        // Clamp the value between -1 and 1
        let clampedValue = max(-1.0, min(1.0, value))
        
        // Convert the range from [-1, 1] to [0, 1]
        let normalizedValue = (clampedValue + 1) * 0.5
        
        return UIColor(white: CGFloat(normalizedValue), alpha: 1.0)
    }
    
    static func percentageBetween(A: Float, B: Float, C: Float) -> Float {
        
        if ( C > A && C > B ) || ( C < A && C < B ) {
            fatalError()
        }
        
        // Calculate the range between A and B
        let totalRange = abs(B - A)
        
        // Calculate the difference between the smaller of A and B and C
        let differenceFromStart = abs(C - min(A, B))
        
        // Calculate the percentage
        let percentage = (differenceFromStart / totalRange)
        
        return percentage
    }
    
    static func fakePerlin(_ x: Float, _ y: Float, _ z: Float) -> Float {
        if ( y > 0.2 ) {
            return 0.9
        } else {
            return -0.5
        }
    }

}
