#version 150

#moj_import <light.glsl>

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

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
out vec2 texCoord3;
out vec4 normal;
out vec4 glpos;
out float marker;
out float scale;


#define LIGHT0_DIRECTION normalize(vec3(0.2, 1.0, -0.7)) 
#define NORMAL vec3(0.0, 1.0, 0.0) 
#define HALFMARKER 7.0 / 32.0

void main() {
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
    marker = float(texture(Sampler0, UV0).a == 1.0);

    vec4 tmp = vec4(Position, 1.0);

    mat3 PlayerInv = mat3(NORMAL, LIGHT0_DIRECTION, cross(NORMAL, LIGHT0_DIRECTION)) * inverse(mat3(Normal, Light0_Direction, cross(Normal, Light0_Direction)));
    mat3 Player = inverse(PlayerInv);

    if (marker > 0.0) {
        if (gl_VertexID % 4 == 0) {
            tmp.xyz = Player * (PlayerInv * tmp.xyz + vec3(-HALFMARKER, 0.0, -HALFMARKER));
            tmp.xy += vec2(-HALFMARKER, HALFMARKER);
            texCoord3 = vec2(0.0, 0.0);
        }
        else if (gl_VertexID % 4 == 1) {
            tmp.xyz = Player * (PlayerInv * tmp.xyz + vec3(-HALFMARKER, 0.0, HALFMARKER));
            tmp.xy += vec2(-HALFMARKER, -HALFMARKER);
            texCoord3 = vec2(0.0, 1.0);
        }
        else if (gl_VertexID % 4 == 2) {
            tmp.xyz = Player * (PlayerInv * tmp.xyz + vec3(HALFMARKER, 0.0, HALFMARKER));
            tmp.xy += vec2(HALFMARKER, -HALFMARKER);
            texCoord3 = vec2(1.0, 1.0);
        }
        else {
            tmp.xyz = Player * (PlayerInv * tmp.xyz + vec3(HALFMARKER, 0.0, -HALFMARKER));
            tmp.xy += vec2(HALFMARKER, HALFMARKER);
            texCoord3 = vec2(1.0, 0.0);
        }
    }

    tmp = ModelViewMat * tmp;

    scale = abs(HALFMARKER * ProjMat[1][1] / tmp.z);

    tmp = ProjMat * tmp;

    if (marker > 0.0) {
        vec4 distProbe = inverse(ProjMat) * vec4(0.0, 0.0, 1.0, 1.0);
        float far = round(length(distProbe.xyz / distProbe.w) / 64.0) * 64.0;
        float near = 0.05;
        float k = (far + near) / (far - near);
        tmp.z = (tmp.z - tmp.w * k) * 10.0 + tmp.w * k;
    }

    glpos = tmp;
    gl_Position = tmp;

}
