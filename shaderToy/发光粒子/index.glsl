#iChannel0 "file://D:/workspace/nova-nuxt/shaderToy/发光粒子/bufferB.glsl"


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    
    vec3 col = texture(iChannel0, uv).rgb;

    fragColor = vec4(col,1.0);
}