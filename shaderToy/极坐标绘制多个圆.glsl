#define Pi 3.141596
#define T iTime

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;
  O.a = 1.;

  uv*=4.;

  vec2 p = uv;

  p = vec2(atan(p.y,p.x)/(Pi*0.25), length(p));

  vec2 grid = min(vec2(1), .5*fwidth(p)/abs(p-round(p)));
  O.rgb += max(grid.x, grid.y)*0.5;

  vec2 pos = floor(p);
  pos = vec2(cos(pos.x)*pos.y, sin(pos.x)*pos.y);
  float d = length(uv-pos)-0.1;
  d = smoothstep(0.2,0.19,d);
  O.rgb += d;

}