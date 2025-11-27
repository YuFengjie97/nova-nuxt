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
float hash11(float p)
{
    p = fract(p * .1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}
float sdBoxFrame( vec3 p, vec3 b, float e )
{
       p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}

float fbm(vec3 p){
  float amp = 1.;
  float fre = 1.;
  float n = 0.;
  for(float i =0.;i<4.;i++){
    n += amp*abs(dot(cos(p*fre), vec3(3,2,1)*.5));
    amp *= .5;
    fre *= 2.;
  }
  return n;
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

  vec3 ro = vec3(0.,0.,-8.);

  vec3 rd = normalize(vec3(uv, 1.));

  float zMax = 50.;
  float z = .01;

  // mat2 mx = rotate(T);
  // mat2 my = rotate(T);
  // if(iMouse.z>0.){
  //   mx = rotate(m.x);
  //   my = rotate(m.y);
  // }


  vec3 col = vec3(0);
  for(float i=0.;i<100.;i++){
    vec3 p = ro + rd * z;
    // p.z += T;

    // p += sin(p.zxy)*.2;
    // float d = length(p) - 4.;
    // float d = length(p.y) - 4.;
    float d = abs(p.y)-4.;
    {
      vec3 q = p;
      q.xz *= rotate(q.y*.4+T);
      // float d1 = length(q.xz)-1.4;
      float d1 = sdBoxFrame(q, vec3(1,4,1), .1);
      d = smax(d, -d1, .8);
      // d = max(d, -d1);
    }
    p.xz *= rotate(i*.1);
    p.yz *= rotate(i*.1);
    d += fbm(p*1.5+T)*.1;
    d = abs(d)*.2 + .03;

    col += (s1(vec3(3,2,1)+dot(p,vec3(.1))+T))/d;
    // col += (.6+sin(vec3(3,2,1)+dot(p,vec3(.2))+T))/d;
    // col += mix(vec3(1,0,0), vec3(0,1,0), dot(p,vec3(1)))/d;
    // col += palette(dot(p,vec3(1.)))/d;
    // col += dot(p,vec3(3,2,1)*.3)/d;
    // col += 1./d;

    if(d<EPSILON || z>zMax) break;
    z += d;
  }
  // col *= exp(-1e-5*z*z);
  col = tanh(col / 5e2);
  O.rgb = col;
}