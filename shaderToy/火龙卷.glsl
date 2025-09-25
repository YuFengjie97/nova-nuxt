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
float hash11(float p)
{
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
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
    amp *= .9;
    fre *= 1.3;
    p.xz *= rotate(p.y*.1+T*.3);
    p.y -= T*4.;
  }
  return n;
}


float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

vec3 col = vec3(0);
float sdFireBall(vec3 p){
  vec3 q = p;

  float h = 5.;
  float range = S(-h,h,p.y);
  float w = range*4.+1.;
  float thick = range*4.+1.;
  q.xz *= rotate(q.y*1.-T*2.);

  float d = sdBox(q, vec3(w,h,thick));
  float d1 = sdBox(q-vec3(0,1,0), vec3(w,h,thick)*vec3(.7,2,.7));
  d = max(d, -d1);
  
  d += fbm(p*3.)*.5;

  d = abs(d)*.1 + .01;

  vec3 c = s1(vec3(3,2,1)+(p.y+p.z)*.5-T*2.);
  // vec3 c = palette((p.y+p.z)*.1-T);
  col += pow(1.3/d, 2.) * c;

  return d;
}

void mainImage(out vec4 O, in vec2 I){
  vec2 R = iResolution.xy;
  vec2 uv = (I*2.-R)/R.y;
  vec2 m = (iMouse.xy*2.-R)/R * PI * 2.;

  O.rgb *= 0.;
  O.a = 1.;

  vec3 ro = vec3(0.,0.,-10.);

  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 20.;
  float z = .1;

  vec3 p;
  for(float i=0.;i<100.;i++){
    p = ro + rd * z;

    if(iMouse.z>0.){
      p.xz *= rotate(m.x);
      p.yz *= rotate(m.y);
    }

    float d = sdFireBall(p);
    

    if(d<EPSILON || z>zMax) break;
    z += d;
  }

  col = tanh(col / 9e4);

  O.rgb = col;
}