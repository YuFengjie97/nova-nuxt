#iChannel0 "./bufferC.glsl"

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy ;

  O.rgb = texture(iChannel0, I/R).rgb;
}