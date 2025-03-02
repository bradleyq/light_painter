#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:utils.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec2 texCoord2;
in vec4 normal;
in vec4 glpos;
in float marker;
in float scale;

out vec4 fragColor;

void main() {

    
    if (marker < 0.5) {
        vec4 color = texture(Sampler0, texCoord0);
        if (color.a < 0.1) {
            discard;
        }
        color *= vertexColor * ColorModulator;
        fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
        fragColor.a = fragColor.a < 0.1 ? 0.1 : fragColor.a;
    } else {
        float onePixelToUV = 0.55 / (gl_FragCoord.y * 2.0 / (glpos.y / glpos.w + 1.0) * scale);
        if (!(abs(texCoord2.x - 0.5) <= onePixelToUV && abs(texCoord2.y - 0.5) <= onePixelToUV)) {
            discard;
        }
        fragColor = linear_fog(vertexColor, vertexDistance, FogStart, FogEnd, FogColor);
        fragColor.a = 1.0;
    }
}
