// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-6;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

float hash(vec2 p){
  return fract(4565.4841*sin(dot(p, vec2(1255.2566,557.3695))));
}

float hash2 (in vec2 _st) {
    return fract(sin(dot(_st.xy,
                         vec2(12.9898,78.233)
                         )
                 )*
        43758.5453123);
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

  O.rgb *= 0.;
  O.a = 1.;

  float s = .1;
  vec2 id = round(uv/s);
  uv -= id*s;

  float angle_unit = radians((floor(s1(T)*2.+1.))*45.);
  float angle_seg = 360./angle_unit;
  float a = floor(hash(id)*angle_seg) * angle_unit;
  vec2 l = vec2(cos(a), sin(a));
  float d = abs(dot(uv, normalize(l)));
  d = S(.1*s,0.,abs(d));
  O.rgb += d;  

}