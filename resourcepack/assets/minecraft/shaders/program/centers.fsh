#version 150

uniform sampler2D DiffuseSampler;

in vec2 texCoord;
flat in vec2 oneTexel;

out vec4 outColor;

void main() {
    outColor = texture(DiffuseSampler, texCoord);
    vec3 c1 = texture(DiffuseSampler, texCoord + vec2(oneTexel.x, 0.0)).rgb;
    vec3 c2 = texture(DiffuseSampler, texCoord + vec2(0.0, oneTexel.y)).rgb;
    vec3 c3 = texture(DiffuseSampler, texCoord + vec2(oneTexel.x, -oneTexel.y)).rgb;
    vec3 c4 = texture(DiffuseSampler, texCoord + vec2(oneTexel.x, oneTexel.y)).rgb;
    if (dot(outColor.rgb - c1, vec3(1.0)) < 0.02
     || dot(outColor.rgb - c2, vec3(1.0)) < 0.02
     || dot(outColor.rgb - c3, vec3(1.0)) < 0.02
     || dot(outColor.rgb - c4, vec3(1.0)) < 0.02) {
        outColor = vec4(0.0);
    }
}