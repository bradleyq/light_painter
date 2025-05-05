#version 150

#moj_import <minecraft:utils.glsl>

uniform sampler2D SearchLayerSampler;
uniform vec2 SearchLayerSize;
uniform int Test;

in vec2 texCoord;
flat in vec2 oneTexel;

out vec4 outColor;

void main() {
    outColor = vec4(0.0);
    vec2 samplepos = gl_FragCoord.xy - 0.5;
    samplepos = vec2(samplepos.x * float(AGGSTEP0), samplepos.y);
    if (samplepos.x < SearchLayerSize.x) {
        float tmpCounter = 0.0;
        for (int i = 0; i < AGGSTEP0; i += 1) {
            tmpCounter += float(texture(SearchLayerSampler, (vec2(samplepos.x + float(i), samplepos.y) + 0.5) * oneTexel).a == 1.0);
        }
        tmpCounter /= 255.0;
        outColor = vec4(vec3(tmpCounter), 1.0);
        if (Test == 1) {
            outColor.rgb /= tmpCounter == 0.0 ? 1.0 : outColor.r;
            outColor.rgb += vec3(0.2, 0.0, 0.0);
        }
    }

    if (abs(gl_FragCoord.x - 1.0) < 0.01) {
        outColor.rgb = vec3(0.0, 1.0, 0.0);
    }
}