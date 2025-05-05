#version 150

#moj_import <minecraft:utils.glsl>

uniform sampler2D ItemEntitySampler;
uniform sampler2D ItemEntityDepthSampler;

in vec2 texCoord;

out vec4 fragColor;

void main() {
    fragColor = vec4(0.0);
    float depth = texture(ItemEntityDepthSampler, texCoord).r;

    if (depth < LIGHTDEPTH) {
        depth = LinearizeDepth(depth / LIGHTDEPTH);
        if (depth < LIGHTRANGE) {
            fragColor = texture(ItemEntitySampler, texCoord);
        }
    }
}