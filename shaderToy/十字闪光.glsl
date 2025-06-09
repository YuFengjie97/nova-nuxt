#define S smoothstep

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R) / R;
  O.rgb *= 0.;
  O.a = 1.;
  
  uv *= 10.;
  uv = abs(uv);

  float v = 0.1;
  float d = uv.y-v/uv.x;
  float d1 = uv.x-v/uv.y;
  d = min(d,d1);
  d = d < 0. ? 0.:d;
  // d = S(0.1,0.,d);
  d = .01/d;


  O.rgb += d;
}
