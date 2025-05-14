#define PI 3.141596


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;
  O.a = 1.;

  float scale = 10.;
  
  vec2 p = uv;
  p *= scale;

  if(uv.x < 0.) {
    p.x += scale * 0.5;
    p = fract(p) - 0.5;
    float d = length(p) - 0.1;
    float aa = fwidth(d);
    float s = smoothstep(0.1,0.1-aa,d);
    O.rgb += s;
  }
  if(uv.x > 0.) {
    p.x -= scale * 0.5;
    vec2 q = vec2(atan(p.y, p.x)/(2.*PI/scale), log(length(p)) * scale);
    q = fract(q);
    float d = length(p) - 0.1;
    float aa = fwidth(d);
    float s = smoothstep(0.1,0.1-aa,d);
    O.rgb += s * vec3(1.,0.,0.);
  }

}