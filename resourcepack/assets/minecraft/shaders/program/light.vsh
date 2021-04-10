#version 150

in vec4 Position;

uniform sampler2D LightsSampler;
uniform mat4 ProjMat;
uniform vec2 InSize;
uniform vec2 AuxSize1;
uniform float FOV;

out vec2 texCoord;
flat out vec2 oneTexel;
flat out vec2 oneTexelAux1;
flat out float aspectRatio;
flat out float conversionK;
flat out float count;

int decodeInt(vec4 ivec) {
    ivec.rgb *= 255.0;
    int num = 0;
    num += int(ivec.r);
    num += int(ivec.g) * 255;
    num += int(ivec.b) * 255 * 255;
    return num * int(floor(4.0 * (ivec.a - 0.75) + 0.5));
}

void main(){
    vec4 outPos = ProjMat * vec4(Position.xy, 0.0, 1.0);
    oneTexel = 1.0 / InSize;
    oneTexelAux1 = 1.0 / AuxSize1;
    aspectRatio = InSize.x / InSize.y;
    texCoord = outPos.xy * 0.5 + 0.5;
    conversionK = tan(FOV / 360.0 * 3.14159265358979) * 2.0;

    vec4 tmpCount = texture(LightsSampler, vec2(1.0, 0.0) - oneTexelAux1 * 0.5);
    count = 0.0;
    if (tmpCount.a == 69.0 / 255.0) {
        tmpCount.a = 1.0;
        count = float(decodeInt(tmpCount));
    }

    gl_Position = vec4(outPos.xy, 0.2, 1.0);

}
