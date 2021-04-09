#version 150

in vec4 Position;

uniform mat4 ProjMat;
uniform vec2 InSize;
uniform vec2 AuxSize1;
uniform float FOV;

out vec2 texCoord;
flat out vec2 oneTexel;
flat out vec2 oneTexelAux1;
flat out float aspectRatio;
flat out float conversionK;

void main(){
    vec4 outPos = ProjMat * vec4(Position.xy, 0.0, 1.0);
    oneTexel = 1.0 / InSize;
    oneTexelAux1 = 1.0 / AuxSize1;
    aspectRatio = InSize.x / InSize.y;
    texCoord = outPos.xy * 0.5 + 0.5;
    conversionK = tan(FOV / 360.0 * 3.14159265358979) * 2.0;

    gl_Position = vec4(outPos.xy, 0.2, 1.0);
}
