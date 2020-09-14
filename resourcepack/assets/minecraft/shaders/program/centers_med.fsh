#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform float DepthTolerance;
uniform float PhysicalR;

varying vec2 texCoord;
varying vec2 oneTexel;
varying float pixSearchR;
varying float pixFocal;

#define NEAR 0.1 
#define FAR 1000.0

float LinearizeDepth(float depth) {
    float z = depth * 2.0 - 1.0;
    return (NEAR * FAR) / (FAR + NEAR - z * (FAR - NEAR));    
}

void main() {
    float alpha = texture2D(DiffuseSampler, texCoord).a;
    float depth = LinearizeDepth(texture2D(DiffuseDepthSampler, texCoord).r);
    vec4 outColor = vec4(0.0);
    if (alpha == 1.0) {
        vec2 center = vec2(0.0);
        vec3 aggColor = vec3(0.0);
        float count = 0.001;
        float searchRadius = min(floor(pixFocal * PhysicalR / depth * 1.5 + 0.5), pixSearchR);
        for (float i = -searchRadius; i <= searchRadius; i += 1.0) {
            for (float j = -searchRadius; j <= searchRadius; j += 1.0) {
                vec4 tmpCol = texture2D(DiffuseSampler, texCoord + vec2(i, j) * oneTexel);
                float tmpDepth = LinearizeDepth(texture2D(DiffuseDepthSampler, texCoord + vec2(i, j) * oneTexel).r);
                if (tmpCol.a == 1.0 && tmpDepth - depth < DepthTolerance && depth - tmpDepth < DepthTolerance) {
                    aggColor += tmpCol.rgb;
                    center += vec2(i,j); 
                    count += 1.0;
                }
            }
        }
        center /= count;
        aggColor /= count;

        if (all(equal(floor(center + vec2(0.5)), vec2(0.0)))) {
            outColor = vec4(aggColor, 1.0);
        }
    }

    gl_FragColor = outColor;
}