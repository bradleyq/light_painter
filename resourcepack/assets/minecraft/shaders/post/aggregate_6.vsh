#version 150

in vec4 Position;

uniform mat4 ProjMat;
uniform vec2 InSize;
uniform vec2 OutSize;
uniform float FOV;

out vec2 texCoord;
flat out vec2 inOneTexel;
flat out float inAspectRatio;
flat out float conversionK;

void main(){
    float x = -1.0; 
    float y = -1.0;
    if (Position.x > 0.001){
        x = 1.0;
    }
    if (Position.y > 0.001){
        y = 1.0;
    }

    inAspectRatio = InSize.x / InSize.y;
    inOneTexel = 1.0 / InSize;
    texCoord = Position.xy / OutSize;
    conversionK = tan(FOV / 360.0 * 3.14159265358979) * 2.0;

    gl_Position = vec4(x, y, 0.2, 1.0);
}
