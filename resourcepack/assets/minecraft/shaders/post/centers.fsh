#version 150

uniform sampler2D ApproxCentersSampler;

in vec2 texCoord;
flat in vec2 oneTexel;

out vec4 fragColor;

void main() {
    fragColor = texture(ApproxCentersSampler, texCoord);
    vec3 c1 = texture(ApproxCentersSampler, texCoord + vec2(oneTexel.x, 0.0)).rgb;
    vec3 c2 = texture(ApproxCentersSampler, texCoord + vec2(0.0, oneTexel.y)).rgb;
    vec3 c3 = texture(ApproxCentersSampler, texCoord + vec2(oneTexel.x, -oneTexel.y)).rgb;
    vec3 c4 = texture(ApproxCentersSampler, texCoord + vec2(oneTexel.x, oneTexel.y)).rgb;
    if (dot(fragColor.rgb - c1, vec3(1.0)) < 0.02
     || dot(fragColor.rgb - c2, vec3(1.0)) < 0.02
     || dot(fragColor.rgb - c3, vec3(1.0)) < 0.02
     || dot(fragColor.rgb - c4, vec3(1.0)) < 0.02) {
        fragColor = vec4(0.0);
    }
}