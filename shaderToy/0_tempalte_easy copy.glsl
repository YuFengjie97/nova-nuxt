// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"


#define T iTime
#define PI 3.1415926
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

float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i = 0.;i<4.;i++){
    n += abs(dot(cos(p*fre), vec3(.1,.2,.3))) * amp;
    amp *= .5;
    fre *= 2.;
    p.xz *= rotate(p.y*.1+T*.3);
    p.y -= T*4.;
  }
  return n;
}


// https://iquilezles.org/articles/distfunctions/
float sdCappedCylinder( vec3 p, float r, float h )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(r,h);
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdLinder(vec3 p, float r, float r2){
  float d = length(p.xz) - r;
  float a = atan(p.z, p.x);
  float rOff = sin(a*4.);
  d -= rOff;
  return d;
}

float smin( float d1, float d2, float k )
{
    k *= 4.0;
    float h = max(k-abs(d1-d2),0.0);
    return min(d1, d2) - h*h*0.25/k;
}

float smax( float d1, float d2, float k )
{
    return -smin(-d1,-d2,k);
}
float helper(vec3 p){
  float d1 = length(p.xy)-.05;
  float d2 = length(p.xz)-.05;
  float d3 = length(p.yz)-.05;
  float d4 = length(p)-.2;
  return min(d4,min(d3,min(d1,d2)));
}

float hash11(float p)
{
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}
float noise11(float p){
  float i = floor(p);
  float f = fract(p);
  float v1 = hash11(i-1.);
  float v2 = hash11(i);
  return mix(v1, v2, smoothstep(0., 1., f));
}


float map(vec3 p){
  float a = p.y*.6-T*4.;
  p.x += cos(a);
  p.z += sin(a);

  float r = 1.5;
  float h = 10.;

  float r1 = smoothstep(-6., -10., p.y)*3.;  // 底部
  float r2 = smoothstep(0., 10., p.y)*4.; // 顶部
  float r3 = smoothstep(5., 10., p.y)*4.; // 顶部
  r += r1 + r2 + r3;

  vec3 q = p;

  q += sin(q.zxy)*.5;
  q += sin(q.zxy*2.)*.25;
  q += sin(q.zxy*4.)*.125;

  // float d = sdCappedCylinder(q, r, h);
  // float d1 = sdCappedCylinder(q, r*.4, h*2.);
  float d = sdLinder(q,r,.6);
  float d1 = sdLinder(q,r*.4,.7);
  // d = max(d, -d1);
  d = smax(d, -d1, .3);
  return d;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,-.5,-16.);
  vec3 rd = normalize(vec3(uv, 1.));

  float z = .1;

  mat2 mx = rotate(T*.1);
  mat2 my = rotate(0.);
  if(iMouse.z>0.){
    mx = rotate(m.x);
    my = rotate(m.y);
  }

  vec3 col = vec3(0);
  vec3 C = vec3(3,2,1);
  float i=0.;
  while(i++<80.){
    vec3 p = ro + rd * z;

    p.xz *= mx;
    p.yz *= my;

    float d = map(p);
    d += fbm(p*3.)*.4;
    d = abs(d)*.3 + .01;
    // float d1 = helper(p);
    // d = min(d, d1);


    if(d<EPSILON) break;
    
    col += s1(C+p.y)/d;

    z += d;
  }

  col = tanh(col / 2e3);

  O.rgb = col;
}