#version 150

#moj_import <minecraft:utils.glsl>

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D LightsSampler;
uniform sampler2D CompareDepthSampler;
uniform float Range;
uniform float IntensityT;
uniform float Intensity;

in vec2 texCoord;
flat in vec2 oneTexel;
flat in vec2 oneTexelAux1;
flat in float aspectRatio;
flat in float conversionK;
flat in float count;

out vec4 outColor;

int decodeInt(vec4 ivec) {
    ivec.rgb *= 255.0;
    int num = 0;
    num += int(ivec.r);
    num += int(ivec.g) * 255;
    num += int(ivec.b) * 255 * 255;
    return num * int(floor(4.0 * (ivec.a - 0.75) + 0.5));
}

void main() {
    outColor = texture(DiffuseSampler, texCoord);
    if (outColor.a > 0.0) {
        float oDepth = texture(DiffuseDepthSampler, texCoord).r;
        float compDepth = texture(CompareDepthSampler, texCoord).r;
        float depth = LinearizeDepth(oDepth);

        if (oDepth >= LIGHTDEPTH && oDepth < compDepth && depth < Range + LIGHTR) {
            vec4 aggColor = vec4(0.0, 0.0, 0.0, 1.0);
            vec2 screenCoord = (texCoord - vec2(0.5)) * vec2(aspectRatio, 1.0);
            float conversion = conversionK * depth;
            vec3 worldCoord = vec3(screenCoord * conversion, depth);

            for (int i = 0; i < int(count); i += 1) {
                vec4 xvec = texture(LightsSampler, (vec2(float(i), 0.0) + 0.5) * oneTexelAux1);
                vec4 yvec = texture(LightsSampler, (vec2(float(i), 1.0) + 0.5) * oneTexelAux1);
                vec4 zvec = texture(LightsSampler, (vec2(float(i), 2.0) + 0.5) * oneTexelAux1);
                vec3 lightWorldCoord = vec3(decodeInt(xvec), decodeInt(yvec), decodeInt(zvec)) / FIXEDPOINT;
                float lightDist = length(worldCoord - lightWorldCoord);
                if (lightDist < LIGHTR) {
                    vec3 lightColor = texture(LightsSampler, (vec2(float(i), 3.0) + 0.5) * oneTexelAux1).rgb;
                    vec2 lightPos = lightWorldCoord.xy / (lightWorldCoord.z * conversionK) * vec2(1.0 / aspectRatio, 1.0);
                    lightPos = 0.5 - abs(lightPos);
                    aggColor.rgb += clamp((pow(1.0 / (lightDist + SPREAD), 2.0) - CUTOFF) * BOOST, 0.0, 1.0) * lightColor * clamp(Range - length(lightWorldCoord), 0.0, 6.0) * clamp(min(lightPos.x, lightPos.y), 0.0, 0.05) * 20.0 / 6.0;
                }
            }

            float IntensityV = outColor.a < 1.0 ? IntensityT : Intensity;
            outColor.rgb *= vec3(1.0) + aggColor.rgb * IntensityV * 5.0 * pow(1.0 - clamp(length(outColor.rgb), 0.0, 1.0), 3.0);
            outColor.rgb += IntensityV * aggColor.rgb * 0.1;
        }
    }
}
