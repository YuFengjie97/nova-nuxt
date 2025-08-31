#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
const float EPSILON = 1e-6;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<4.;i++){
    n += abs(dot(cos(p), vec3(.1)));
    amp *= .5;
    fre *= 2.;
  }
  return n;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;
  float pix = 1./R.y;

  O.rgb *= 0.;
  O.a = 1.;

  // float s = 10.*pix;
  // uv = (floor(uv/s)-.5)*s;

  float d = length(uv)-.4;
  d = sin(d*10.-T);
  float a = atan(uv.y, uv.x)*5.;
  float r = (sin(a)*.5+.5)*.6;
  float glow = pow(r/d,2.);
  vec3 col = vec3(1,0,0);

  // https://mini.gmshaders.com/p/func-mix
  for(float i = 0.; i<1.; i+=.05){
    vec2 tuv = mix(uv, vec2(0.), i * 0.2);
    col += texture(iChannel0, tuv).rgb * 0.05;
  }
  O.rgb += col*glow;


}