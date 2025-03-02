#version 150

#moj_import <minecraft:utils.glsl>

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform float Range;

in vec2 texCoord;

out vec4 outColor;

void main() {
    outColor = vec4(0.0);
    float depth = texture(DiffuseDepthSampler, texCoord).r;

    if (depth < LIGHTDEPTH) {
        depth = LinearizeDepth(depth / LIGHTDEPTH);
        if (depth < Range) {
            outColor = texture(DiffuseSampler, texCoord);;
        }
    }
}