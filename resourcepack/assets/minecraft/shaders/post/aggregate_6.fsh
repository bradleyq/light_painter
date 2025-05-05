#version 150

#moj_import <minecraft:utils.glsl>
#moj_import <minecraft:texint.glsl>

uniform sampler2D SearchLayerSampler;
uniform sampler2D ItemEntityDepthSampler;
uniform sampler2D ColoredCentersSampler;
uniform vec2 SearchLayerSize;
uniform int Test;

in vec2 texCoord;
flat in vec2 inOneTexel;
flat in float inAspectRatio;
flat in float conversionK;

out vec4 outColor;

void main() {
    if (Test == 1) {
        outColor = texture(SearchLayerSampler, texCoord);
    }
    float width = ceil(SearchLayerSize.x / float(AGGSTEP0));
    float width2 = ceil(width / float(AGGSTEP1));
    float height = ceil(SearchLayerSize.y / float(AGGSTEP0));
    float height2 = ceil(height / float(AGGSTEP1));
    vec2 pos = gl_FragCoord.xy - 0.5;
    float targetNum = pos.x + 1.0;

    vec2 samplepos = vec2(2.0 * width + 2.0 * width2, 0.0);
    float tmpCounter = 0.0;
    float status = 0.0;
    int px = 0;
    int py = 0;
    for (int iter = 0; iter < int(width2); iter += 1) {
        float l0count = texture(SearchLayerSampler, (vec2(samplepos.x + float(iter), 0.0) + 0.5) / SearchLayerSize).r * 255.0;
        if (tmpCounter + l0count >= targetNum) {
            status = 1.0;
            px = iter;
            iter = BIG;
        } else {
            tmpCounter += l0count;
        }
    }

    outColor = vec4(encodeInt(int(tmpCounter)).rgb, 69.0 / 255.0);

    if (status == 1.0) {
        samplepos = vec2(2.0 * width + width2 + float(px), 0.0);
        for (int iter = 0; iter < int(height2); iter += 1) {
            float l1count = texture(SearchLayerSampler, (vec2(samplepos.x, float(iter)) + 0.5) / SearchLayerSize).r * 255.0;
            if (tmpCounter + l1count >= targetNum) {
                status = 2.0;
                py = iter;
                iter = BIG;
            } else {
                tmpCounter += l1count;
            }
        }
    }

    if (status == 2.0) {
        py *= int(AGGSTEP1);
        samplepos = vec2(2.0 * width + float(px), float(py));
        for (int iter = 0; iter < int(AGGSTEP1); iter += 1) {
            float l2count = texture(SearchLayerSampler, (vec2(samplepos.x, samplepos.y + float(iter)) + 0.5) / SearchLayerSize).r * 255.0;
            if (tmpCounter + l2count >= targetNum) {
                status = 3.0;
                py += iter;
                iter = BIG;
            } else {
                tmpCounter += l2count;
            }
        }
    }

    if (status == 3.0) {
        px *= int(AGGSTEP1);
        samplepos = vec2(width + float(px), float(py));
        for (int iter = 0; iter < int(AGGSTEP1); iter += 1) {
            float l3count = texture(SearchLayerSampler, (vec2(samplepos.x + float(iter), samplepos.y) + 0.5) / SearchLayerSize).r * 255.0;
            if (px + iter < int(width) && tmpCounter + l3count >= targetNum) {
                status = 4.0;
                px += iter;
                iter = BIG;
            } else {
                tmpCounter += l3count;
            }
        }
    }

    if (status == 4.0) {
        py *= int(AGGSTEP0);
        samplepos = vec2(float(px), float(py));
        for (int iter = 0; iter < int(AGGSTEP0); iter += 1) {
            float l4count = texture(SearchLayerSampler, (vec2(samplepos.x, samplepos.y + float(iter)) + 0.5) / SearchLayerSize).r * 255.0;
            if (tmpCounter + l4count >= targetNum) {
                status = 5.0;
                py += iter;
                iter = BIG;
            } else {
                tmpCounter += l4count;
            }
        }
    }

    if (status == 5.0) {
        vec4 sampleColor;
        px *= int(AGGSTEP0);
        samplepos = vec2(float(px), float(py));
        for (int iter = 0; iter < int(AGGSTEP0); iter += 1) {
            sampleColor = texture(ColoredCentersSampler, (vec2(samplepos.x + float(iter), samplepos.y) + 0.5) / SearchLayerSize);
            float isLight = sampleColor.a;
            if (tmpCounter + isLight == targetNum) {
                px += iter;
                iter = BIG;
            } else {
                tmpCounter += isLight;
            }
        }

        samplepos = vec2(px, py);
        samplepos = (samplepos + 0.5) * inOneTexel;
        float lightDepth = LinearizeDepth(texture(ItemEntityDepthSampler, samplepos).r / LIGHTDEPTH);
        samplepos = (samplepos - vec2(0.5)) * vec2(inAspectRatio, 1.0);
        vec3 lightWorldCoord = vec3(samplepos * conversionK * lightDepth, lightDepth);

        if (pos.y == 0.0) {
            outColor = encodeInt(int(lightWorldCoord.x * FIXEDPOINT));
        } else if (pos.y == 1.0) {
            outColor = encodeInt(int(lightWorldCoord.y * FIXEDPOINT));
        } else if (pos.y == 2.0) {
            outColor = encodeInt(int(lightWorldCoord.z * FIXEDPOINT));
        } else {
            outColor = sampleColor;
        }

        if (Test == 1 && outColor.a == 0.0) {
            outColor += vec4(0.0, 0.2, 0.0, 1.0);
        }
    }
}