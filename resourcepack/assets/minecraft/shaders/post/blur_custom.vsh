#version 150

in vec4 Position;

uniform mat4 ProjMat;
uniform vec2 OutSize;

out vec2 texCoord;
flat out float aspectRatio;

void main(){
    vec4 outPos = ProjMat * vec4(Position.xy * OutSize, 0.0, 1.0);
    gl_Position = vec4(outPos.xy, 0.2, 1.0);
    aspectRatio = OutSize.x / OutSize.y;
    texCoord = Position.xy;
}
