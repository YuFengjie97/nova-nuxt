// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define S smoothstep
const float EPSILON = 1e-6;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float map(vec2 p){
  float d = abs(length(p) - .4);
  return d;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 col = vec3(0);

  float d = map(uv);
  d = S(0.01, 0.,d);
  col += d;

  float d2 = length(uv-m)-map(m);
  d2 = abs(d2);
  d2 = S(0.01,0.,d2);
  // col += d2*vec3(1,0,0);
  col = mix(col, vec3(1,0,0), d2);

  O.rgb = col;
}