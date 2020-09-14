#version 110

attribute vec4 Position;

uniform mat4 ProjMat;
uniform vec2 InSize;
uniform float ScreenTolerance;
uniform float FOV;

varying vec2 texCoord;
varying vec2 oneTexel;
varying float pixSearchR;
varying float pixFocal;

void main(){
    vec4 outPos = ProjMat * vec4(Position.xy, 0.0, 1.0);
    gl_Position = vec4(outPos.xy, 0.2, 1.0);

    oneTexel = 1.0 / InSize;
    texCoord = outPos.xy * 0.5 + 0.5;
    pixSearchR = floor(ScreenTolerance * InSize.y * 1.1 + 0.5);
    pixFocal = 0.5 * InSize.y / tan(FOV / 360.0 * 3.14159265358979);
}
