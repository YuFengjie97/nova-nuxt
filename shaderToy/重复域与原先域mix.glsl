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


// iq's sdf function
float sdBoxFrame( vec3 p, vec3 b, float e )
{
       p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
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

  mat2 mx = rotate(T);
  mat2 my = rotate(T);
  if(iMouse.z>0.){
    mx = rotate(m.x);
    my = rotate(m.y);
  }

  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;

    p.xz *= mx;
    p.yz *= my;

    p = abs(p);
    p-=vec3(1,2,3);
    p.xz*=rotate(6.+T);
    p.xy*=rotate(12.+T);
    p.yz*=rotate(18.+T);


    p = clamp(p,0.,6.);

    // vec3 q = fract(p/4.)-.5;
    vec3 q = cos(p);
    q.yz *= rotate(4.2);

    vec3 q2 = mix(q, p, tanh(sin(T))*.5+.5);

    // float d = length(p) - 3.;
    float d = sdBoxFrame(q2, vec3(.6), .02);
    // d += fbm(p*5.)*.1;

    d = abs(d)*.4 + .01;
    // d = max(0., d);

    col += s1(vec3(3,2,1)+dot(p,q2)+T*2.)*pow(.2/d,2.);
    
    if(d<EPSILON || z>zMax) break;
    z += d;
  }

  col = tanh(col / 2e2);

  O.rgb = col;
}