#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform float Range;

varying vec2 texCoord;

#define NEAR 0.1 
#define FAR 1000.0

float LinearizeDepth(float depth) {
    float z = depth * 2.0 - 1.0;
    return (NEAR * FAR) / (FAR + NEAR - z * (FAR - NEAR));    
}

void main() {
    vec4 outColor = vec4(0.0);
    vec4 candidate = texture2D(DiffuseSampler, texCoord);

    if (candidate.a == 1.0) {
        float depth = LinearizeDepth(texture2D(DiffuseDepthSampler, texCoord).r);
        if (depth > 0.2 && depth < Range) {
            outColor = candidate;
        }
    }

    gl_FragColor = outColor;
}