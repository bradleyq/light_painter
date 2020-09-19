#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D CompareDepthSampler;
uniform sampler2D ItemEntityDepthSampler;
uniform sampler2D LightsCoordSampler;
uniform sampler2D ColoredCentersSampler;
uniform float Range;

varying vec2 texCoord;
varying vec2 oneTexel;
varying float aspectRatio;
varying float conversionK;

#define BIG 100000
#define LR 20.0

float luminance(vec3 rgb) {
    return max(max(rgb.r, rgb.g), rgb.b);
}

int decodeInt(vec3 ivec) {
    ivec *= 255.0;
    int num = 0;
    num += int(ivec.r);
    num += int(ivec.g) * 255;
    num += int(ivec.b) * 255 * 255;
    return num;
}

vec4 decodeAlphaHDR(vec4 color) {
    return vec4(color.rgb * (1.0 + clamp(color.a - 26.0 / 255.0, 0.0, 1.0) * 3.0 * 255.0 / 224.0), 1.0);
}

vec4 encodeAlphaHDR(vec4 color) {
    float me = clamp(max(max(color.r, color.g), color.b), 1.0, 4.0);
    return vec4(color.rgb / me, 26.0 / 255.0 + (me - 1.0) * 224.0 / 255.0 / 3.0);
}

#define NEAR 0.1 
#define FAR 1000.0
  
float LinearizeDepth(float depth) {
    float z = depth * 2.0 - 1.0;
    return (NEAR * FAR) / (FAR + NEAR - z * (FAR - NEAR));    
}

void main() {
    vec4 outColor = vec4(0.0);
    float oDepth = texture2D(DiffuseDepthSampler, texCoord).r;
    float compDepth = texture2D(CompareDepthSampler, texCoord).r;
    float depth = LinearizeDepth(oDepth);
    if (oDepth < compDepth && depth < Range + LR) {
        outColor = decodeAlphaHDR(texture2D(DiffuseSampler, texCoord));
        vec4 aggColor = vec4(0.0, 0.0, 0.0, 1.0);

        vec2 pixCoord = texCoord;
        vec2 screenCoord = (pixCoord - vec2(0.5)) * vec2(aspectRatio, 1.0);
        float conversion = conversionK * depth;
        vec3 worldCoord = vec3(screenCoord * conversion, depth);

        vec4 tmpCount = texture2D(LightsCoordSampler, vec2(1.0, 0.0));
        int count = decodeInt(tmpCount.rgb) * int(tmpCount.a == 69.0 / 255.0);

        for (int i = 0; i < count; i += 1) {
            vec3 xvec = texture2D(LightsCoordSampler, (vec2(float(i), 0.0) + 0.5) * oneTexel).rgb;
            vec3 yvec = texture2D(LightsCoordSampler, (vec2(float(i), 1.0) + 0.5) * oneTexel).rgb;
            vec2 lightPos = vec2(decodeInt(xvec), decodeInt(yvec));
            lightPos = (lightPos + 0.5) * oneTexel;
            float lightDepth = LinearizeDepth(texture2D(ItemEntityDepthSampler, lightPos).r);
            vec2 lightScreenCoord = (lightPos - vec2(0.5)) * vec2(aspectRatio, 1.0);
            float lightConversion = conversionK * lightDepth;
            vec3 lightWorldCoord = vec3(lightScreenCoord * lightConversion, lightDepth);
            float lightDist = length(worldCoord - lightWorldCoord);

            if (lightDist < LR) {
                vec3 lightColor = texture2D(ColoredCentersSampler, lightPos).rgb;
                lightPos = 0.5 - abs(lightPos - 0.5);
                aggColor.rgb += clamp((pow(1.0 / (lightDist + 3.0), 2.0) - 0.01) * 9.0, 0.0, 1.0) * lightColor * clamp(Range - lightDepth, 0.0, 6.0) * clamp(min(lightPos.x, lightPos.y), 0.0, 0.05) * 20.0 / 6.0;
            }
        }
        outColor.rgb = mix(outColor.rgb, aggColor.rgb, 0.7);
    }


    gl_FragColor = encodeAlphaHDR(outColor);
}
