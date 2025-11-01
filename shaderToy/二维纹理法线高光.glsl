// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

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

float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU;
  a += T*.4;
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


vec3 C = vec3(3,2,1);

float fbm(vec2 p){
  float amp = 1.;
  float n = 0.;
  for(float i=0.;i<5.;i++){
    n += noise(p)*amp;
    amp *= .5;
    p *= 2.;
  }
  C += dot(p, vec2(.01));
  return n;
}

float map(vec2 p){
  p *= 1.2;

  // float d = fbm(p);
  // d = fbm(p+d);

  vec2 q = vec2(fbm(p+vec2(3.2)), fbm(p+vec2(11.7)));
  float d = fbm(q);

  return d;
}

vec3 calcNormal(vec2 p){
  vec2 eps = vec2(0.0001, 0.);
  return normalize(vec3(
    map(p+eps.xy)-map(p-eps.xy),
    map(p+eps.yx)-map(p-eps.yx),
    0.001
  ));
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 nor = calcNormal(uv*.3);
  vec3 col = s1(C)*.7;
  vec3 l_pos = vec3(cos(T),sin(T),1.2);
  vec3 l_dir = normalize(l_pos-vec3(uv,0));
  float diff = max(0.,dot(l_dir, nor));
  float spe = pow(max(0., dot(reflect(-l_dir,nor), vec3(0,0,1))),30.);
  col = col*.4 + diff*col + spe*1.3;

  O.rgb = col;
}