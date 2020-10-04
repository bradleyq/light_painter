#version 120

attribute vec4 Position;

uniform mat4 ProjMat;
uniform vec2 InSize;
uniform vec2 AuxSize1;
uniform float FOV;

varying vec2 texCoord;
varying vec2 oneTexel;
varying vec2 oneTexelAux1;
varying float aspectRatio;
varying float conversionK;

void main(){
    vec4 outPos = ProjMat * vec4(Position.xy, 0.0, 1.0);
    gl_Position = vec4(outPos.xy, 0.2, 1.0);

    oneTexel = 1.0 / InSize;
    oneTexelAux1 = 1.0 / AuxSize1;
    aspectRatio = InSize.x / InSize.y;
    texCoord = outPos.xy * 0.5 + 0.5;
    conversionK = tan(FOV / 360.0 * 3.14159265358979) * 2.0;
}
