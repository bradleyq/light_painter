#version 150

uniform sampler2D InSampler;
uniform vec2 InSize;
uniform float Step;

in vec2 texCoord;
flat in vec2 oneTexel;

out vec4 outColor;

void main() {
    outColor = vec4(0.0);
    vec2 samplepos = gl_FragCoord.xy - 0.5;
    samplepos = vec2(samplepos.x * Step, samplepos.y);
    if (samplepos.x < InSize.x) {
        float tmpCounter = 0.0;
        for (int i = 0; i < int(Step); i += 1) {
            tmpCounter += float(texture(InSampler, (vec2(samplepos.x + float(i), samplepos.y) + 0.5) * oneTexel).a == 1.0);
        }
        tmpCounter /= 255.0;
        outColor = vec4(vec3(tmpCounter), 1.0);
    }

    if (abs(gl_FragCoord.x - 1.0) < 0.01) {
        outColor.rgb = vec3(0.0, 1.0, 0.0);
    }
}