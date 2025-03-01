#version 150

#moj_import <minecraft:utils.glsl>

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform float Range;

in vec2 texCoord;

out vec4 outColor;

float LinearizeDepth(float depth) {
    float z = depth * 2.0 - 1.0;
    return 2.0 * (NEAR * FAR) / (FAR + NEAR - z * (FAR - NEAR)) * DSCALE;    
}

void main() {
    outColor = vec4(0.0);
    vec4 candidate = texture(DiffuseSampler, texCoord);

    if (candidate.a == LIGHTALPHA) {
        candidate.rgb /= candidate.a;
        candidate.a = 1.0;

        float depth = LinearizeDepth(texture(DiffuseDepthSampler, texCoord).r);
        if (depth < Range) {
            outColor = candidate;
        }
    }
}