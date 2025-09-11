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

float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}


float hash(vec2 p){
  return fract(sin(dot(p, vec2(456.456,7897.7536)))*741.25639);
}

vec2 randomGradient(vec2 p){
  float a = hash(p)*TAU;
  a += T;
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
    p *= rotate(2.+T*.01);
    amp *= .5;
    fre *= 2.;
  }
  return n;
}

float fbm(vec3 p){
  vec3 q = p;
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i = 0.;i<4.;i++){
    n += abs(dot(cos(p*fre), vec3(.1,.2,.3))) * amp;
    amp *= .9;
    fre *= 1.3;
    p.xz *= rotate(p.y*.1-T*2.);
    p.y -= T*4.;
  }
  return n;
}
float sdVerticalCapsule( vec3 p, float h, float r )
{
  p.y -= clamp( p.y, 0.0, h );
  return length( p ) - r;
}

vec3 col = vec3(0);
float sdFireBall(vec3 p, float r, float h, float seed){
  vec3 q = p;
  float range = S(h,0.,p.y);
  r = range*r;
  float d = sdVerticalCapsule(q, h, r);
  d += fbm(q*3.)*.8;

  d = abs(d)*.1 + .006;

  vec3 c = s1(vec3(3,2,1)*seed+(p.y+p.z)*.5+seed);
  col += pow(1./d, 2.) * c;

  return d;
}

vec2 edge(vec2 p) {
    vec2 p2 = abs(p);
    if (p2.x > p2.y) return vec2((p.x < 0.) ? -1. : 1., 0.);
    else             return vec2(0., (p.y < 0.) ? -1. : 1.);
}


void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-16.);

  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 50.;
  float z = .1;

  vec3 p;
  for(float i=0.;i<100.;i++){
    p = ro + rd * z;
    p.y += 2.;

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    float r = 2.;
    float s = 5.;
    // float r = .4;
    // float s = 1.2;
    vec2 id = floor(p.xz/s);
    vec2 cen = id + .5;
    vec2 nei = cen + edge(p.xz/s-cen);

    float h = 10.;
    float seed = hash12(id)*10.;
    float d = 1e10;
    {
      vec3 q = p;
      q.xz -= cen * s;
      q.y -= s1(seed+T)*40.;
      float d1 = sdFireBall(q, r, h, seed);
      d = min(d, d1);
    }
    {
      vec3 q = p;
      q.xz -= nei * s;
      // q.y -= 0.;
      float d1 = sdFireBall(q, r, h, seed);
      d = min(d, d1);
    }
    

    if(d<EPSILON || z>zMax) break;
    z += d;
  }

  col = tanh(col / 1e5);

  O.rgb = col;
}