#version 150

#moj_import <minecraft:utils.glsl>
#moj_import <minecraft:texint.glsl>

in vec4 Position;

uniform sampler2D LightsSampler;

uniform mat4 ProjMat;
uniform vec2 LightsSize;
uniform vec2 OutSize;

out vec2 texCoord;
flat out vec2 oneTexel;
flat out vec2 oneTexelLights;
flat out float count;
flat out float stepX;
flat out float stepZ;

void main(){
    float x = -1.0; 
    float y = -1.0;
    if (Position.x > 0.001){
        x = 1.0;
    }
    if (Position.y > 0.001){
        y = 1.0;
    }

    gl_Position = vec4(x, y, 0.2, 1.0);
    oneTexel = 1.0 / OutSize;
    oneTexelLights = 1.0 / LightsSize;
    texCoord = Position.xy;
    stepX = 2.0 * LIGHTRANGE / float(LIGHTVOLX);
    stepZ = LIGHTRANGE / float(LIGHTVOLZ);

    vec4 tmpCount = texture(LightsSampler, vec2(1.0, 0.0) - (1.0 / LightsSize) * 0.5);
    count = 0.0;
    if (tmpCount.a == 69.0 / 255.0) {
        tmpCount.a = 1.0;
        count = float(decodeInt(tmpCount));
    }
}
