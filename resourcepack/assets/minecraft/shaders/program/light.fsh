#version 110

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D ItemEntityDepthSampler;
uniform sampler2D LightsCoordSampler;
uniform sampler2D ColoredCentersSampler;
uniform vec2 InSize;
uniform float FOV;
uniform float Range;

varying vec2 texCoord;
varying float aspectRatio;

#define BIG 1000000

float luminance(vec3 rgb) {
    return max(max(rgb.r, rgb.g), rgb.b);
}

int decodeInt(vec3 ivec) {
    int num = 0;
    num += int(ivec.r * 255.0);
    num += int(ivec.g * 255.0) * 255;
    num += int(ivec.b * 255.0) * 255 * 255;
    return num;
}

#define NEAR 0.1 
#define FAR 1000.0
  
float LinearizeDepth(float depth) {
    float z = depth * 2.0 - 1.0;
    return (NEAR * FAR) / (FAR + NEAR - z * (FAR - NEAR));    
}

void main() {
    vec4 outColor = texture2D(DiffuseSampler, texCoord);
    vec4 aggColor = vec4(0.0, 0.0, 0.0, 1.0);
    float depth = LinearizeDepth(texture2D(DiffuseDepthSampler, texCoord).r);

    vec2 pixCoord = texCoord;
    vec2 screenCoord = (pixCoord - vec2(0.5)) * vec2(aspectRatio, 1.0);
    float conversion = tan(FOV / 360.0 * 3.14159265358979) * 2.0 * depth;
    vec3 worldCoord = vec3(screenCoord * conversion, depth);
    for (int i = 0; i < int(InSize); i += 1) {
        vec4 xvec = texture2D(LightsCoordSampler, (vec2(float(i), 0.0) + 0.5) / InSize);
        if (xvec.a > 0.5) {
            vec3 yvec = texture2D(LightsCoordSampler, (vec2(float(i), 1.0) + 0.5) / InSize).rgb;
            vec2 lightPos = vec2(decodeInt(xvec.rgb), decodeInt(yvec));
            lightPos = (lightPos + 0.5) / InSize;
            float lightDepth = LinearizeDepth(texture2D(ItemEntityDepthSampler, lightPos).r);
            vec2 lightScreenCoord = (lightPos - vec2(0.5)) * vec2(aspectRatio, 1.0);
            float lightConversion = tan(FOV / 360.0 * 3.14159265358979) * 2.0 * lightDepth;
            vec3 lightWorldCoord = vec3(lightScreenCoord * lightConversion, lightDepth);

            vec3 lightColor = texture2D(ColoredCentersSampler, lightPos).rgb;
            lightColor /= max(max(lightColor.r, max(lightColor.g, lightColor.b)), 0.01);

            float lightDist = length(worldCoord - lightWorldCoord);

            if (lightDist < 100.0) {
                aggColor.rgb += clamp((pow(1.0 / (lightDist + 3.0), 2.0) - 0.01) * 9.0, 0.0, 1.0) * lightColor * clamp(Range - lightDepth, 0.0, 6.0) / 6.0;
            }
        } else {
            i += BIG;
        }
    }


    gl_FragColor = vec4(mix(outColor.rgb, aggColor.rgb, 0.7), 1.0);
}
