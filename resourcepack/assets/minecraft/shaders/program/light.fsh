#version 150

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D LightsSampler;
uniform float Range;

in vec2 texCoord;
flat in vec2 oneTexel;
flat in vec2 oneTexelAux1;
flat in float aspectRatio;
flat in float conversionK;
flat in float count;

out vec4 outColor;

#define BIG 100000
#define LR 8.0
#define FIXEDPOINT 1000.0
#define NEAR 0.05
#define FAR 1024.0
#define SPREAD 1.2
#define BOOST 2.5
#define CUTOFF 0.02

float luminance(vec3 rgb) {
    return max(max(rgb.r, rgb.g), rgb.b);
}

int decodeInt(vec4 ivec) {
    ivec.rgb *= 255.0;
    int num = 0;
    num += int(ivec.r);
    num += int(ivec.g) * 255;
    num += int(ivec.b) * 255 * 255;
    return num * int(floor(4.0 * (ivec.a - 0.75) + 0.5));
}

vec4 decodeAlphaHDR(vec4 color) {
    return vec4(color.rgb * (1.0 + clamp(color.a - 26.0 / 255.0, 0.0, 1.0) * 3.0 * 255.0 / 224.0), 1.0);
}

vec4 encodeAlphaHDR(vec3 color) {
    float me = clamp(max(max(color.r, color.g), color.b), 1.0, 4.0);
    return vec4(color.rgb / me, 26.0 / 255.0 + (me - 1.0) * 224.0 / 255.0 / 3.0);
}
  
float LinearizeDepth(float depth) {
    float z = depth * 2.0 - 1.0;
    return 2.0 * (NEAR * FAR) / (FAR + NEAR - z * (FAR - NEAR));    
}

void main() {
    outColor = vec4(0.0);
    float depth = LinearizeDepth(texture(DiffuseDepthSampler, texCoord).r);
    if (depth < Range + LR) {
        outColor = decodeAlphaHDR(texture(DiffuseSampler, texCoord));
        vec4 aggColor = vec4(0.0, 0.0, 0.0, 1.0);

        vec2 pixCoord = texCoord;
        vec2 screenCoord = (pixCoord - vec2(0.5)) * vec2(aspectRatio, 1.0);
        float conversion = conversionK * depth;
        vec3 worldCoord = vec3(screenCoord * conversion, depth);

        for (int i = 0; i < int(count); i += 1) {
            vec4 xvec = texture(LightsSampler, (vec2(float(i), 0.0) + 0.5) * oneTexelAux1);
            vec4 yvec = texture(LightsSampler, (vec2(float(i), 1.0) + 0.5) * oneTexelAux1);
            vec4 zvec = texture(LightsSampler, (vec2(float(i), 2.0) + 0.5) * oneTexelAux1);
            vec3 lightWorldCoord = vec3(decodeInt(xvec), decodeInt(yvec), decodeInt(zvec)) / FIXEDPOINT;
            float lightDist = length(worldCoord - lightWorldCoord);
            if (lightDist < LR) {
                vec3 lightColor = texture(LightsSampler, (vec2(float(i), 3.0) + 0.5) * oneTexelAux1).rgb;
                vec2 lightPos = lightWorldCoord.xy / (lightWorldCoord.z * conversionK) * vec2(1.0 / aspectRatio, 1.0);
                lightPos = 0.5 - abs(lightPos);
                aggColor.rgb += clamp((pow(1.0 / (lightDist + SPREAD), 2.0) - CUTOFF) * BOOST, 0.0, 1.0) * lightColor * clamp(Range - length(lightWorldCoord), 0.0, 6.0) * clamp(min(lightPos.x, lightPos.y), 0.0, 0.05) * 20.0 / 6.0;
            }
        }
        outColor = encodeAlphaHDR(mix(outColor.rgb, aggColor.rgb, 0.7));
    }
}
