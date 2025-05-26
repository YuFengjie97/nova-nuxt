#define PI 3.141596
#define T iTime

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I-R)/R.y;
  O.rgb *= 0.;
  O.a = 1.;

  uv *= 4.;
  uv = fract(uv);
  uv -= 0.5;
  uv *= 4.;

  // uv += sin(uv.xy * (8.+sin(T)*4.));
  uv += sin(uv.xy * 4.);

  float d = length(uv);
  d = pow(1./d, d)*4.;

  O.rgb = sin(vec3(3,2,1) + d);
}