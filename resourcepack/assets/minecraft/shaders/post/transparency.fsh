#version 150

#moj_import <minecraft:utils.glsl>

uniform sampler2D DiffuseSampler;
uniform sampler2D DiffuseDepthSampler;
uniform sampler2D TranslucentSampler;
uniform sampler2D TranslucentDepthSampler;
uniform sampler2D ItemEntitySampler;
uniform sampler2D ItemEntityDepthSampler;
uniform sampler2D ParticlesSampler;
uniform sampler2D ParticlesDepthSampler;
uniform sampler2D WeatherSampler;
uniform sampler2D WeatherDepthSampler;
uniform sampler2D CloudsSampler;
uniform sampler2D CloudsDepthSampler;

in vec2 texCoord;

#define NUM_LAYERS 6

vec4 color_layers[NUM_LAYERS];
float depth_layers[NUM_LAYERS];
int index_layers[NUM_LAYERS] = int[NUM_LAYERS](0, 1 ,2, 3, 4, 5);
int active_layers = 0;

out vec4 fragColor;

void try_insert( vec4 color, sampler2D dSampler, int ie ) {
    if ( color.a == 0.0 ) {
        return;
    }

    float depth = texture( dSampler, texCoord ).r;
    if (ie > 0) {
        if (depth >= LIGHTDEPTH) {
            depth = (depth - LIGHTDEPTH) / (1.0 - LIGHTDEPTH);
        }
        else {
            return;
        }
    }
    color_layers[active_layers] = color;
    depth_layers[active_layers] = depth;

    int jj = active_layers++;
    int ii = jj - 1;
    while ( jj > 0 && depth > depth_layers[index_layers[ii]] ) {
        int indexTemp = index_layers[ii];
        index_layers[ii] = index_layers[jj];
        index_layers[jj] = indexTemp;

        jj = ii--;
    }
}

vec3 blend( vec3 dst, vec4 src ) {
    return ( dst * ( 1.0 - src.a ) ) + src.rgb;
}

void main() {
    color_layers[0] = vec4( texture( DiffuseSampler, texCoord ).rgb, 1.0 );
    depth_layers[0] = texture( DiffuseDepthSampler, texCoord ).r;
    active_layers = 1;

    try_insert( texture( CloudsSampler, texCoord ), CloudsDepthSampler, 0);
    try_insert( texture( TranslucentSampler, texCoord ), TranslucentDepthSampler, 0);
    try_insert( texture( ParticlesSampler, texCoord ), ParticlesDepthSampler, 0);
    try_insert( texture( WeatherSampler, texCoord ), WeatherDepthSampler, 0);
    try_insert( texture( ItemEntitySampler, texCoord ), ItemEntityDepthSampler, 1);
    
    vec3 texelAccum = color_layers[index_layers[0]].rgb;
    for ( int ii = 1; ii < active_layers; ++ii ) {
        texelAccum = blend( texelAccum, color_layers[index_layers[ii]] );
    }

    fragColor = vec4( texelAccum.rgb, 1.0 );
}