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
float hash11(float p)
{
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

float noise11(float p){
  float i1 = floor(p);
  float i2 = i1+1.;
  float f = fract(p);
  float n1 = hash11(i1);
  float n2 = hash11(i2);
  float u = smoothstep(0.,1.,f);
  // float f =
  return mix(n1, n2, f); 
}

vec3 turbulence(vec3 p){
  float fre = 1.;
  float amp = 1.;
  for(float i =0.;i<4.;i++){
    p.xz *= rotate(.4);
    // p.yz *= rotate(.2);
    // p.xy *= rotate(.2);
    p += cos(p.zxy*fre-T*i)*amp;
    fre *= 2.;
    amp *= .5;
  }
  return p;
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
  mat2 my = rotate(T);
  if(iMouse.z>0.){
    mx = rotate(m.x);
    my = rotate(m.y);
  }


  vec3 col = vec3(0);
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;

    p.xz *= mx;
    // p.yz *= my;

    // p = mix(p, vec3(fbm(p*2.+vec3(0,T*10.,0))), vec3(.1));

    float d;
    vec3 q = p;
    {
      // q.xz *= rotate(noise11(q.y*2.)*.2);
      q.y *= .5;
      q = turbulence(q);
      d = length(cos(q.xz))-.2;
      float d1 = length(p.xz) - 3.;
      d = smax(d1, d, 1.);
      // d = max(d1, d);
      d = abs(d)*.2 + .01;
      // d = max(0.,d)*.1 + .01;
    }

    // vec3 c = s1(vec3(3,2,1)+dot(q, vec3(.1))-T);
    vec3 c = mix(vec3(1,0,0), vec3(0,1,0), S(10.,-10.,p.y));
    col += c*pow(1./d,1.);
    // col += 1.4/d;

    if(d<EPSILON || z>zMax) break;
    z += d;
  }

  col = tanh(col / 2e2);

  O.rgb = col;
}