#iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture1.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture2.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture3.jpg"
// #iChannel0 "file://D:/workspace/nova-nuxt/public/img/noise/shaderToy/texture4.jpg"

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


float noise(vec2 p){
  return texture(iChannel0, p).r;
}

float fbm(vec2 p){
  float n = 0.;
  float amp = 1.;
  float fre = 1.;
  for(float i=0.;i<5.;i++){
    n += noise(p*fre)*amp;
    fre *= 2.;
    amp *= .5;
  }
  return n;
}



float sdCappedCylinder( vec3 p, float h, float r )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - vec2(r,h);
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

vec3 col = vec3(0);
float sdFireBall(vec3 p){
  vec3 q = p;
  q.xz = rotate(q.y*.8) * q.xz;

  float h = 4.;
  float ang = atan(q.z, q.x);
  float r_inc = sin(ang*.5);
  float n = noise(vec2(r_inc, q.y*.1)*.1 + vec2(0.,-T)*.08)*1.6;
  // float n = fbm(vec2(r_inc, q.y*.1)*.1 + vec2(0.,-T)*.08)*1.6;

  float r = S(0., 7., abs(q.y+1.))*4. + 1. + n;


  float d = sdCappedCylinder(q, 4., r);
  float d1 = sdCappedCylinder(q, 5., r-.4);
  d = max(d, -d1);
  
  d = abs(d)*.1 + .02;

  vec3 c = s1(vec3(3,2,1)+(q.y+q.z)*.5-T*2.);
  col += pow(1./d, 3.) * c;

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

  col = tanh(col / 1e6);

  O.rgb = col;
}