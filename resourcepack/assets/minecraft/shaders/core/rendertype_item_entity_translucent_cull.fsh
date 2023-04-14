#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec2 texCoord3;
in vec4 normal;
in vec4 glpos;
in float marker;
in float scale;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    if (color.a < 0.1) {
        discard;
    }

    
    if (marker < 0.5) {
        color *= vertexColor * ColorModulator;
        fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
    } else {
        float onePixelToUV = 0.51 / (gl_FragCoord.y * 2.0 / (glpos.y / glpos.w + 1.0) * scale);
        if (!(abs(texCoord3.x - 0.5) <= onePixelToUV && abs(texCoord3.y - 0.5) <= onePixelToUV)) {
            discard;
        }
        fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
        fragColor.rgb *= 254.0 / 255.0;
    }
}
