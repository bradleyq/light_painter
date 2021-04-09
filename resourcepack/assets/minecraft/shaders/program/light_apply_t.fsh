#version 110
 
uniform sampler2D DiffuseSampler;
uniform sampler2D LightMapSampler;
uniform sampler2D BlurSampler;
uniform float Intensity;
 
varying vec2 texCoord;

vec3 decodeAlphaHDR(vec4 color) {
    return color.rgb * (1.0 + clamp(color.a - 26.0 / 255.0, 0.0, 1.0) * 3.0 * 255.0 / 224.0);
}
 
 void main(){
    vec4 outColor = texture2D(DiffuseSampler, texCoord);
    vec3 lightColor = texture2D(LightMapSampler, texCoord).rgb;
    vec4 blurColor = texture2D(BlurSampler, texCoord);
    if (outColor.a > 0.0) {
        outColor.rgb *= (Intensity / clamp(length(blurColor.rgb), 0.04, 1.0) * lightColor * 0.9) * (1.0 - clamp(length(blurColor.rgb) / 1.6, 0.0, 1.0))  + vec3(1.0);
        outColor.rgb += Intensity * lightColor * 0.1;
    }

    gl_FragColor = outColor;
 }