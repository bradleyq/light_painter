#version 150

#define BIG 1000000
#define FIXEDPOINT 1000.0
#define DSCALE 10.0

#define NEAR 0.05
#define FAR 1024.0

#define LIGHTR 8.0
#define SPREAD 3.0
#define BOOST 12.0
#define CUTOFF 0.02

#define ALPHACUTOFF (21.5 / 255.0)
#define LIGHTALPHA (24.0 / 255.0)
#define LIGHTDEPTH 0.025

bool isGUI(mat4 ProjMat) { 
    return abs(ProjMat[2][3]) <= 1.0 / BIG;
}

bool isHand(float fogs, float foge) { // also includes panorama
    return fogs >= foge;
}

float LinearizeDepth(float depth) {
    float z = depth * 2.0 - 1.0;
    return 2.0 * (NEAR * FAR) / (FAR + NEAR - z * (FAR - NEAR));    
}

float luminance(vec3 rgb) {
    return 0.2126 * rgb.r + 0.7152 * rgb.g + 0.0722 * rgb.b;
}
