#iChannel0 "./bufferA.glsl"
void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = I/R;

  float d = texture(iChannel0, uv).r;
  // float dx = dFdx(d);
  // float dy = dFdy(d);
  float e = .01;
  float dx = texture(iChannel0, uv+vec2(e,0)).r-d;
  float dy = texture(iChannel0, uv+vec2(0,e)).r-d;

  vec2 vel = normalize(vec2(dy, -dx));
  float ang = atan(vel.y, vel.x);
  // vec3 col = sin(vec3(3,2,1)+(vel.x+vel.y)*1.6);
  vec3 col = sin(vec3(3,2,1)+ang)*.5+.5;
  // vec3 col = mix(vec3(.2,.5,0), vec3(0,.6,.6), ang);

  O.rgb = col;
}