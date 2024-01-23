//
//  ComputeCube.metal
//  MarchingCubes
//
//  Created by Todd Littlejohn on 9/15/23.
//

#include <metal_stdlib>
using namespace metal;

// Type defs
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

struct Influence {
    float x_center;
    float z_center;
    int raise;
    float radius;
    float strength;
};

// Helper function definitions
float perlin(device const int* seed, float xs, float ys, float zs, device const Influence* influences, int influenceCount);
float perlin2D(device const int* seed, float xs, float ys);
float hillFunction(device const int* seed, float x, float z, int influenceCount, device const Influence* influences);
float influenceFunction(float x, float z, float x_center, float z_center, float r);
float totalInfluence(float x, float z, int influenceCount, device const Influence* influences);
float fade(float t);
float lerp(float a, float b, float t);
float grad(int hash, float x, float y, float z);

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
                         device const Influence* influences,
                         device const int* influenceCount,
                         device float* xPositions,
                         device float* yPositions,
                         device float* zPositions,
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
                
        float noiseValue = perlin(seed, vertexPositionX, vertexPositionY, vertexPositionZ, influences, influenceCount[0]);
        
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
            
            float startVertexNoiseLevel = perlin(seed, startVertexX, startVertexY, startVertexZ, influences, influenceCount[0]);
            float endVertexNoiseLevel = perlin(seed, endVertexX, endVertexY, endVertexZ, influences, influenceCount[0]);
//
            float t = ( isoLevel[0] - startVertexNoiseLevel ) / ( endVertexNoiseLevel - startVertexNoiseLevel );
            float interpolatedVertexX = startVertexX + ( t * ( endVertexX - startVertexX ) );
            float interpolatedVertexY = startVertexY + ( t * ( endVertexY - startVertexY ) );
            float interpolatedVertexZ = startVertexZ + ( t * ( endVertexZ - startVertexZ ) );
//            
            int positionIndex = ( index * 20 ) + l;
                        
            xPositions[ positionIndex ] = interpolatedVertexX;
            yPositions[ positionIndex ] = interpolatedVertexY;
            zPositions[ positionIndex ] = interpolatedVertexZ;
            
        }
    }
    
    positionCount[index] = length;
        
}

float perlin(device const int* seed, float xs, float ys, float zs, device const Influence* influences, int influenceCount) {
    
    // Get the height from the hill function
    float height = hillFunction(seed, xs, zs, influenceCount, influences);
    
    // Return a value based on the difference between the height and the z-coordinate
    return height - ys;

    
//    float xFloor = floor(xs);
//    float xDelta = xs - xFloor;
//    float xPi = xDelta * 6.28;
//    
//    float zFloor = floor(zs);
//    float zDelta = zs - zFloor;
//    float zPi = zDelta * 6.28;
//    
//    float xWaveHeight = sin(xPi);
//    float zWaveHeight = sin(zPi);
//    
//    if ( ys < xWaveHeight + 1 && ys < zWaveHeight + 1 ) {
//        return 0.3;
//    } else {
//        return 0;
//    }
    
//    float xVec = xs - 2.5;
//    float yVec = ys;
//    float zVec = zs - 2.5;
//    
//    float xSqrd = xVec * xVec;
//    float ySqrd = yVec * yVec;
//    float zSqrd = zVec * zVec;
//    
//    float sqrdTotal = xSqrd + ySqrd + zSqrd;
//    
//    float distance = sqrt(sqrdTotal);
//    
//    if ( distance < 2.5 ) {
//        return 0.5;
//    } else {
//        return 0;
//    }
    
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

float perlin2D(device const int* seed, float xs, float ys) {
    int X = int(xs) & 255;
    int Y = int(ys) & 255;
    
    float x = xs - floor(xs);
    float y = ys - floor(ys);
    
    float u = fade(x);
    float v = fade(y);
    
    int A = seed[X] + Y;
    int B = seed[X + 1] + Y;
    
    return lerp(
                lerp(
                     grad(seed[A], x, y, 0.0),
                     grad(seed[B], x-1, y, 0.0),
                     u
                     ),
                lerp(
                     grad(seed[A+1], x, y-1, 0.0),
                     grad(seed[B+1], x-1, y-1, 0.0),
                     u
                     ),
                v
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

float hillFunction(device const int* seed, float x, float z, int influenceCount, device const Influence* influences) {
    // Use 2D noise for base terrain
    float baseHeight = perlin2D(seed, x, z);
    
    // Use another 2D noise function, possibly at a different scale, for hill height
    float hillHeight = perlin2D(seed, x * 0.5, z * 0.5);
    
    float influence = totalInfluence(x, z, influenceCount, influences);
    
    // Combine the two in some way to get the final height
    return baseHeight + hillHeight * 0.5 + influence; // The 0.5 multiplier makes hills half as tall as base terrain
}

float totalInfluence(float x, float z, int influenceCount, device const Influence* influences) {
    float total = 0.0;
    for (int i = 0; i < influenceCount; i++) {
        
        if ( influences[i].raise == 1 ) {
            total += influenceFunction(x, z, influences[i].x_center, influences[i].z_center, influences[i].radius) * influences[i].strength;
        } else {
            total -= influenceFunction(x, z, influences[i].x_center, influences[i].z_center, influences[i].radius) * influences[i].strength;
        }
        
    }
    return total;
}

float influenceFunction(float x, float z, float x_center, float z_center, float r) {
    float distance = sqrt((x - x_center) * (x - x_center) + (z - z_center) * (z - z_center));
    float influence = max(0.0, 1.0 - distance / r);
    return influence;
}
