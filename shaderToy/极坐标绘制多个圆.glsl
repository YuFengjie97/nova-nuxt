#define Pi 3.141596
#define T iTime

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;
  O.a = 1.;
  
  vec2 p = uv;
  p *= 2.;

  p = vec2(atan(p.y,p.x)/(Pi*0.25), length(p));

  vec2 grid = min(vec2(1), .5*fwidth(p)/abs(p-round(p)));
  O.rgb += max(grid.x, grid.y)*0.5;


  float d = length(p);

  O.rgb += d;
}