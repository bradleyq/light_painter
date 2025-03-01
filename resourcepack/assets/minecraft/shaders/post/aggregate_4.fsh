#version 150

uniform sampler2D DiffuseSampler;
uniform vec2 DiffuseSize;
uniform float Step;
uniform float Test;

in vec2 texCoord;
flat in vec2 oneTexel;

out vec4 outColor;

void main() {
    outColor = texture(DiffuseSampler, texCoord);
    float width = ceil(DiffuseSize.x / Step);
    float width2 = ceil(width / Step);
    float height = ceil(DiffuseSize.y / Step);
    vec2 samplepos = gl_FragCoord.xy - 0.5;
    samplepos = vec2(samplepos.x - width2, samplepos.y * Step);
    if (samplepos.x >= 2.0 * width && samplepos.x < 2.0 * width + width2 && samplepos.y < height) {
        float tmpCounter = 0.0;
        for (int i = 0; i < int(Step); i += 1) {
            tmpCounter += float(texture(DiffuseSampler, (vec2(samplepos.x, samplepos.y + float(i)) + 0.5) * oneTexel).b * 255.0);
        }
        tmpCounter /= 255.0;
        outColor = vec4(vec3(tmpCounter), 1.0);
        if (Test > 0.5) {
            outColor.rgb /= tmpCounter == 0.0 ? 1.0 : outColor.r;
            outColor.rgb += vec3(0.6, 0.0, 0.0);
        }
    }
}