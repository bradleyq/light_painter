#version 150

#moj_import <minecraft:utils.glsl>

uniform sampler2D SearchLayerSampler;
uniform vec2 SearchLayerSize;
uniform int Test;

in vec2 texCoord;
flat in vec2 oneTexel;

out vec4 outColor;

void main() {
    outColor = texture(SearchLayerSampler, texCoord);
    float width = ceil(SearchLayerSize.x / float(AGGSTEP0));
    float width2 = ceil(width / float(AGGSTEP1));
    float height = ceil(SearchLayerSize.y / float(AGGSTEP0));
    vec2 samplepos = gl_FragCoord.xy - 0.5;
    samplepos = vec2(samplepos.x - width2, samplepos.y * float(AGGSTEP1));
    if (samplepos.x >= 2.0 * width && samplepos.x < 2.0 * width + width2 && samplepos.y < height) {
        float tmpCounter = 0.0;
        for (int i = 0; i < AGGSTEP1; i += 1) {
            tmpCounter += float(texture(SearchLayerSampler, (vec2(samplepos.x, samplepos.y + float(i)) + 0.5) * oneTexel).b * 255.0);
        }
        tmpCounter /= 255.0;
        outColor = vec4(vec3(tmpCounter), 1.0);
        if (Test == 1) {
            outColor.rgb /= tmpCounter == 0.0 ? 1.0 : outColor.r;
            outColor.rgb += vec3(0.6, 0.0, 0.0);
        }
    }
}