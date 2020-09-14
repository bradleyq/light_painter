#version 110

attribute vec4 Position;

uniform mat4 ProjMat;
uniform vec2 InSize;
uniform float ScreenTolerance;
uniform float ScreenMaxR;
uniform float FOV;

varying vec2 texCoord;
varying vec2 oneTexel;
varying float aspectRatio;
varying float pixTol;
varying float pixMax;
varying float Focal;

void main(){
    vec4 outPos = ProjMat * vec4(Position.xy, 0.0, 1.0);
    gl_Position = vec4(outPos.xy, 0.2, 1.0);

    oneTexel = 1.0 / InSize;
    aspectRatio = InSize.x / InSize.y;
    texCoord = outPos.xy * 0.5 + 0.5;
    pixTol = floor(ScreenTolerance * InSize.y + 0.5);
    pixMax = floor(ScreenMaxR * InSize.y + 0.5);
    Focal = 0.5 / tan(FOV / 360.0 * 3.14159265358979);
}
