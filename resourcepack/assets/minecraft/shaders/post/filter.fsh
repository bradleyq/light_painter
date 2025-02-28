#version 150

uniform sampler2D InSampler;
uniform sampler2D InDepthSampler;
uniform float Range;

in vec2 texCoord;

out vec4 outColor;

#define NEAR 0.05
#define FAR 1024.0
#define DSCALE 10.0

float LinearizeDepth(float depth) {
    float z = depth * 2.0 - 1.0;
    return 2.0 * (NEAR * FAR) / (FAR + NEAR - z * (FAR - NEAR)) * DSCALE;    
}

void main() {
    outColor = vec4(0.0);
    vec4 candidate = texture(InSampler, texCoord);

    if (candidate.a * 255 == 254.0 && candidate.r < 1.0 &&  candidate.g < 1.0 &&  candidate.b < 1.0) {
        candidate *= 255.0 / 254.0;
        float depth = LinearizeDepth(texture(InDepthSampler, texCoord).r);
        if (depth < Range) {
            outColor = candidate;
        }
    }
}