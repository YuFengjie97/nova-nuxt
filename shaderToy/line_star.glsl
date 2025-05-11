#define PI 3.141596

float sdfLine(vec2 p, vec2 a, vec2 b){
  vec2 d =vec2(max(p.x,a.x)-a.x, max(p.y,b.y)-b.y);
  return length(d);
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I-R*.5)/R.y;
  vec3 col = vec3(0.);

  float d = sdfLine(uv, vec2(0.), vec2(0.5, 0.));
  float s = smoothstep(0.01,0.,d);
  
  col += s;


  O = vec4(col, 1.);
}