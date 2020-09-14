#version 110

uniform sampler2D DiffuseSampler;
uniform vec2 InSize;
uniform float Step;
uniform float Test;

varying vec2 texCoord;
varying vec2 oneTexel;
varying float aspectRatio;

void main() {
    vec4 outColor = texture2D(DiffuseSampler, texCoord);
    float width = ceil(InSize.x / Step);
    float height = ceil(InSize.y / Step);
    vec2 samplepos = gl_FragCoord.xy - 0.5;
    samplepos = vec2((samplepos.x - 2.0 * width) * Step + width, samplepos.y);
    if (samplepos.x >= width && samplepos.x < 2.0 * width && samplepos.y < height) {
        float tmpCounter = 0.0;
        for (int i = 0; i < int(Step); i += 1) {
            tmpCounter += float(texture2D(DiffuseSampler, (vec2(samplepos.x + float(i), samplepos.y) + 0.5) / InSize).b * 255.0);
        }
        tmpCounter /= 255.0;
        outColor = vec4(vec3(tmpCounter), 1.0);
        if (Test > 0.5) {
            outColor.rgb /= tmpCounter == 0.0 ? 1.0 : outColor.r;
            outColor.rgb += vec3(0.5, 0.0, 0.0);
        }
    }

    gl_FragColor = outColor;
}