// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/noise_2.png"

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

float noise(vec2 p){
  return texture(iChannel0, p).r;
}

float fbm(vec2 p){
  float amp = 1.;
  float n = 0.;
  for(float i =0.;i<6.;i++){
    n += noise(p)*amp;
    amp *= .5;
    p *= 2.;
  }
  return n;
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
  vec3 col = vec3(0);


  vec2 disstortionSpeed = vec2(.06);
  float disstortionScale = .1;

  float n = fbm(uv*disstortionScale+disstortionSpeed*T);
  vec2 uv3 = uv + n;
  float disstortionPower = 1.;
  uv3 = pow(uv3, vec2(disstortionPower));

  float disstortionAmount = .3;
  uv = mix(uv, uv3, disstortionAmount);

  // 随便搞得的重复图案
  uv *= 4.;
  vec2 uv2 = fract(uv)-.5;
  float d = length(uv2)-.1;
  // float d = length(uv);
  // d = sin(d*20.);

  float glow = pow(.1/d,2.);
  vec3 c = s1(vec3(3,2,1)+glow*.01+uv.x+uv.y);

  col += glow*c;


  O.rgb = col;
}