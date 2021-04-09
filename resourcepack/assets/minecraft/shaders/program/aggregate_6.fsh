#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D ItemEntityDepthSampler;
uniform sampler2D ColoredCentersSampler;
uniform vec2 InSize;
uniform float Step;
uniform float Test;

in vec2 texCoord;
flat in vec2 inOneTexel;
flat in float inAspectRatio;
flat in float conversionK;

out vec4 outColor;

#define BIG 1000000
#define NEAR 0.05
#define FAR 1024.0
#define FIXEDPOINT 1000.0
#define DSCALE 10.0

int intmod(int i, int base) {
    return i - (i / base * base);
}

vec4 encodeInt(int i) {
    float a = 1.0;
    if (i < 0) {
        i *= -1;
        a = 0.5;
    }
    int r = intmod(i, 255);
    i = i / 255;
    int g = intmod(i, 255);
    i = i / 255;
    int b = intmod(i, 255);
    return vec4(float(r) / 255.0, float(g) / 255.0, float(b) / 255.0, a);
}

float LinearizeDepth(float depth) {
    float z = depth * 2.0 - 1.0;
    return 2.0 * (NEAR * FAR) / (FAR + NEAR - z * (FAR - NEAR)) * DSCALE;    
}


void main() {
    outColor = texture(DiffuseSampler, texCoord);
    float width = ceil(InSize.x / Step);
    float width2 = ceil(width / Step);
    float height = ceil(InSize.y / (Step));
    float height2 = ceil(height / (Step));
    vec2 pos = gl_FragCoord.xy - 0.5;
    float targetNum = pos.x + 1.0;

    vec2 samplepos = vec2(2.0 * width + 2.0 * width2, 0.0);
    float tmpCounter = 0.0;
    float status = 0.0;
    int px = 0;
    int py = 0;
    for (int iter = 0; iter < int(width2); iter += 1) {
        float l0count = texture(DiffuseSampler, (vec2(samplepos.x + float(iter), 0.0) + 0.5) / InSize).r * 255.0;
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
            float l1count = texture(DiffuseSampler, (vec2(samplepos.x, float(iter)) + 0.5) / InSize).r * 255.0;
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
            float l2count = texture(DiffuseSampler, (vec2(samplepos.x, samplepos.y + float(iter)) + 0.5) / InSize).r * 255.0;
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
            float l3count = texture(DiffuseSampler, (vec2(samplepos.x + float(iter), samplepos.y) + 0.5) / InSize).r * 255.0;
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
            float l4count = texture(DiffuseSampler, (vec2(samplepos.x, samplepos.y + float(iter)) + 0.5) / InSize).r * 255.0;
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
        px *= int(Step);
        samplepos = vec2(float(px), float(py));
        for (int iter = 0; iter < int(Step); iter += 1) {
            sampleColor = texture(ColoredCentersSampler, (vec2(samplepos.x + float(iter), samplepos.y) + 0.5) / InSize);
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
        float lightDepth = LinearizeDepth(texture(ItemEntityDepthSampler, samplepos).r);
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

        if (Test > 0.5 && outColor.a == 0.0) {
            outColor += vec4(0.0, 0.2, 0.0, 1.0);
        }
    }
}