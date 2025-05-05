#version 150

#moj_import <minecraft:utils.glsl>
#moj_import <minecraft:texint.glsl>

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D LightsSampler;
uniform sampler2D VolumeSampler;
uniform sampler2D CompareDepthSampler;

uniform vec2 VolumeSize;
uniform vec2 LightsSize;

in vec2 texCoord;
flat in vec2 oneTexel;
flat in vec2 oneTexelLights;
flat in vec2 oneTexelVolume;
flat in float aspectRatio;
flat in float conversionK;

out vec4 outColor;

void main() {
    outColor = texture(DiffuseSampler, texCoord);
    if (outColor.a > 0.0) {
        float oDepth = texture(DiffuseDepthSampler, texCoord).r;
        float compDepth = texture(CompareDepthSampler, texCoord).r;
        float depth = LinearizeDepth(oDepth);

        if (oDepth < compDepth && depth < LIGHTRANGE + LIGHTR) {
            vec4 aggColor = vec4(0.0, 0.0, 0.0, 1.0);
            vec2 screenCoord = (texCoord - vec2(0.5)) * vec2(aspectRatio, 1.0);
            float conversion = conversionK * depth;
            vec3 worldCoord = vec3(screenCoord * conversion, depth);

            int i = 0;
            int zone = int(floor(max((worldCoord.x + LIGHTRANGE) * LIGHTVOLX / (2 * LIGHTRANGE), 0.0)) + floor(max((worldCoord.z) * LIGHTVOLZ / LIGHTRANGE, 0.0)) * LIGHTVOLX);
            vec4 volvec = texture(VolumeSampler, (vec2(float(i), float(zone)) + 0.5) * oneTexelVolume);

            while (volvec.a > 0.5 && i < int(LightsSize.x)) {
                int li = decodeInt(volvec);
                i += 1;
                volvec = texture(VolumeSampler, (vec2(float(i), float(zone)) + 0.5) * oneTexelVolume);

                vec4 xvec = texture(LightsSampler, (vec2(float(li), 0.0) + 0.5) * oneTexelLights);
                vec4 yvec = texture(LightsSampler, (vec2(float(li), 1.0) + 0.5) * oneTexelLights);
                vec4 zvec = texture(LightsSampler, (vec2(float(li), 2.0) + 0.5) * oneTexelLights);
                vec3 lightWorldCoord = vec3(decodeInt(xvec), decodeInt(yvec), decodeInt(zvec)) / FIXEDPOINT;
                float lightDist = length(worldCoord - lightWorldCoord);
                if (lightDist < LIGHTR) {
                    vec3 lightColor = texture(LightsSampler, (vec2(float(li), 3.0) + 0.5) * oneTexelLights).rgb;
                    vec2 lightPos = lightWorldCoord.xy / (lightWorldCoord.z * conversionK) * vec2(1.0 / aspectRatio, 1.0);
                    lightPos = 0.5 - abs(lightPos);
                    aggColor.rgb += clamp((pow(1.0 / (lightDist + SPREAD), 2.0) - CUTOFF) * BOOST, 0.0, 1.0) * lightColor * clamp(LIGHTRANGE - length(lightWorldCoord), 0.0, 6.0) * clamp(min(lightPos.x, lightPos.y), 0.0, 0.05) * 20.0 / 6.0;
                }
            }

            outColor.rgb *= vec3(1.0) + aggColor.rgb * LIGHTINTENSITYT * 5.0 * pow(1.0 - clamp(length(outColor.rgb), 0.0, 1.0), 3.0);
            outColor.rgb += LIGHTINTENSITYT * aggColor.rgb * 0.1;
        }
    }
}
