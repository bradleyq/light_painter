#version 150

#define BIG 1000000
#define FIXEDPOINT 1000.0
#define DSCALE 10.0
#define ERRORMARGIN 0.0005

#define NEAR 0.05
#define FAR 1024.0

#define LIGHTR 8.0
#define SPREAD 1.2
#define BOOST 2.5
#define CUTOFF 0.02

#define ALPHACUTOFF (21.5 / 255.0)
#define LIGHTALPHA (24.0 / 255.0)

bool isHand(float fogs, float foge) { // also includes panorama
    return fogs >= foge;
}