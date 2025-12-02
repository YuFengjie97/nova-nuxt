#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-3;

float remap01(float v, float vmin, float vmax){
  return clamp(v-vmin,0.,1.)/(vmax-vmin);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  
  uv *= 5.;


  vec2 m = vec2(cos(T), sin(T))*2.;
  if(iMouse.z>0.){
    m = (iMouse.xy*2.-R)/R*5.;
  }
  vec3 col = vec3(0);

  col += S(10./R.y, 0., length(uv-m)-.2);

  O.rgb *= 0.;
  O.a = 1.;


  float md = length(uv - m);
  float scl = S(.0,2.2,md);
  uv -= m ;
  uv *= scl;
  uv += m;

  vec2 grid = abs(fract(uv*1.)-.5);
  float d = min(grid.x, grid.y);
  col += S(30./R.y, 0., d);

  O.rgb = col;
}