#iChannel0 "./bufferA.glsl"
#iChannel1 "../pic/buttfly.png"

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I)/R.xy;

  O.rgb *= 0.;
  O.a = 1.;
  vec4 tex = texture(iChannel0, uv);
  float d = tex.z;
  vec3 col = sin(vec3(3,2,1))*.5+.5;
  O.rgb += col * d;
}