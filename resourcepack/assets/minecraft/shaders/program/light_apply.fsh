 #version 110
 
 uniform sampler2D DiffuseSampler;
 uniform sampler2D LightMapSampler;
 uniform float Intensity;
 
 varying vec2 texCoord;
 
 void main(){
    vec4 outColor = texture2D(DiffuseSampler, texCoord);
    vec3 lightColor = texture2D(LightMapSampler, texCoord).rgb;
    outColor.rgb *= (Intensity * lightColor * 0.9) * (1.0 - clamp(length(outColor.rgb) / 1.6, 0.0, 1.0))  + vec3(1.0);
    outColor.rgb += Intensity * lightColor * 0.1;
    gl_FragColor = vec4(outColor.rgb, 1.0);
 }