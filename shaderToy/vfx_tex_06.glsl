// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

#define T iTime
#define PI 3.141596
#define TAU 6.283185
#define S smoothstep
#define s1(v) (sin(v)*.5+.5)
const float EPSILON = 1e-3;

mat2 rotate(float a){
  float s = sin(a);
  float c = cos(a);
  return mat2(c,-s,s,c);
}

vec3 palette( in float t )
{
  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.0, 0.1, 0.2);
  return a + b*cos( 6.283185*(c*t+d) );
}

float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU;
  return vec2(cos(a), sin(a));
}

float noise(vec2 p){
  vec2 i = floor(p);
  vec2 f = fract(p);

  vec2 g00 = randomGradient(i+vec2(0,0));
  vec2 g10 = randomGradient(i+vec2(1,0));
  vec2 g01 = randomGradient(i+vec2(0,1));
  vec2 g11 = randomGradient(i+vec2(1,1));

  float v00 = dot(g00, f-vec2(0,0));
  float v10 = dot(g10, f-vec2(1,0));
  float v01 = dot(g01, f-vec2(0,1));
  float v11 = dot(g11, f-vec2(1,1));

  vec2 u = smoothstep(0.,1.,f);

  return mix(mix(v00,v10,u.x), mix(v01,v11,u.x), u.y);
}

float fbm(vec2 p){
  float n = 0.;
  n += noise(p)*1.; p*=2.;
  n += noise(p)*1.5;
  return n;
}

float fbmPolar(vec2 uv, vec2 scale, vec2 offset){
  vec2 uv1 = vec2((atan(uv.y,uv.x)+PI)/TAU, length(uv));
  float ang = uv1.x;
  uv *= rotate(PI);
  vec2 uv2 = vec2((atan(uv.y,uv.x)+PI)/TAU, length(uv));
  
  float n1 = fbm(uv1*scale+offset);
  float n2 = fbm(uv2*scale+offset+vec2(33,44));
  
  float ler = S(.0,.1,abs(ang-.5));
  float n = mix(n1, n2, ler);

  return n;
}

float noisePolar(vec2 uv, vec2 scale, vec2 offset){
  vec2 uv1 = vec2((atan(uv.y,uv.x)+PI)/TAU, length(uv));
  float ang = uv1.x;
  uv *= rotate(PI);
  vec2 uv2 = vec2((atan(uv.y,uv.x)+PI)/TAU, length(uv));
  
  float n1 = noise(uv1*scale+offset);
  float n2 = noise(uv2*scale+offset+vec2(33,44));
  
  float ler = S(.0,.1,abs(ang-.5));
  float n = mix(n1, n2, ler);

  return n;
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I-R*.5)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;


  vec3 col = vec3(0);
  float t = T*2.8;

  float noi = noisePolar(uv, vec2(3), vec2(0., mod(-t, 50.)));

  vec2 offset = vec2(0., mod(-t, 50.));
  float n = fbmPolar(uv, vec2(6., 1.)*4., offset);

  n = pow(n*1.5, 1.);
  // n += S(.5,3.5,n)*2.5;
  // n = pow(n, 3.);

  // n = clamp(n, 0., 10.);


  float d = length(uv);
  float glow = pow(.05/d, 2.);

  n += glow;
  n = clamp(n, 0., 1.);
  float colorGrad = n;

  float mask = S(.3, .4, d);
  n -= mask;

  vec3 c = mix(vec3(5,0,0), vec3(0,5,0), colorGrad);

  col += n*c;


  O.rgb = col;
}