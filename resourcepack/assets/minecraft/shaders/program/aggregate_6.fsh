#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D ColoredCentersSampler;
uniform vec2 InSize;
uniform float Step;
uniform float Test;

varying vec2 texCoord;
varying vec2 oneTexel;
varying float aspectRatio;

#define BIG 1000000

int intmod(int i, int base) {
    return i - (i / base * base);
}

vec3 encodeInt(int i) {
    int r = intmod(i, 255);
    i = i / 255;
    int g = intmod(i, 255);
    i = i / 255;
    int b = intmod(i, 255);
    return vec3(float(r) / 255.0, float(g) / 255.0, float(b) / 255.0);
}

void main() {
    vec4 outColor = texture2D(DiffuseSampler, texCoord);
    float width = ceil(InSize.x / Step);
    float width2 = ceil(width / Step);
    float height = ceil(InSize.y / (Step));
    float height2 = ceil(height / (Step));
    vec2 pos = gl_FragCoord.xy - 0.5;
    float targetNum = pos.x + 1.0;

    if (pos.y <= 1.0) {
        vec2 samplepos = vec2(2.0 * width + 2.0 * width2, 0.0);
        float tmpCounter = 0.0;
        float status = 0.0;
        int px = 0;
        int py = 0;
        for (int iter = 0; iter < int(width2); iter += 1) {
            float l0count = texture2D(DiffuseSampler, (vec2(samplepos.x + float(iter), 0.0) + 0.5) / InSize).r * 255.0;
            if (tmpCounter + l0count >= targetNum) {
                status = 1.0;
                px = iter;
                iter = BIG;
            } else {
                tmpCounter += l0count;
            }
        }

        outColor = vec4(encodeInt(int(tmpCounter)), 69.0 / 255.0);

        if (status == 1.0) {
            samplepos = vec2(2.0 * width + width2 + float(px), 0.0);
            for (int iter = 0; iter < int(height2); iter += 1) {
                float l1count = texture2D(DiffuseSampler, (vec2(samplepos.x, float(iter)) + 0.5) / InSize).r * 255.0;
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
            py *= int(Step);
            samplepos = vec2(2.0 * width + float(px), float(py));
            for (int iter = 0; iter < int(Step); iter += 1) {
                float l2count = texture2D(DiffuseSampler, (vec2(samplepos.x, samplepos.y + float(iter)) + 0.5) / InSize).r * 255.0;
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
            px *= int(Step);
            samplepos = vec2(width + float(px), float(py));
            for (int iter = 0; iter < int(Step); iter += 1) {
                float l3count = texture2D(DiffuseSampler, (vec2(samplepos.x + float(iter), samplepos.y) + 0.5) / InSize).r * 255.0;
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
            py *= int(Step);
            samplepos = vec2(float(px), float(py));
            for (int iter = 0; iter < int(Step); iter += 1) {
                float l4count = texture2D(DiffuseSampler, (vec2(samplepos.x, samplepos.y + float(iter)) + 0.5) / InSize).r * 255.0;
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
            px *= int(Step);
            samplepos = vec2(float(px), float(py));
            for (int iter = 0; iter < int(Step); iter += 1) {
                float isLight = texture2D(ColoredCentersSampler, (vec2(samplepos.x + float(iter), samplepos.y) + 0.5) / InSize).a;
                if (tmpCounter + isLight == targetNum) {
                    px += iter;
                    if (pos.y == 0.0) {
                        outColor = vec4(encodeInt(px), 1.0);
                    } else {
                        outColor = vec4(encodeInt(py), 1.0);
                    }
                    iter = BIG;
                } else {
                    tmpCounter += isLight;
                }
            }
        }

        if (Test > 0.5 && outColor.a == 0.0) {
            outColor += vec4(0.0, 0.2, 0.0, 1.0);
        }
    }

    gl_FragColor = outColor;
}