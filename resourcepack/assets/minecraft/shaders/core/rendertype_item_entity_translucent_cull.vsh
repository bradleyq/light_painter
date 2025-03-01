#version 150

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:utils.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;
uniform float FogStart;
uniform float FogEnd;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

uniform vec4 ColorModulator;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
out vec4 normal;
out vec4 glpos;
out float marker;
out float scale;

#define HALFMARKER tmp.z / 360.0

void main() {
    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);

    vec4 tmpcol = texture(Sampler0, UV0);
    vec4 tmp = ModelViewMat * vec4(Position, 1.0);

    marker = float(!isHand(FogStart, FogEnd) && (tmpcol.a == LIGHTALPHA));

    if (marker > 0.0) {
        vertexColor = vec4(tmpcol.rgb, 1.0);
        
        if (gl_VertexID % 4 == 0) {
            tmp.xy += vec2(-HALFMARKER, HALFMARKER);
            texCoord2 = vec2(0.0, 0.0);
        }
        else if (gl_VertexID % 4 == 1) {
            tmp.xy += vec2(-HALFMARKER, -HALFMARKER);
            texCoord2 = vec2(0.0, 1.0);
        }
        else if (gl_VertexID % 4 == 2) {
            tmp.xy += vec2(HALFMARKER, -HALFMARKER);
            texCoord2 = vec2(1.0, 1.0);
        }
        else {
            tmp.xy += vec2(HALFMARKER, HALFMARKER);
            texCoord2 = vec2(1.0, 0.0);
        }
        
        scale = abs(HALFMARKER * ProjMat[1][1] / tmp.z);
        tmp = ProjMat * tmp;

        vec4 distProbe = inverse(ProjMat) * vec4(0.0, 0.0, 1.0, 1.0);
        float far = round(length(distProbe.xyz / distProbe.w) / 64.0) * 64.0;
        float k = (far + NEAR) / (far - NEAR);
        tmp.z = (tmp.z - tmp.w * k) * 10.0 + tmp.w * k;
    }
    else {
        tmp = ProjMat * tmp;
    }

    glpos = tmp;
    gl_Position = tmp;

}
