#version 120

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D LightsSampler;
uniform vec2 InSize;
uniform float Range;

varying vec2 texCoord;
varying vec2 oneTexel;
varying float aspectRatio;
varying float conversionK;

#define BIG 100000
#define LR 8.0
#define FIXEDPOINT 1000.0

float luminance(vec3 rgb) {
    return max(max(rgb.r, rgb.g), rgb.b);
}

int decodeInt(vec4 ivec) {
    ivec *= 255.0;
    int num = 0;
    num += int(ivec.r);
    num += int(ivec.g) * 255;
    num += int(ivec.b) * 255 * 255;
    return num * int(floor(4.0 * (ivec.a - 0.75) + 0.5));
}

#define NEAR 0.1 
#define FAR 1000.0
  
float LinearizeDepth(float depth) {
    float z = depth * 2.0 - 1.0;
    return (NEAR * FAR) / (FAR + NEAR - z * (FAR - NEAR));    
}

void main() {
    vec4 outColor = vec4(0.0);
    float depth = LinearizeDepth(texture2D(DiffuseDepthSampler, texCoord).r);
    if (depth < Range + LR) {

        outColor = texture2D(DiffuseSampler, texCoord);
        vec4 aggColor = vec4(0.0, 0.0, 0.0, 1.0);

        vec2 pixCoord = texCoord;
        vec2 screenCoord = (pixCoord - vec2(0.5)) * vec2(aspectRatio, 1.0);
        float conversion = conversionK * depth;
        vec3 worldCoord = vec3(screenCoord * conversion, depth);
        vec4 tmpCount = texture2D(LightsSampler, vec2(1.0, 0.0));
        int count = 0;
        // if (tmpCount.a == 69.0 / 255.0) {
        //     tmpCount.a = 1.0;
        //     count = decodeInt(tmpCount);
        // }

        for (int i = 0; i < count; i += 1) {
            vec4 xvec = texture2D(LightsSampler, (vec2(float(i), 0.0) + 0.5) * oneTexel);
            vec4 yvec = texture2D(LightsSampler, (vec2(float(i), 1.0) + 0.5) * oneTexel);
            vec4 zvec = texture2D(LightsSampler, (vec2(float(i), 2.0) + 0.5) * oneTexel);
            vec3 lightWorldCoord = vec3(float(decodeInt(xvec)) / FIXEDPOINT, float(decodeInt(yvec)) / FIXEDPOINT, float(decodeInt(zvec)) / FIXEDPOINT);
            float lightDist = length(worldCoord - lightWorldCoord);
            if (lightDist <= LR) {
                vec3 lightColor = texture2D(LightsSampler, (vec2(float(i), 3.0) + 0.5) * oneTexel).rgb;
                lightColor /= max(max(lightColor.r, max(lightColor.g, lightColor.b)), 0.01);
                aggColor.rgb += clamp((pow(1.0 / (lightDist + 3.0), 2.0) - 0.01) * 9.0, 0.0, 1.0) * lightColor * clamp(Range - length(lightWorldCoord), 0.0, 3.0) / 3.0;
            }

        }
        outColor = vec4(mix(outColor.rgb, aggColor.rgb, 0.9), 1.0);

    }


    gl_FragColor = outColor;
}
