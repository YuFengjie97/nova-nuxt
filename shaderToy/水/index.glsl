#iChannel0 "./bufferA.glsl"
#iChannel1 "./bufferB.glsl"

void mainImage(out vec4 O, in vec2 I){
    vec2 R = iResolution.xy;
    vec2 uv = (I)/R;

    O.rgb = texture(iChannel1, uv).rgb;
}