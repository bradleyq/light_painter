#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform float DepthTolerance;
uniform float PhysicalR;

varying vec2 texCoord;
varying vec2 oneTexel;
varying float aspectRatio;
varying float pixTol;
varying float pixMax;
varying float Focal;

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
        float minr = 0.0;
        float valid = 0.0;
        float isCenter = 1.0;

        vec2 offsets = (texCoord - vec2(0.5)) * vec2(aspectRatio, 1.0);
        offsets = offsets * offsets;
        offsets += vec2(Focal * Focal);
        offsets = pow(offsets, vec2(0.5));
        offsets = vec2(Focal) / offsets;
        offsets = (offsets - 1.0 / offsets) * Focal * PhysicalR / depth;

        for (float i = 0.0; i < pixMax;) {
            i += 1.0;
            valid = 0.0;
            vec2 tmpCoord = texCoord + vec2(i, 0.0) * oneTexel + vec2(clamp(offsets.x, 0.0, 10000.0), 0.0);
            valid += float(texture2D(DiffuseSampler, tmpCoord).a == 1.0 && LinearizeDepth(texture2D(DiffuseDepthSampler, tmpCoord).r) - DepthTolerance < depth);
            tmpCoord = texCoord + vec2(-i, 0.0) * oneTexel + vec2(clamp(offsets.x, -10000.0, 0.0), 0.0);
            valid += float(texture2D(DiffuseSampler, tmpCoord).a == 1.0 && LinearizeDepth(texture2D(DiffuseDepthSampler, tmpCoord).r) - DepthTolerance < depth);
            tmpCoord = texCoord + vec2(0.0, i) * oneTexel + vec2(0.0, clamp(offsets.y, 0.0, 10000.0));
            valid += float(texture2D(DiffuseSampler, tmpCoord).a == 1.0 && LinearizeDepth(texture2D(DiffuseDepthSampler, tmpCoord).r) - DepthTolerance < depth);
            tmpCoord = texCoord + vec2(0.0, -i) * oneTexel + vec2(0.0, clamp(offsets.y, -10000.0, 0.0));
            valid += float(texture2D(DiffuseSampler, tmpCoord).a == 1.0 && LinearizeDepth(texture2D(DiffuseDepthSampler, tmpCoord).r) - DepthTolerance < depth);

            if (valid == 4.0) {
                minr = i;
            }
            if (valid > 0.0 && i > minr + pixTol) {
                isCenter = 0.0;
            }
            if (valid == 0.0 || i > minr + pixTol) {
                i += pixMax;
            }
        }

        if (depth < 6.0 && minr * oneTexel.y < (PhysicalR * 0.5) * Focal / depth) {
            isCenter = 0.0;
        }

        if (isCenter == 1.0) {
            outColor = texture2D(DiffuseSampler, texCoord);
        }
    }

    gl_FragColor = outColor;
}