//
//  ComputeCube.metal
//  MarchingCubes
//
//  Created by Todd Littlejohn on 9/15/23.
//

#include <metal_stdlib>
using namespace metal;

// Helper function definitions
float perlin(device const int* seed, float xs, float ys, float zs);
float fade(float t);
float lerp(float a, float b, float t);
float grad(int hash, float x, float y, float z);

struct Point3D {
    float x;
    float y;
    float z;
};

struct Edge {
    float start;
    float end;
};

struct DynamicArray {
    int items[8];       // Storage for up to 8 items.
    int currentSize;    // Number of valid items in the array.
};

kernel void compute_cube(device const int* inputs,
                         device const float* inX,
                         device const float* inY,
                         device const float* inZ,
                         device const int* seed,
                         device const int* edgeTable,
                         device const int* edgesOffsets,
                         device const int* edgesLength,
                         device const float* cubeDistance,
                         device const float* isoLevel,
                         device float* xPositions,
                         device int* positionCount,
                         uint index [[thread_position_in_grid]])
{
    // the for-loop is replaced with a collection of threads, each of which
    // calls this function.
        
    Edge edgeIndicies[] = {
        {0, 1}, {1, 3}, {2, 3}, {0, 2},
        {4, 5}, {5, 7}, {6, 7}, {4, 6},
        {0, 4}, {1, 5}, {3, 7}, {2, 6}
    };
    
    float distance = cubeDistance[0];

//    int encodedIndex = inputs[index];
//    int x = encodedIndex / 1000000;
//    int y = (encodedIndex % 1000000) / 1000;
//    int z = encodedIndex % 1000;
    
    float startingX = inX[index] * distance;
    float startingY = inY[index] * distance;
    float startingZ = inZ[index] * distance;
    
    Point3D cornerPositions[] = {
        {0, 0, 0}, {1, 0, 0}, {0, 1, 0}, {1, 1, 0},
        {0, 0, 1}, {1, 0, 1}, {0, 1, 1}, {1, 1, 1}
    };
    
    DynamicArray vertexes;
    vertexes.currentSize = 0;
        

    for ( int i = 0; i < 8; i++ ) {
        
        Point3D cornerPosition = cornerPositions[i];
        float cornerDeltaX = cornerPosition.x * distance;
        float cornerDeltaY = cornerPosition.y * distance;
        float cornerDeltaZ = cornerPosition.z * distance;
        
        float vertexPositionX = startingX + cornerDeltaX;
        float vertexPositionY = startingY + cornerDeltaY;
        float vertexPositionZ = startingZ + cornerDeltaZ;
                
        float noiseValue = perlin(seed, vertexPositionX, vertexPositionY, vertexPositionZ);
        
//        pr[index] = noiseValue;
        
        if ( noiseValue > isoLevel[0] ) {
            vertexes.items[vertexes.currentSize] = i;
            vertexes.currentSize++;
        }
                        
    }
    
    int cubeIndex = 0;
    
    for ( int j = 0; j < vertexes.currentSize; j++ ) {
        cubeIndex = cubeIndex | 1 << vertexes.items[j];
    }
        
    int length = edgesLength[cubeIndex];
    int offset = edgesOffsets[cubeIndex];
    int count = 0;
    
    if ( offset != -1 ) {
        
        for ( int l = 0; l < length; l++ ) {
            
            int edge = edgeTable[ offset + l ];
            Edge edgeIndicie = edgeIndicies[edge];
            int edgeIndicieStart = edgeIndicie.start;
            int edgeIndicieEnd = edgeIndicie.end;
            Point3D startCornerPosition = cornerPositions[edgeIndicieStart];
            Point3D endCornerPosition = cornerPositions[edgeIndicieEnd];
//            
            float startCornerPositionX = startCornerPosition.x * cubeDistance[0];
            float startCornerPositionY = startCornerPosition.y * cubeDistance[0];
            float startCornerPositionZ = startCornerPosition.z * cubeDistance[0];
//            
            float endCornerPositionX = endCornerPosition.x * cubeDistance[0];
            float endCornerPositionY = endCornerPosition.y * cubeDistance[0];
            float endCornerPositionZ = endCornerPosition.z * cubeDistance[0];
            
            float startVertexX = startingX + startCornerPositionX;
            float startVertexY = startingY + startCornerPositionY;
            float startVertexZ = startingZ + startCornerPositionZ;
//            
            float endVertexX = startingX + endCornerPositionX;
            float endVertexY = startingY + endCornerPositionY;
            float endVertexZ = startingZ + endCornerPositionZ;
            
            float startVertexNoiseLevel = perlin(seed, startVertexX, startVertexY, startVertexZ);
            float endVertexNoiseLevel = perlin(seed, endVertexX, endVertexY, endVertexZ);
//            
            float t = ( isoLevel[0] - startVertexNoiseLevel ) / ( endVertexNoiseLevel - startVertexNoiseLevel );
            float interpolatedVertexX = startVertexX + ( t * ( endVertexX - startVertexX ) );
            float interpolatedVertexY = startVertexY + ( t * ( endVertexY - startVertexY ) );
            float interpolatedVertexZ = startVertexZ + ( t * ( endVertexZ - startVertexZ ) );
//            
            int positionIndex = ( index * 20 ) + l;
            
//            xPositions[ positionIndex ] = 10.0;
            
//            xPositions[ ( index * 20 ) + l ] = interpolatedVertexX;
//            yPositions[ ( index * 20 ) + l ] = interpolatedVertexY;
//            zPositions[ ( index * 20 ) + l ] = interpolatedVertexZ;
//            count += 1;
            
        }
    }
    
    // Try commenting out this line
    xPositions[index] = 3.4;
    
    
    positionCount[index] = 4;
    
        
}

float perlin(device const int* seed, float xs, float ys, float zs) {
    
//    float s1 = 0.0001;
//    float s2 = ys;
//    float s3 = zs;
    
//    int foo = int(s1) & 255;
//    
//    return 5.0;
    
    int X = int(xs) & 255;
    int Y = int(ys) & 255;
    int Z = int(zs) & 255;
    
    float x = xs - floor(xs);
    float y = ys - floor(ys);
    float z = zs - floor(zs);
        
    float u = fade(x);
    float v = fade(y);
    float w = fade(z);
        
    int A = seed[X] + Y;
    int AA = seed[A] + Z;
    int AB = seed[A + 1] + Z;
    int B = seed[X + 1] + Y;
    int BA = seed[B] + Z;
    int BB = seed[B + 1] + Z;
    
            
    return lerp(
                lerp(
                     lerp(
                          grad(seed[AA], x, y, z),
                          grad(seed[BA], x-1, y, z),
                          u
                          ),
                     lerp(
                          grad(seed[AB], x, y-1, z),
                          grad(seed[BB], x-1, y-1, z),
                          u
                          ),
                     v
                    ),
                lerp(
                     lerp(
                          grad(seed[AA+1], x, y, z-1),
                          grad(seed[BA+1], x-1, y, z-1),
                          u
                          ),
                     lerp(
                          grad(seed[AB+1], x, y-1, z-1),
                          grad(seed[BB+1], x-1, y-1, z-1),
                          u
                          ),
                     v
                    ),
                w
            );
}

float fade(float t) {
    return t * t * t * (t * (t * 6 - 15) + 10);
}

float lerp(float a, float b, float t) {
    return a + t * (b - a);
}

float grad(int hash, float x, float y, float z) {
    
    Point3D g3[] = {
        {1, 1, 0}, {-1, 1, 0}, {1, -1, 0}, {-1, -1, 0},
        {1, 0, 1}, {-1, 0, 1}, {1, 0, -1}, {-1, 0, -1},
        {0, 1, 1}, {0, -1, 1}, {0, 1, -1}, {0, -1, -1}
    };
    
    int h = hash & 15;
    Point3D grad = g3[h % 12];
    return ( grad.x * x ) + ( grad.y * y ) + ( grad.z * z );
    
}
