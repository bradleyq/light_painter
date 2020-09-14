#version 110

uniform sampler2D DiffuseSampler;

varying vec2 texCoord;
varying vec2 oneTexel;

float v3min(vec3 v) {
    return max(min(v.r, min(v.g, v.b)), 0.01);
}

void main() {
    vec4 outColor = texture2D(DiffuseSampler, texCoord);
    vec3 c1 = texture2D(DiffuseSampler, texCoord + vec2(oneTexel.x, 0.0)).rgb;
    vec3 c2 = texture2D(DiffuseSampler, texCoord + vec2(0.0, oneTexel.y)).rgb;
    vec3 c3 = texture2D(DiffuseSampler, texCoord + vec2(oneTexel.x, -oneTexel.y)).rgb;
    vec3 c4 = texture2D(DiffuseSampler, texCoord + vec2(oneTexel.x, oneTexel.y)).rgb;
    if (dot(outColor.rgb - c1 / v3min(c1), vec3(1.0)) < 0.01
     || dot(outColor.rgb - c2 / v3min(c2), vec3(1.0)) < 0.01
     || dot(outColor.rgb - c3 / v3min(c3), vec3(1.0)) < 0.01
     || dot(outColor.rgb - c4 / v3min(c4), vec3(1.0)) < 0.01) {
        outColor = vec4(0.0);
    }
    gl_FragColor = outColor;
}