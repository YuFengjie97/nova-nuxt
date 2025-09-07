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

vec3 palette( in float t )
{
  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.0, 0.1, 0.2);
  return a + b*cos( 6.283185*(c*t+d) );
}

float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,1263.7536)))*741.25639);
}
float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU*2.;
  a += T*2.;
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
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<6.;i++){
    n += noise(fre*p)*amp;
    // p *= rotate(2.+T*.01);
    amp *= .5;
    fre *= 2.;
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

float line(vec2 p, float len, float w) {
  p.y = abs(p.y);
  float d = length(p-vec2(0., clamp(0.,len,p.y)))-w;
  return d;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  uv.y += T*.1;
  vec2 s = vec2(.2, 1.);
  vec2 id = round(uv/s);
  vec2 o = sign(uv-s*id);

  float n = noise(uv);

  float d = 1e20;
  for(float x=0.;x<=1.;x++){
  for(float y=0.;y<=1.;y++){
    vec2 idd = id + vec2(x, y)*o;
    vec2 uv2 = uv - idd*s;

    float ha = hash(idd*.1);
    float w = .05*ha+.01;
    float len = .1*ha+.1;
    vec2 off = vec2(0., ha*.6);

    uv2 += n*.2;
    // uv2 *= vec2(1., .8);

    float d1 = line(uv2-off, len, w);
    // float d1 = length(uv2)-.2;
    d = min(d, d1);
  }
  }

  if(mod(floor(T*.4), 2.) == 0.){
    d = S(4./R.y, 0., d);
  }
  
  O.rgb += d;
}