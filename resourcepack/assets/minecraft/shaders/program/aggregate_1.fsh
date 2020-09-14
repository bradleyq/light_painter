#version 110

uniform sampler2D DiffuseSampler;
uniform vec2 InSize;
uniform float Step;
uniform float Test;

varying vec2 texCoord;
varying vec2 oneTexel;
varying float aspectRatio;

void main() {
    vec4 outColor = vec4(0.0);
    vec2 samplepos = gl_FragCoord.xy - 0.5;
    samplepos = vec2(samplepos.x * Step, samplepos.y);
    if (samplepos.x < InSize.x) {
        float tmpCounter = 0.0;
        for (int i = 0; i < int(Step); i += 1) {
            tmpCounter += float(texture2D(DiffuseSampler, (vec2(samplepos.x + float(i), samplepos.y) + 0.5) / InSize).a == 1.0);
        }
        tmpCounter /= 255.0;
        outColor = vec4(vec3(tmpCounter), 1.0);
        if (Test > 0.5) {
            outColor.rgb /= tmpCounter == 0.0 ? 1.0 : outColor.r;
            outColor.rgb += vec3(0.2, 0.0, 0.0);
        }
    }

    if (abs(gl_FragCoord.x - 1.0) < 0.01) {
        outColor.rgb = vec3(0.0, 1.0, 0.0);
    }

    gl_FragColor = outColor;
}