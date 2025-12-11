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

  vec3 ro = vec3(0.,0.,-10.);

  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 50.;
  float z = .1;

  mat2 mx = rotate(T*.3);
  mat2 my = rotate(T*.3);
  if(iMouse.z>0.){
    mx = rotate(m.x);
    my = rotate(m.y);
  }


  vec3 col = vec3(0);
  vec3 C = vec3(3,2,1);
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    vec3 p0 = p;

    p.xz *= mx;
    p.yz *= my;

    float r = length(p);
    float the = acos(p.y/r);
    float phi = atan(p.z, p.x);
    vec3 q = vec3(the, phi, r);

    q.z -= T;

    q.xy = cos(q.xy*6.);
    q.xy += asin(sin(q.yx+T*.4));
    q.xy += asin(sin(q.yx*2.+T*.4))*.5;

    q.z = mod(q.z, 2.)-1.;


    float radius = 0.;
    float d = length(q.xz-vec2(0,radius)) - .2;
    {
      float d1 = length(q.yz-vec2(0,radius)) - .2;
      d = min(d, d1);
    }
    {
      float d1 = length(q-vec3(0,0,radius))-.4;
      d = min(d, d1);
    }
    {
      float d1 = length(p0 - ro) - 3.;
      d = max(d, -d1);
    }

    // d = max(d*.3, 0.01);
    d = abs(d)*.2+.01;
    
    col += s1(C+r)/d;
    
    if(d<EPSILON || z>zMax) break;
    z += d;
  }

  col = tanh(col / 2e3);

  O.rgb = col;
}