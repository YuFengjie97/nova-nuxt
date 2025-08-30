// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

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

float vmax(vec3 v) {
	return max(max(v.x, v.y), v.z);
}
// Box: correct distance to corners
float fBox(vec3 p, vec3 b) {
	vec3 d = abs(p) - b;
	return length(max(d, vec3(0))) + vmax(min(d, vec3(0)));
}

float mainImagetxt(vec2 u){
  u -= round(u);
  u = abs(u*4.)-2.;
  float d = length(u)-.1;
  return d;
}

float map(vec3 p){
  vec2 uv_txt = vec2(atan(p.y,p.z), atan(p.z,p.x));
  float d = fBox(p, vec3(1.));
  d = max(d,0.);

  float d1 = mainImagetxt(uv_txt);
  // d = min(d, d1);
  d = d1;

  return d;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  uv*=10.;
  vec2 id = floor(uv);
  uv = fract(uv);


  float d = sqrt(10. * uv.x*uv.y*(1.-uv.x)*(1.-uv.y));
  vec3 col = 1. + sin(vec3(3,2,1)+dot(id,id)*2.+T*4.);
  O.rgb += col*d;
}