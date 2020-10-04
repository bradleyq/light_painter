#version 120

uniform sampler2D DiffuseSampler;

varying vec2 texCoord;
varying vec2 oneTexel;

float v3max(vec3 v) {
    return max(max(v.r, max(v.g, v.b)), 0.01);
}

void main() {
    vec4 outColor = texture2D(DiffuseSampler, texCoord);
    outColor.rgb /= v3max(outColor.rgb);
    vec3 c1 = texture2D(DiffuseSampler, texCoord + vec2(oneTexel.x, 0.0)).rgb;
    vec3 c2 = texture2D(DiffuseSampler, texCoord + vec2(0.0, oneTexel.y)).rgb;
    vec3 c3 = texture2D(DiffuseSampler, texCoord + vec2(oneTexel.x, -oneTexel.y)).rgb;
    vec3 c4 = texture2D(DiffuseSampler, texCoord + vec2(oneTexel.x, oneTexel.y)).rgb;
    if (dot(outColor.rgb - c1 / v3max(c1), vec3(1.0)) < 0.02
     || dot(outColor.rgb - c2 / v3max(c2), vec3(1.0)) < 0.02
     || dot(outColor.rgb - c3 / v3max(c3), vec3(1.0)) < 0.02
     || dot(outColor.rgb - c4 / v3max(c4), vec3(1.0)) < 0.02) {
        outColor = vec4(0.0);
    }
    gl_FragColor = outColor;
}