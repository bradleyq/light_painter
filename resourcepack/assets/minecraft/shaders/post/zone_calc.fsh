#version 150

#moj_import <minecraft:utils.glsl>
#moj_import <minecraft:texint.glsl>

uniform sampler2D LightsSampler;

in vec2 texCoord;
flat in vec2 oneTexel;
flat in vec2 oneTexelLights;
flat in float count;
flat in float stepX;
flat in float stepZ;

out vec4 fragColor;

void main() {
    fragColor = vec4(0.0);
    
    vec2 pos = gl_FragCoord.xy - 0.5;
    int targetIndex = int(round(pos.x));
    int zoneX = int(round(pos.y)) % LIGHTVOLX;
    int zoneZ = int(round(pos.y)) / LIGHTVOLX;

    int foundIndex = 0;

    for (int i = 0; i < int(count); i += 1) {
        vec4 xvec = texture(LightsSampler, (vec2(float(i), 0.0) + 0.5) * oneTexelLights);
        vec4 zvec = texture(LightsSampler, (vec2(float(i), 2.0) + 0.5) * oneTexelLights);
        vec3 lightCoord = vec3(decodeInt(xvec), 0.0, decodeInt(zvec)) / FIXEDPOINT;
        if (lightCoord.x >= -LIGHTRANGE + (float(zoneX) * stepX) - LIGHTR
         && lightCoord.x <= -LIGHTRANGE + (float(zoneX + 1) * stepX) + LIGHTR
         && lightCoord.z >= (float(zoneZ) * stepZ) - LIGHTR
         && lightCoord.z <= (float(zoneZ + 1) * stepZ) + LIGHTR) {
            if (targetIndex == foundIndex) {
                fragColor = encodeInt(i);
                break;
            }
            foundIndex += 1;
        }
    }
}