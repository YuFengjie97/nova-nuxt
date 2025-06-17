#define T iTime
#define S smoothstep


mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;

  vec2 uv = (I*2.-R)/R.y;
  
  O.rgb *= 0.;
  O.a = 1.;

  uv *= 4.;

  vec2 p = uv;

  vec2 grid = min(vec2(1),fwidth(p)/abs(p-round(p)));
  O.rgb += max(grid.x,grid.y)*vec3(1,0,0);

  // p -= round(p/5.)*5.;
  p = mod(p-2.5, 5.) - 2.5;

  float d = length(p-vec2(2.0))-1.5;
  d = S(0.01,0.,d);
  O.rgb += d;
  // O.rgb = mix(O.rgb, vec3(1,0,0), d);

}