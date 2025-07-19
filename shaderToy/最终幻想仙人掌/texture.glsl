#define T iTime
#define PI 3.141596
#define S smoothstep

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  O.rgb *= 0.;
  O.a = 1.;

  uv.x = fract(uv.x*4.);
  vec3 col = vec3(.2);
  float band = S(0.81, 0.8, abs(uv.x));
  col = mix(col, vec3(0,.6,0), band);

  O.rgb = col;
}