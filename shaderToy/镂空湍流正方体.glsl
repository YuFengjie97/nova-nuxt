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
float hash112(float p){
  return abs(sin(p*112.33));
}

float smin( float a, float b, float k )
{
    k *= 1.0/(1.0-sqrt(0.5));
    float h = max( k-abs(a-b), 0.0 )/k;
    return min(a,b) - k*0.5*(1.0+h-sqrt(1.0-h*(h-2.0)));
}
float smax(float a, float b, float k) {
    return -smin(-a, -b, k);
}


float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
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

  vec3 col = vec3(0);
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;

    p.xz *= rotate(T*.2);
    p.yz *= rotate(T*.2);

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    vec3 q = cos(p);
    // vec3 q = abs(p-floor(p)-.5);
    for(float l=1.;l<6.;l++){
      q += sin(q.zxy*l+T)*.2;
    }


    float d = length(q)-.6;
    {
      float d1 = sdBox(p, vec3(4.));
      d = smax(d1, -d, 1.);
    }
    d = abs(d)*.3+.005;


    vec3 c = sin(vec3(3,2,1)+dot(p,p)*.1+T)+1.;
    col += c * pow(.01/d,2.);
    
    
    // float a = atan(p.y,p.x);
    // float s = TAU / 8.;
    // float id = round(a/s);

    // float d = 1e4;


    // float sz = 2.;
    

    // for(float l=0.;l<5.;l++){
    //   float idz = round((p.z-l)/sz);
    //   float idd = idz;
    //   p.z -= idz * sz;

    //   float sdz = .5+.5;
    //   float r = sdz*1.+.01;
    //   vec3 offset = vec3(sdz*4.+2.,0,0);

    //   vec3 q = p;
    //   q.xy = rotate(s*id)*q.xy;
    //   q -= offset;
    //   float d1 = length(q) - r;
    //   d = min(d, d1);

    //   vec3 c = sin(vec3(3,2,1)+p.x)+1.;
    //   col += c * pow(.1/d,2.);
    // }
    


    if(d<EPSILON || z>zMax) break;
    z += d;
  }

  col = tanh(col / 1e2);

  O.rgb = col;
}